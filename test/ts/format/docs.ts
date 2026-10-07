// Format the `motoko` code blocks in `///` doc comments with mo-fmt, which
// `mops format` does not reach. `--check` lists the blocks that would change.

import execa from "execa";
import glob from "fast-glob";
import { readFile, writeFile } from "fs/promises";
import { cpus } from "os";
import { join } from "path";

const rootDirectory = join(__dirname, "../../..");
const check = process.argv.includes("--check");

interface Block {
  path: string;
  // 1-based line of the opening fence
  line: number;
  // Indentation before `///`, shared by every line of the block
  indent: string;
  tags: string[];
  // Index of the first and one past the last code line
  start: number;
  end: number;
  code: string;
}

function blocksIn(path: string, lines: string[]): Block[] {
  const blocks: Block[] = [];
  for (let i = 0; i < lines.length; i++) {
    const open = lines[i].match(/^([ \t]*)\/\/\/ ?```motoko\b(.*)$/);
    if (!open) continue;
    const [, indent, tags] = open;
    const prefix = `${indent}///`;
    const start = i + 1;
    let end = start;
    while (lines[end]?.trim() !== "/// ```") {
      if (!lines[end]?.startsWith(prefix)) {
        throw new Error(`${path}:${i + 1}: unclosed code block`);
      }
      end++;
    }
    const code = lines
      .slice(start, end)
      .map((line) => line.slice(prefix.length).replace(/^ /, ""));
    blocks.push({
      path,
      line: i + 1,
      indent,
      tags: tags.trim().split(/\s+/).filter(Boolean),
      start,
      end,
      code: code.join("\n"),
    });
    i = end;
  }
  return blocks;
}

async function forEachLimit<T>(
  items: T[],
  limit: number,
  fn: (item: T) => Promise<void>
) {
  let next = 0;
  await Promise.all(
    Array.from({ length: Math.min(limit, items.length) }, async () => {
      while (next < items.length) {
        await fn(items[next++]);
      }
    })
  );
}

async function main() {
  // mo-fmt is not on PATH; it lives in the toolchain version mops.toml pins
  const { stdout: moFmtPath } = await execa(
    "npx",
    ["mops", "toolchain", "bin", "mo-fmt"],
    { cwd: rootDirectory }
  );

  const paths = (await glob("src/**/*.mo", { cwd: rootDirectory })).sort();
  const files = await Promise.all(
    paths.map(async (path) => {
      const lines = (await readFile(join(rootDirectory, path), "utf8")).split(
        "\n"
      );
      return { path, lines, blocks: blocksIn(path, lines) };
    })
  );

  const failures: string[] = [];
  const formatted = new Map<Block, string>();
  await forEachLimit(
    files.flatMap((file) => file.blocks),
    cpus().length,
    async (block) => {
      // Run from the root so mo-fmt reads the same mo-fmt.toml as `mops format`
      const result = await execa(
        moFmtPath,
        ["--stdin-filepath", "example.mo"],
        { cwd: rootDirectory, input: block.code, reject: false }
      );
      if (result.exitCode === 0) {
        formatted.set(block, result.stdout.replace(/\n+$/, ""));
      } else if (!block.tags.includes("no-validate")) {
        // A `no-validate` block may be a fragment that does not parse
        failures.push(
          `${block.path}:${block.line}: doc example failed to format\n${result.stderr}`
        );
      }
    }
  );

  const changed: Block[] = [];
  for (const file of files) {
    // Splice from the bottom so earlier blocks keep their line indices
    for (const block of [...file.blocks].reverse()) {
      const code = formatted.get(block);
      if (code === undefined || code === block.code) continue;
      changed.push(block);
      const lines = code
        .split("\n")
        .map((line) =>
          line ? `${block.indent}/// ${line}` : `${block.indent}///`
        );
      file.lines.splice(block.start, block.end - block.start, ...lines);
    }
    if (!check && file.blocks.some((block) => changed.includes(block))) {
      await writeFile(join(rootDirectory, file.path), file.lines.join("\n"));
    }
  }

  changed.sort((a, b) => a.path.localeCompare(b.path) || a.line - b.line);
  for (const block of changed) {
    console.log(`${block.path}:${block.line}`);
  }
  for (const failure of failures) {
    console.error(failure);
  }
  const total = files.reduce((sum, file) => sum + file.blocks.length, 0);
  if (changed.length) {
    console.log(
      check
        ? `${changed.length} of ${total} doc examples need formatting. Run \`npm run format\`.`
        : `Formatted ${changed.length} of ${total} doc examples.`
    );
  } else {
    console.log(`All ${total} doc examples are formatted.`);
  }
  process.exit(failures.length ? 2 : check && changed.length ? 1 : 0);
}

main().catch((err) => {
  console.error(err);
  process.exit(2);
});
