import { Principal } from "@dfinity/principal";
import { PocketIc, PocketIcServer } from "@dfinity/pic";
import chalk from "chalk";
import execa from "execa";
import { mkdir, mkdtemp, readFile, rm, writeFile } from "fs/promises";
import { glob } from "glob";
import { cpus, tmpdir } from "os";
import { dirname, join, relative } from "path";

interface TestResult {
  snippet: Snippet;
  status: "passed" | "failed" | "skipped";
  error?: any;
  time: number;
}

interface ExampleActor {
  main?(): Promise<void>;
}

interface Snippet {
  path: string;
  line: number;
  language: string;
  tags: string[];
  name: string | undefined;
  includes: Snippet[];
  sourceCode: string;
}

const testStatusEmojis: Record<TestResult["status"], string> = {
  passed: "✅",
  failed: "❌",
  skipped: "🚫",
};

const rootDirectory = join(__dirname, "../../..");

// Treat redundant type instantiations (M0223) and `@deprecated` usages (M0154)
// as errors in doc snippets — examples must never use deprecated APIs.
const mocExtraFlags = ["-E=M0223,M0154"];

async function resolveMocPath(): Promise<string> {
  if (process.env.DFX_MOC_PATH) return process.env.DFX_MOC_PATH;
  const { stdout } = await execa("npx", ["mops", "toolchain", "bin", "moc"], {
    cwd: rootDirectory,
  });
  const path = stdout.trim();
  if (!path) {
    throw new Error(
      "Could not resolve `moc` binary. Set DFX_MOC_PATH or run `mops toolchain init`."
    );
  }
  return path;
}

async function pMap<T, R>(
  items: T[],
  limit: number,
  fn: (item: T, idx: number, workerIdx: number) => Promise<R>
): Promise<R[]> {
  const results: R[] = new Array(items.length);
  let next = 0;
  // `workerIdx` is bound to the JS loop, not the item index. This is what
  // callers rely on to claim per-worker resources (temp files, canisters)
  // without collisions when items finish out of order.
  await Promise.all(
    Array.from({ length: Math.min(limit, items.length) }, async (_, workerIdx) => {
      while (true) {
        const idx = next++;
        if (idx >= items.length) return;
        results[idx] = await fn(items[idx], idx, workerIdx);
      }
    })
  );
  return results;
}

// PocketIC returns 409/202 under load; the pic client surfaces these as
// transient string errors. Retry with backoff so concurrent operations across
// worker canisters don't spuriously fail validation. `Server busy` is always
// pre-accept (safe to retry); the other two can fire after the request was
// accepted but the client gave up polling — re-submission is acceptable here
// because doc snippets are stateless (reinstall wipes state, and re-running
// `main()` produces the same result).
const transientPicErrors = [
  "Server busy",
  "Server started processing",
  "Unknown state",
];

async function withRetry<T>(fn: () => Promise<T>): Promise<T> {
  const maxAttempts = 8;
  let delayMs = 50;
  for (let attempt = 1; ; attempt++) {
    try {
      return await fn();
    } catch (err: any) {
      const msg = String(err?.message ?? err);
      if (
        attempt >= maxAttempts ||
        !transientPicErrors.some((m) => msg.includes(m))
      ) {
        throw err;
      }
      // Jitter so concurrent retriers don't wake in lockstep.
      const jitter = delayMs * (0.5 + Math.random() * 0.5);
      await new Promise((resolve) => setTimeout(resolve, jitter));
      delayMs = Math.min(delayMs * 2, 1000);
    }
  }
}

async function main() {
  const testFilters = process.argv.slice(2);

  const sourcePaths = (await glob(join(rootDirectory, "src/**/*.mo"))).sort();

  let skippable = true;
  const snippets: Snippet[] = (
    await Promise.all(
      sourcePaths.map(async (path) => {
        const virtualPath = relative(rootDirectory, path);

        // Require matching at least one test filter
        if (
          testFilters.length &&
          testFilters.every((testFilter) => !virtualPath.includes(testFilter))
        ) {
          return [];
        }

        // Skip internal modules
        if (skippable && !virtualPath.startsWith("src/internal/")) {
          skippable = false;
        }

        const content = await readFile(path, "utf8");

        // Empty non-doc-comment lines to preserve line numbers
        const docComments = content.replace(/^[ \t]*\/\/\/ ?/gm, "");

        const codeBlocks: {
          line: number;
          language: string | undefined;
          sourceCode: string;
          tags: string[];
        }[] = [];

        const getLineNumber = (text: string, charIndex: number): number => {
          if (!text || charIndex < 0 || charIndex >= text.length) {
            return -1;
          }
          let line = 1;
          for (let i = 0; i < charIndex; i++) {
            if (text[i] === "\n") {
              line++;
            }
          }
          return line;
        };

        for (const match of docComments.matchAll(
          /```(\S*)?(?:[ \t]+([^\n]+)?)?\n([\s\S]*?)\n[ \t]*```/g
        )) {
          const [_, language, tags, sourceCode] = match;
          codeBlocks.push({
            line: getLineNumber(docComments, match.index),
            language,
            tags: tags?.trim() ? tags.trim().split(/\s+/) : [],
            sourceCode: sourceCode.trim(),
          });
        }

        const snippets: Snippet[] = [];
        const snippetMap = new Map<string, Snippet>();
        for (const { line, language, tags, sourceCode } of codeBlocks) {
          const snippet: Snippet = {
            path: virtualPath,
            line,
            language,
            tags,
            name: tags
              .find((attr) => attr.startsWith("name="))
              ?.substring("name=".length),
            includes: [],
            sourceCode,
          };
          snippets.push(snippet);
          if (snippet.name) {
            if (snippetMap.has(snippet.name)) {
              throw new Error(
                `${snippet.path}:${snippet.line} Duplicate snippet name: ${snippet.name}`
              );
            }
            snippetMap.set(snippet.name, snippet);
          }
        }
        // Resolve "include=..." references
        for (const snippet of snippets) {
          for (const attr of snippet.tags) {
            if (attr.startsWith("include=")) {
              const name = attr.substring("include=".length);
              const include = snippetMap.get(name);
              if (!include) {
                throw new Error(
                  `${snippet.path}:${snippet.line} Unresolved snippet attribute: ${attr}`
                );
              }
              snippet.includes.push(include);
            }
          }
        }
        return snippets;
      })
    )
  ).flatMap((snippets) => snippets);

  const allPaths = [...new Set(snippets.map((snippet) => snippet.path))];
  console.log(
    `Found ${snippets.length} code snippet${
      snippets.length === 1 ? "" : "s"
    } in ${allPaths.length} file${allPaths.length === 1 ? "" : "s"}.`
  );
  if (!skippable && snippets.length == 0) {
    process.exit(1);
  }

  // Mirror `mo:core` source files to a temp directory once. Each compile passes
  // it via `--package core`, replacing the in-memory virtual FS used previously.
  const workDir = await mkdtemp(join(tmpdir(), "validate-docs-"));
  const corePackageDir = join(workDir, "core");
  for (const path of sourcePaths) {
    const target = join(corePackageDir, relative(join(rootDirectory, "src"), path));
    await mkdir(dirname(target), { recursive: true });
    await writeFile(target, await readFile(path));
  }

  const mocPath = await resolveMocPath();

  // Start PocketIC with a pool of canisters. Each worker owns one canister so
  // installs and calls can run in parallel (different canisters do not block
  // each other on the PocketIC server).
  const poolSize = Math.max(1, Math.min(snippets.length, cpus().length));

  const results: (TestResult | undefined)[] = new Array(snippets.length);
  const testResults: TestResult[] = [];
  let pocketIcServer: PocketIcServer | undefined;
  let pocketIc: PocketIc | undefined;
  try {
    pocketIcServer = await PocketIcServer.start({
      showRuntimeLogs: false,
      showCanisterLogs: false, // TODO: enable with --verbose flag?
    });
    pocketIc = await PocketIc.create(pocketIcServer.getUrl());
    const ic = pocketIc;

    console.log(`Creating ${poolSize} canister${poolSize === 1 ? "" : "s"}...`);
    const principals: Principal[] = await Promise.all(
      Array.from({ length: poolSize }, async () => {
        const principal = await withRetry(() => ic.createCanister());
        await withRetry(() =>
          ic.updateCanisterSettings({
            canisterId: principal,
            controllers: [Principal.anonymous()],
          })
        );
        return principal;
      })
    );

    console.log(`Running snippets...`);

    // Print results live as snippets finish, but always in the original snippet
    // order so per-file headers and the summary stay coherent.
    let nextToPrint = 0;
    let previousSnippet: Snippet | undefined;
    const flush = () => {
      while (nextToPrint < snippets.length) {
        const snippet = snippets[nextToPrint];
        const result = results[nextToPrint];
        const isSkipped =
          snippet.language !== "motoko" || snippet.tags.includes("no-validate");
        if (!isSkipped && !result) break;
        if (snippet.path !== previousSnippet?.path) {
          console.log(chalk.gray(snippet.path));
        }
        if (result) {
          testResults.push(result);
          if (testFilters.length || result.status !== "passed") {
            console.log(
              testStatusEmojis[result.status],
              `${snippet.path}:${snippet.line}`.padEnd(30),
              chalk.grey(`${(result.time / 1000).toFixed(1)}s`)
            );
          }
          if (result.error) {
            console.log(chalk.grey(displaySnippet(snippet)));
            console.error(chalk.red(result.error));
          }
        } else {
          console.log(
            testStatusEmojis["skipped"],
            `${snippet.path}:${snippet.line}`,
            chalk.grey("skipped")
          );
          console.log(chalk.grey(displaySnippet(snippet)));
        }
        previousSnippet = snippet;
        nextToPrint++;
      }
    };

    await pMap(snippets, poolSize, async (snippet, idx, workerIdx) => {
      if (snippet.language !== "motoko" || snippet.tags.includes("no-validate")) {
        flush();
        return;
      }
      const startTime = Date.now();
      let status: TestResult["status"];
      let error;
      try {
        await runSnippet(snippet, {
          mocPath,
          corePackageDir,
          workDir,
          workerIdx,
          principal: principals[workerIdx],
          pocketIc: ic,
        });
        status = "passed";
      } catch (err) {
        error = err;
        status = "failed";
      }
      results[idx] = {
        snippet,
        status,
        error,
        time: Date.now() - startTime,
      };
      flush();
    });
    flush();
  } finally {
    // Best-effort cleanup; warn rather than throw so we don't mask a primary
    // error from the `try` body.
    const warn = (label: string) => (err: unknown) =>
      console.warn(`Cleanup of ${label} failed:`, err);
    await pocketIc?.tearDown().catch(warn("PocketIC instance"));
    await pocketIcServer?.stop().catch(warn("PocketIC server"));
    await rm(workDir, { recursive: true, force: true }).catch(warn(workDir));
  }

  const paths = new Set(snippets.map((snippet) => snippet.path));
  const failedPaths = new Set(
    testResults
      .filter((result) => result.status === "failed")
      .map((result) => result.snippet.path)
  );
  if (paths.size > 1 && failedPaths.size) {
    console.log("---");
    failedPaths.forEach((path) => {
      console.log(
        `${path} ${testStatusEmojis["failed"]} ${
          testResults.filter(
            (result) =>
              result.status === "failed" && result.snippet.path === path
          ).length
        }`
      );
    });
  }
  console.log(
    ["passed", "failed", "skipped"]
      .map(
        (status: TestResult["status"]) =>
          `${
            testResults.filter((result) => result.status === status).length
          } ${status}`
      )
      .join(", ")
  );

  // Exit code 1 for failed tests
  const hasError =
    (!skippable && testResults.length === 0) ||
    testResults.some((result) => result.status === "failed");
  process.exit(hasError ? 1 : 0);
}

interface RunContext {
  mocPath: string;
  corePackageDir: string;
  workDir: string;
  workerIdx: number;
  principal: Principal;
  pocketIc: PocketIc;
}

const runSnippet = async (snippet: Snippet, ctx: RunContext) => {
  const extractImports = (source: string) => {
    const importLines = [];
    const nonImportLines = [];
    let doneWithImports = false;
    for (const line of source.split("\n")) {
      // Basic import detection
      if (line.startsWith("import ")) {
        if (doneWithImports) {
          throw new Error("Unexpected import line");
        }
        importLines.push(line);
      } else {
        nonImportLines.push(line);
        const trimmedLine = line.trim();
        if (trimmedLine && !trimmedLine.startsWith("//")) {
          doneWithImports = true;
        }
      }
    }
    return [importLines.join("\n"), nonImportLines.join("\n")];
  };

  if (
    snippet.sourceCode.startsWith("\n") ||
    snippet.sourceCode.endsWith("\n")
  ) {
    throw new Error("Unexpected leading / trailing newline");
  }
  const snippetSource = [
    // Prepend source code included from other snippets
    ...snippet.includes.map((include) => include.sourceCode),
    snippet.sourceCode,
  ].join("\n");
  let actorSource = snippetSource;

  // Wrap in persistent actor if not otherwise specified
  // TODO: more sophisticated check
  if (!/^(persistent +)?actor.*\{$/m.test(actorSource)) {
    const [imports, nonImports] = extractImports(snippetSource);
    actorSource = `${imports}\n\npersistent actor { ignore do {\n${nonImports}\n} }`;
  }

  // Rewrite `// => ...` comments as assertions
  actorSource = actorSource
    .split("\n")
    .map((line) => {
      const match = line.match(
        /^(\s*(?:(?:let|var)\s+\S+\s*=\s*|ignore\s+)?)(.*)\s*\/\/ => (.+?)(?:\s*\/\/.*)?$/
      );
      if (match) {
        const [_, pre, statement, expected] = match;
        return `${pre} do { let _value_ = do { ${statement} }; assert _value_ == (${expected}); _value_ };`;
      }
      return line;
    })
    .join("\n");

  // Check for incorrectly-formatted assertion comment
  const assertionCommentMatch = actorSource.match(/\/\/ ?[=-]>/);
  if (assertionCommentMatch) {
    throw new Error(
      `${snippet.path}:${snippet.line} Unable to parse assertion comment: ${assertionCommentMatch[0]}`
    );
  }

  // Write source to a worker-scoped temp file. Reusing the same path per worker
  // keeps the temp directory bounded and avoids cross-worker collisions.
  const sourcePath = join(ctx.workDir, `worker-${ctx.workerIdx}.mo`);
  const wasmPath = join(ctx.workDir, `worker-${ctx.workerIdx}.wasm`);
  await writeFile(sourcePath, actorSource);

  try {
    await execa(
      ctx.mocPath,
      [
        "--package",
        "core",
        ctx.corePackageDir,
        "--actor-alias",
        "snippet",
        ctx.principal.toText(),
        ...mocExtraFlags,
        "-o",
        wasmPath,
        sourcePath,
      ],
      { stdio: "pipe" }
    );
  } catch (err: any) {
    const stderr = (err.stderr ?? "").toString().trim();
    throw new Error(stderr || err.message || String(err));
  }

  const wasmBuffer = await readFile(wasmPath);
  const wasm = wasmBuffer.buffer.slice(
    wasmBuffer.byteOffset,
    wasmBuffer.byteOffset + wasmBuffer.byteLength
  ) as ArrayBuffer;

  await withRetry(() =>
    ctx.pocketIc.reinstallCode({
      canisterId: ctx.principal,
      wasm,
    })
  );

  // Call `main()` if present. Strip line/block comments so the heuristic
  // doesn't match `func main` mentioned in prose comments.
  const hasMain = /\bfunc\s+main\b/.test(stripComments(actorSource));
  const actor: ExampleActor = ctx.pocketIc.createActor(({ IDL }) => {
    return IDL.Service(
      hasMain
        ? {
            main: IDL.Func([], []),
          }
        : {}
    );
  }, ctx.principal);
  if (hasMain) {
    await withRetry(() => actor.main!());
  }
};

main().catch((err) => {
  console.error(err);
  process.exit(1);
});

// Strips line and block comments. Doesn't handle string literals; acceptable
// for the heuristic uses below.
const stripComments = (source: string): string =>
  source.replace(/\/\/[^\n]*/g, "").replace(/\/\*[\s\S]*?\*\//g, "");

const displaySnippet = (snippet: Snippet) => {
  const tripleBacktick = "```";
  return `${tripleBacktick}${snippet.language || ""}${
    snippet.tags.length ? ` ${snippet.tags.join(" ")}` : ""
  }\n${snippet.sourceCode}\n${tripleBacktick}`;
};
