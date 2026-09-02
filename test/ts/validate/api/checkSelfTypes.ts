// Every public function whose first parameter is named `self` must take the module's
// own type (e.g. all `self` parameters in Nat.mo are of type `Nat`), so that contextual
// dot notation resolves where readers expect. Intentional exceptions such as conversion
// functions (`List.toList(self : Iter<T>)`, used as `iter.toList()`) are marked with an
// `// ignore-self-type-check` comment on the declaration.

import { readFileSync } from "fs";
import { basename, join, relative } from "path";
import glob from "fast-glob";

const rootDir = join(__dirname, "../../../..");
const srcDir = join(rootDir, "src");

const IGNORE_MARKER = "ignore-self-type-check";

// Modules whose subject type is not simply named after the file
const expectedHeadOverrides: Record<string, string> = {
  Array: "[]",
  VarArray: "[var]",
  Option: "?",
  RealTimeQueue: "Queue",
};

// Reduces a type to the shape used for comparison: an array, a mutable array, an option,
// or the last segment of the leading type path (`Types.List<T>` -> "List")
function typeHead(type: string): string {
  if (type.startsWith("[var")) return "[var]";
  if (type.startsWith("[")) return "[]";
  if (type.startsWith("?")) return "?";
  const match = type.match(/^[A-Za-z_][A-Za-z0-9_.]*/);
  if (!match) return type;
  const path = match[0].split(".");
  return path[path.length - 1];
}

// Reads the `self` parameter's type starting at `start`, up to the end of the first
// parameter (a `,` or `)` outside any nested brackets)
function parseSelfType(source: string, start: number): [string, number] {
  let depth = 0;
  let i = start;
  while (i < source.length) {
    const c = source[i];
    if (c === "<" || c === "(" || c === "[") depth++;
    else if (c === "]" || (c === ">" && source[i - 1] !== "-")) depth--;
    else if (c === ")") {
      if (depth === 0) break;
      depth--;
    } else if (c === "," && depth === 0) break;
    i++;
  }
  return [source.slice(start, i).replace(/\s+/g, " ").trim(), i];
}

const errors: string[] = [];

const moFiles = glob.sync(join(srcDir, "**/*.mo")).sort();
if (moFiles.length === 0) {
  throw new Error("Expected at least one Motoko file in `src` directory");
}
moFiles.forEach((srcPath) => {
  const moduleName = basename(srcPath, ".mo");
  const expectedHead = expectedHeadOverrides[moduleName] ?? moduleName;
  const source = readFileSync(srcPath, "utf8");

  // Same declaration shape as the api.lock.json parser in `index.ts`
  const declarationRegex =
    /\n {2}(public\s+(?:func|let|class)\s+\w+[^{=]*?)\(\s*self\s*:\s*/g;
  let match;
  while ((match = declarationRegex.exec(source)) !== null) {
    const [matched, prefix] = match;
    // A `)` before the matched paren means `self` is not in the declaration's
    // first parameter list
    if (prefix.includes(")")) continue;

    const [selfType, typeEnd] = parseSelfType(
      source,
      match.index + matched.length
    );
    // The marker window covers the declaration plus one more line, since prettier
    // moves a trailing comment on a `func` declaration into the body's first line
    const declarationEnd = source.indexOf("\n", typeEnd);
    const markerWindow = source.slice(
      match.index,
      source.indexOf("\n", declarationEnd + 1)
    );
    if (markerWindow.includes(IGNORE_MARKER)) continue;

    if (typeHead(selfType) !== expectedHead) {
      const line = source.slice(0, match.index).split("\n").length + 1;
      const name = prefix.replace(/\s+/g, " ").trim();
      errors.push(
        `${relative(rootDir, srcPath)}:${line}: \`${name}\` takes ` +
          `\`self : ${selfType}\`, but every \`self\` in ${moduleName}.mo should be of ` +
          `type \`${expectedHead}\` so that contextual dot notation resolves as expected.\n` +
          `If the mismatch is intentional (e.g. a conversion function), add an ` +
          `\`// ${IGNORE_MARKER}\` comment to the declaration.`
      );
    }
  }
});

if (errors.length) {
  errors.forEach((error) => console.error(error + "\n"));
  process.exit(1);
}
