import { existsSync, readdirSync, readFileSync, writeFileSync } from "fs";
import { join } from "path";

const rootDir = join(__dirname, "../../../..");
const srcDir = join(rootDir, "src");
const validationDir = join(rootDir, "validation");
const apiDir = join(validationDir, "api");

interface Module {
  name: string;
  functions: Func[];
}

interface Func {
  name: string;
  declaration: string;
}

interface Spec {
  name: string;
  modules: string[];
  functions: string[];
  extends: string[];
}

const moduleMap = new Map<string, Module>();

function readModules(dir: string, subdir: string = "") {
  readdirSync(join(dir, subdir), { withFileTypes: true }).forEach((entry) => {
    const subPath = join(subdir, entry.name);
    const fullPath = join(dir, subPath);
    if (entry.isDirectory()) {
      readModules(dir, subPath);
    } else if (entry.isFile() && entry.name.endsWith(".mo")) {
      // Use forward slashes regardless of platform
      const name = subPath.replace(/\\/g, "/").replace(/\.mo$/, "");
      const modules = parseModules(name, readFileSync(fullPath, "utf8"));
      if (!modules[0].functions.length) {
        throw new Error(`No public declarations found in ${name}.mo`);
      }
      modules.forEach((module) => {
        if (moduleMap.has(module.name)) {
          throw new Error(`Module already exists with name: '${module.name}'`);
        }
        moduleMap.set(module.name, module);
      });
    }
  });
}

const declarationKinds = ["func", "let", "var", "class", "type", "module", "object"];
const declarationModifiers = ["shared", "query", "composite", "persistent"];

// Scanner-based parser: walks a Motoko source file tracking comments, text
// literals, and bracket nesting to extract complete public declarations,
// including from nested public modules/classes (emitted as dotted submodules).
function parseModules(fileName: string, source: string): Module[] {
  const s = source;
  let pos = 0;
  const modules: Module[] = [];

  const error = (message: string): never => {
    const line = s.slice(0, pos).split("\n").length;
    throw new Error(`${fileName}.mo:${line}: ${message}`);
  };

  const skipTrivia = () => {
    for (;;) {
      while (pos < s.length && /\s/.test(s[pos])) pos++;
      if (s.startsWith("//", pos)) {
        while (pos < s.length && s[pos] !== "\n") pos++;
      } else if (s.startsWith("/*", pos)) {
        // Motoko block comments nest
        let depth = 0;
        do {
          if (pos >= s.length) error("Unterminated block comment");
          if (s.startsWith("/*", pos)) {
            depth++;
            pos += 2;
          } else if (s.startsWith("*/", pos)) {
            depth--;
            pos += 2;
          } else {
            pos++;
          }
        } while (depth > 0);
      } else {
        return;
      }
    }
  };

  const skipTextLike = (): boolean => {
    const quote = s[pos];
    if (quote !== '"' && quote !== "'") return false;
    pos++;
    while (pos < s.length && s[pos] !== quote) {
      pos += s[pos] === "\\" ? 2 : 1;
    }
    if (pos >= s.length) error("Unterminated text literal");
    pos++;
    return true;
  };

  const readWord = (): string => {
    const start = pos;
    while (pos < s.length && /[A-Za-z0-9_]/.test(s[pos])) pos++;
    return s.slice(start, pos);
  };

  // Skip past a balanced ()/[]/{} block starting at the current position
  const skipBlock = () => {
    let depth = 0;
    for (;;) {
      skipTrivia();
      if (pos >= s.length) error("Unterminated block");
      if (skipTextLike()) continue;
      const c = s[pos];
      if (c === "{" || c === "(" || c === "[") depth++;
      else if (c === "}" || c === ")" || c === "]") depth--;
      pos++;
      if (depth === 0) return;
    }
  };

  // Skip a `= <expression>` body up to its terminating semicolon
  const skipValue = () => {
    let depth = 0;
    for (;;) {
      skipTrivia();
      if (pos >= s.length) error("Unterminated declaration value");
      if (skipTextLike()) continue;
      const c = s[pos];
      if (depth === 0 && c === ";") {
        pos++;
        return;
      }
      if (depth === 0 && c === "}") return; // end of enclosing block
      if (c === "{" || c === "(" || c === "[") depth++;
      else if (c === "}" || c === ")" || c === "]") depth--;
      pos++;
    }
  };

  // Scan a declaration from `start` (at the `public` keyword) up to its body
  // (`{`), value (`=`), or end (`;`). Type declarations continue through `=`
  // so that the aliased type shape is locked as well.
  const scanDeclaration = (start: number, kind: string) => {
    let paren = 0;
    let bracket = 0;
    let brace = 0;
    let angle = 0;
    let typeRhs = false;
    // Last meaningful token, to tell a record/object type `{` from a body `{`
    let lastToken = "";
    const typeBraceTokens = [":", "->", "<:", "=", "and", "or", "actor", "object", "module"];
    for (;;) {
      skipTrivia();
      if (pos >= s.length) error("Unterminated public declaration");
      const c = s[pos];
      if (c === '"' || c === "'") error("Unexpected text literal in declaration");
      if (/[A-Za-z0-9_]/.test(c)) {
        lastToken = readWord();
        continue;
      }
      const nested = paren + bracket + brace + angle > 0;
      if (!nested && c === ";") {
        break;
      } else if (!nested && c === "=" && !typeRhs) {
        if (kind !== "type") break;
        typeRhs = true;
      } else if (c === "{") {
        if (!nested && !typeRhs && !typeBraceTokens.includes(lastToken)) {
          // Declaration body; leave `{` unconsumed
          return { declaration: s.slice(start, pos), terminator: "{" };
        }
        brace++;
      } else if (c === "}") {
        if (brace === 0) break; // end of enclosing block (e.g. `public let x = 0` without `;`)
        brace--;
      } else if (c === "(") paren++;
      else if (c === ")") paren--;
      else if (c === "[") bracket++;
      else if (c === "]") bracket--;
      else if (c === "<" && s[pos + 1] === ":") {
        pos += 2;
        lastToken = "<:";
        continue;
      } else if (c === "-" && s[pos + 1] === ">") {
        pos += 2;
        lastToken = "->";
        continue;
      } else if (c === "<") angle++;
      else if (c === ">") angle--;
      lastToken = c;
      pos++;
    }
    if (paren || bracket || brace || angle) {
      error(`Unbalanced public declaration: ${s.slice(start, pos)}`);
    }
    return { declaration: s.slice(start, pos), terminator: s[pos] };
  };

  const parsePublic = (start: number, prefix: string, functions: Func[]) => {
    skipTrivia();
    let kind = readWord();
    while (declarationModifiers.includes(kind)) {
      skipTrivia();
      kind = readWord();
    }
    if (!declarationKinds.includes(kind)) {
      error(`Unsupported public declaration kind: '${kind || s[pos]}'`);
    }
    skipTrivia();
    const name = readWord();
    if (!name) {
      error(`Missing name in public ${kind} declaration`);
    }
    const { declaration, terminator } = scanDeclaration(start, kind);
    functions.push({
      name,
      declaration: formatDeclaration(name, declaration, () =>
        error(`Malformed public declaration: ${declaration}`)
      ),
    });
    if (terminator === "{") {
      if (kind === "module" || kind === "object" || kind === "class") {
        pos++;
        scanContainer(`${prefix}${name}.`, functions);
      } else {
        skipBlock();
      }
    } else if (terminator === "=") {
      pos++;
      skipValue();
    } else if (terminator === ";") {
      pos++;
    }
  };

  // Scan a module/class/object body (after its `{`), collecting public
  // declarations and recursing into public containers
  const scanContainer = (path: string, parentFunctions: Func[] | null) => {
    const functions: Func[] = [];
    modules.push({
      name: path ? `${fileName}.${path.slice(0, -1)}` : fileName,
      functions,
    });
    for (;;) {
      skipTrivia();
      if (pos >= s.length) {
        if (path) error("Unterminated container body");
        return;
      }
      if (skipTextLike()) continue;
      const c = s[pos];
      if (c === "}") {
        pos++;
        return;
      }
      if (c === "{" || c === "(" || c === "[") {
        skipBlock();
        continue;
      }
      if (/[A-Za-z_]/.test(c)) {
        const start = pos;
        const word = readWord();
        if (word === "public") {
          parsePublic(start, path, functions);
        }
        continue;
      }
      pos++;
    }
  };

  // Find the file's top-level module declaration
  for (;;) {
    skipTrivia();
    if (pos >= s.length) error("No module declaration found");
    if (skipTextLike()) continue;
    const c = s[pos];
    if (/[A-Za-z_]/.test(c)) {
      const word = readWord();
      if (word === "module") {
        skipTrivia();
        readWord(); // optional module name
        skipTrivia();
        if (s[pos] !== "{") error("Expected '{' after top-level module");
        pos++;
        scanContainer("", null);
        return modules;
      }
      continue;
    }
    if (c === "{" || c === "(" || c === "[") {
      skipBlock();
      continue;
    }
    pos++;
  }
}

// Normalize a raw declaration for the lockfile: collapse whitespace, drop the
// redundant `public` keyword, and present function-typed `let` bindings (used
// as an inlining optimization) in ordinary `func` syntax.
function formatDeclaration(
  name: string,
  declaration: string,
  malformed: () => never
): string {
  let result = declaration
    .replace(/\s+/g, " ")
    .replace(/([(<[])\s+/g, "$1")
    .replace(/\s+([)>\],])/g, "$1")
    .trim()
    .replace(/^public /, "");
  if (!result || result.endsWith(":") || result.endsWith("=")) {
    malformed();
  }
  const letMatch = result.match(/^let (\w+) : (.+)$/);
  if (letMatch) {
    const asFunc = letToFunc(letMatch[1], letMatch[2]);
    if (asFunc !== null) {
      result = asFunc;
    }
  }
  return result;
}

// Rewrite `let name : <T>(args) -> Ret` as `func name<T>(args) : Ret`;
// returns null for non-function types
function letToFunc(name: string, type: string): string | null {
  let rest = type;
  const modifiers = rest.match(/^(shared( query)?|query|composite query) /);
  const prefix = modifiers ? modifiers[0] : "";
  rest = rest.slice(prefix.length);
  let typeParams = "";
  if (rest.startsWith("<")) {
    const end = findBalanced(rest, "<", ">");
    if (end < 0) return null;
    typeParams = rest.slice(0, end + 1);
    rest = rest.slice(end + 1).trimStart();
  }
  const arrow = findTopLevelArrow(rest);
  if (arrow < 0) return null;
  const domain = rest.slice(0, arrow).trim();
  const codomain = rest.slice(arrow + 2).trim();
  const params =
    domain.startsWith("(") && findBalanced(domain, "(", ")") === domain.length - 1
      ? domain
      : `(${domain})`;
  return `${prefix}func ${name}${typeParams}${params} : ${codomain}`;
}

// Index of the closing delimiter matching an opening one at index 0
function findBalanced(text: string, open: string, close: string): number {
  let depth = 0;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (open === "<" && c === "<" && text[i + 1] === ":") {
      i++;
      continue;
    }
    if (open === "<" && c === ">" && text[i - 1] === "-") continue;
    if (c === open) depth++;
    else if (c === close) {
      depth--;
      if (depth === 0) return i;
    }
  }
  return -1;
}

// Index of the first `->` outside any brackets, or -1
function findTopLevelArrow(type: string): number {
  let depth = 0;
  for (let i = 0; i < type.length; i++) {
    const c = type[i];
    if (c === "-" && type[i + 1] === ">") {
      if (depth === 0) return i;
      i++;
    } else if (c === "<" && type[i + 1] === ":") i++;
    else if (c === "(" || c === "[" || c === "{" || c === "<") depth++;
    else if (c === ")" || c === "]" || c === "}" || c === ">") depth--;
  }
  return -1;
}

if (!existsSync(srcDir)) {
  throw new Error(`Directory "${srcDir}" does not exist.`);
}

const errors: string[] = [];

// Read module files
readModules(srcDir);

// Read spec files
const specs: Spec[] = [];
const specMap = new Map<string, Spec>();
readdirSync(validationDir)
  .filter((file) => file.endsWith(".json"))
  .forEach((file) => {
    try {
      const content = JSON.parse(
        readFileSync(join(validationDir, file), "utf-8")
      );
      const items = content.specs;
      if (!Array.isArray(items)) {
        throw new Error(`Unexpected spec format`);
      }
      specs.push(
        ...items.map((config: any, index: number) => {
          const name = config.name;
          if (!name) {
            throw new Error(`Unnamed spec with index ${index}`);
          }
          if (specMap.has(name)) {
            throw new Error(`Spec already exists with name: '${name}'`);
          }
          const spec = <Spec>{
            name,
            modules: config.modules || [],
            functions: config.functions || [],
            extends: config.extends || [],
          };
          specMap.set(name, spec);
          return spec;
        })
      );
    } catch (err) {
      console.error(`Error while reading spec file: ${file}`);
      throw err;
    }
  });

// Deterministic, locale-independent ordering
const compareStrings = (a: string, b: string) => (a < b ? -1 : a > b ? 1 : 0);

// Update lockfile
writeFileSync(
  join(apiDir, "api.lock.json"),
  JSON.stringify(
    [...moduleMap.keys()].sort(compareStrings).map((key) => {
      const module = moduleMap.get(key);
      return {
        name: module.name,
        exports: module.functions
          .slice()
          .sort(
            (a, b) =>
              compareStrings(a.name, b.name) ||
              compareStrings(a.declaration, b.declaration)
          )
          .map((f) => f.declaration),
      };
    }),
    null,
    2
  ) + "\n",
  "utf8"
);

// Validate spec files
const resolveSpec = (spec: Spec, functions: string[], visited: Set<string>) => {
  if (visited.has(spec.name)) {
    return;
  }
  visited.add(spec.name);
  functions.push(
    ...spec.functions.filter((funcName) => !functions.includes(funcName))
  );
  spec.extends.forEach((extendName) => {
    const extend = specMap.get(extendName);
    if (!extend) {
      errors.push(
        `Unknown module: '${extendName}' (referenced in '${spec.name}')`
      );
      return;
    }
    resolveSpec(extend, functions, visited);
  });
};
specs.forEach((spec) => {
  // Resolve inherited values
  const specFunctions: string[] = [];
  resolveSpec(spec, specFunctions, new Set());

  // Check module functions
  spec.modules.forEach((moduleName) => {
    const module = moduleMap.get(moduleName);
    if (!module) {
      errors.push(`Unknown module: '${moduleName}'`);
      return;
    }
    specFunctions.forEach((functionName) => {
      if (
        !module.functions.some((moduleFunc) => functionName == moduleFunc.name)
      ) {
        errors.push(`Missing function: ${module.name}.${functionName}()`);
      }
    });
  });
});

if (errors.length) {
  errors
    .filter((err, i) => !errors.slice(0, i).includes(err))
    .forEach((err) => {
      console.error(err);
    });
  process.exit(1);
}
