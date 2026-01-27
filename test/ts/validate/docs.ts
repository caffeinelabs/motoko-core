import { Principal } from "@dfinity/principal";
import { PocketIc, PocketIcServer } from "@dfinity/pic";
import chalk from "chalk";
import { readFile } from "fs/promises";
import { glob } from "glob";
import motoko from "motoko";
import { join, relative } from "path";

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

async function main() {
  const testFilters = process.argv.slice(2);

  const virtualBaseDirectory = "motoko-base";
  motoko.usePackage("core", join(virtualBaseDirectory, "src")); // Register `mo:core`

  let skippable = true;
  const snippets: Snippet[] = (
    await Promise.all(
      (await glob(join(rootDirectory, "src/**/*.mo")))
        .sort()
        .map(async (path) => {
          const virtualPath = relative(rootDirectory, path);

          // Write to virtual file system
          const content = await readFile(path, "utf8");
          motoko.write(join(virtualBaseDirectory, virtualPath), content);

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

  // Start PocketIC
  const pocketIcServer = await PocketIcServer.start({
    showRuntimeLogs: false,
    showCanisterLogs: false, // TODO: enable with --verbose flag?
  });
  const pocketIc = await PocketIc.create(pocketIcServer.getUrl());

  console.log("Creating canisters...");
  const sourcePrincipal = await pocketIc.createCanister();
  //   const testPrincipal = await pocketIc.createCanister();
  await pocketIc.updateCanisterSettings({
    canisterId: sourcePrincipal,
    controllers: [Principal.anonymous() /* , testPrincipal */],
  });

  console.log(`Running snippets...`);
  const testResults: TestResult[] = [];
  let previousSnippet: Snippet | undefined;
  for (const snippet of snippets) {
    if (snippet.path !== previousSnippet?.path) {
      console.log(chalk.gray(snippet.path));
    }
    if (
      snippet.language === "motoko" &&
      !snippet.tags.includes("no-validate")
    ) {
      const startTime = Date.now();
      let status: TestResult["status"];
      let error;
      try {
        await runSnippet(snippet, pocketIc, sourcePrincipal);
        status = "passed";
      } catch (err) {
        error = err;
        status = "failed";
      }
      const result: TestResult = {
        snippet,
        status,
        error,
        time: Date.now() - startTime,
      };
      testResults.push(result);
      if (testFilters.length || status !== "passed") {
        console.log(
          testStatusEmojis[status],
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
  }
  await pocketIc.tearDown();
  await pocketIcServer.stop();

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

const runSnippet = async (
  snippet: Snippet,
  pocketIc: PocketIc,
  sourcePrincipal: Principal
) => {
  // Set canister alias
  const sourceCanisterName = "snippet";
  motoko.setAliases(".", { [sourceCanisterName]: sourcePrincipal.toText() });

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

  // Write to virtual file system
  const virtualPath = join(
    "snippet",
    `${snippet.path.replace(/\.mo$/, "")}_${snippet.line}.mo`
  );
  motoko.write(virtualPath, actorSource);

  // Compile source Wasm
  const sourceResult = motoko.wasm(virtualPath, "ic");
  motoko.write(`${sourcePrincipal.toText()}.did`, sourceResult.candid);

  // Install Wasm files
  await pocketIc.reinstallCode({
    canisterId: sourcePrincipal,
    wasm: sourceResult.wasm,
  });

  // Call `example()` method
  const hasMain = actorSource.includes("func main"); // TODO: more robust?
  const actor: ExampleActor = pocketIc.createActor(({ IDL }) => {
    return IDL.Service(
      hasMain
        ? {
            main: IDL.Func([], []),
          }
        : {}
    );
  }, sourcePrincipal);
  await actor.main?.();
};

main().catch((err) => {
  console.error(err);
  process.exit(1);
});

const displaySnippet = (snippet: Snippet) => {
  const tripleBacktick = "```";
  return `${tripleBacktick}${snippet.language || ""}${
    snippet.tags.length ? ` ${snippet.tags.join(" ")}` : ""
  }\n${snippet.sourceCode}\n${tripleBacktick}`;
};
