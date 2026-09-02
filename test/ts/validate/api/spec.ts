import { existsSync, readdirSync, readFileSync, writeFileSync } from "fs";
import { join } from "path";
import { Parser, Language, Node } from "web-tree-sitter";

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

async function createParser(): Promise<Parser> {
  await Parser.init();
  const language = await Language.load(
    require.resolve("tree-sitter-motoko/tree-sitter-motoko.wasm")
  );
  const parser = new Parser();
  parser.setLanguage(language);
  return parser;
}

function readModules(parser: Parser, dir: string, subdir: string = "") {
  readdirSync(join(dir, subdir), { withFileTypes: true }).forEach((entry) => {
    const subPath = join(subdir, entry.name);
    const fullPath = join(dir, subPath);
    if (entry.isDirectory()) {
      // Internal modules are published but not part of the usable API
      if (subPath.replace(/\\/g, "/") !== "internal") {
        readModules(parser, dir, subPath);
      }
    } else if (entry.isFile() && entry.name.endsWith(".mo")) {
      // Use forward slashes regardless of platform
      const name = subPath.replace(/\\/g, "/").replace(/\.mo$/, "");
      const modules = parseModules(parser, name, readFileSync(fullPath, "utf8"));
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

// Signature parts of a declaration node; anything after them (a body or
// value) is excluded from the lockfile entry
const headerNodeTypes = new Set([
  "identifier",
  "type_identifier",
  "typ_params",
  "tup_pat",
  "par_pat",
  "annot_pat",
  "var_pat",
  "wild_pat",
  "typ_annot",
]);

// Extract public declarations from a parsed Motoko file, including from
// nested public modules/classes (emitted as dotted submodules)
function parseModules(
  parser: Parser,
  fileName: string,
  source: string
): Module[] {
  const tree = parser.parse(source);
  const error = (node: Node, message: string): never => {
    throw new Error(
      `${fileName}.mo:${node.startPosition.row + 1}: ${message}`
    );
  };

  const findError = (node: Node): Node | null => {
    if (node.type === "ERROR" || node.isMissing) return node;
    if (!node.hasError) return null;
    for (const child of node.children) {
      const found = child && findError(child);
      if (found) return found;
    }
    return null;
  };
  const errorNode = findError(tree.rootNode);
  if (errorNode) {
    error(errorNode, `Parse error near '${errorNode.text.slice(0, 40)}'`);
  }

  const moduleDec = tree.rootNode.namedChildren.find(
    (child) => child?.type === "obj_dec" && child.child(0)?.type === "module"
  );
  if (!moduleDec) {
    throw new Error(`${fileName}.mo: No top-level module declaration found`);
  }

  const modules: Module[] = [];

  // The name and signature end of a declaration node; type declarations
  // extend through `=` so that the aliased type shape is locked as well
  const declarationParts = (dec: Node) => {
    const named = dec.namedChildren.filter((c): c is Node => !!c);
    const nameNode = named.find(
      (c) => c.type === "identifier" || c.type === "type_identifier"
    );
    switch (dec.type) {
      case "typ_dec":
        return { kind: "type", nameNode, end: dec.endIndex };
      case "let_dec":
      case "var_dec": {
        const pattern = named[0];
        return {
          kind: dec.type === "let_dec" ? "let" : "var",
          nameNode: pattern.type === "var_pat" ? pattern : pattern.namedChild(0),
          end: pattern.endIndex,
        };
      }
      case "func_dec":
      case "class_dec": {
        let end = -1;
        for (const child of named) {
          if (!headerNodeTypes.has(child.type)) break;
          end = child.endIndex;
        }
        return {
          kind: dec.type === "func_dec" ? "func" : "class",
          nameNode,
          end,
        };
      }
      case "obj_dec":
        return {
          kind: dec.child(0)?.type ?? "",
          nameNode,
          end: nameNode ? nameNode.endIndex : -1,
        };
      default:
        return { kind: dec.type, nameNode, end: -1 };
    }
  };

  const scanBody = (body: Node, path: string) => {
    const functions: Func[] = [];
    modules.push({
      name: path ? `${fileName}.${path}` : fileName,
      functions,
    });
    for (const field of body.namedChildren) {
      if (field?.type !== "dec_field" || field.child(0)?.type !== "public") {
        continue;
      }
      const dec = field.namedChildren.find((c) => c?.type.endsWith("_dec"));
      if (!dec) {
        error(field, `Unrecognized public declaration: ${field.text.slice(0, 40)}`);
      }
      const { kind, nameNode, end } = declarationParts(dec);
      if (!["func", "let", "var", "type", "class", "module", "object"].includes(kind)) {
        error(dec, `Unsupported public declaration kind: '${kind}'`);
      }
      if (!nameNode) {
        error(dec, `Missing name in public ${kind} declaration`);
      }
      if (end < 0) {
        error(dec, `Unable to determine signature of public ${kind} declaration`);
      }
      const name = nameNode.text;
      const declaration =
        (kind === "let" && functionTypedLet(dec, name, source)) ||
        source.slice(dec.startIndex, end);
      functions.push({
        name,
        declaration: formatDeclaration(declaration, () =>
          error(dec, `Malformed public declaration: ${declaration}`)
        ),
      });
      if (kind === "module" || kind === "object" || kind === "class") {
        const childBody = dec.namedChildren.find(
          (c) => c?.type === "obj_body"
        );
        if (childBody) {
          scanBody(childBody, path ? `${path}.${name}` : name);
        }
      }
    }
  };

  const rootBody = moduleDec.namedChildren.find(
    (c) => c?.type === "obj_body"
  );
  if (!rootBody) {
    throw new Error(`${fileName}.mo: Top-level module has no body`);
  }
  scanBody(rootBody, "");
  return modules;
}

// Rewrite a function-typed `let` binding (used as an inlining optimization)
// in ordinary `func` syntax: `let name : <T>(args) -> Ret` becomes
// `func name<T>(args) : Ret`. Returns null for non-function types.
function functionTypedLet(
  dec: Node,
  name: string,
  source: string
): string | null {
  const pattern = dec.namedChild(0);
  if (pattern?.type !== "annot_pat") return null;
  const annot = pattern.namedChildren.find((c) => c?.type === "typ_annot");
  const type = annot?.namedChild(0);
  if (type?.type !== "func_typ") return null;
  const parts = type.namedChildren.filter((c): c is Node => !!c);
  const typeParams = parts[0]?.type === "typ_params" ? parts[0] : null;
  const domain = typeParams ? parts[1] : parts[0];
  const codomain = parts[parts.length - 1];
  if (!domain || !codomain || domain === codomain) return null;
  // Leading modifiers such as `shared`
  const modifiers = source.slice(
    type.startIndex,
    (typeParams ?? domain).startIndex
  );
  const params = domain.type === "tup_typ" ? domain.text : `(${domain.text})`;
  return `${modifiers}func ${name}${
    typeParams ? typeParams.text : ""
  }${params} : ${codomain.text}`;
}

// Normalize a declaration for the lockfile
function formatDeclaration(declaration: string, malformed: () => never): string {
  const result = declaration
    .replace(/\s+/g, " ")
    .replace(/([(<[])\s+/g, "$1")
    .replace(/\s+([)>\],])/g, "$1")
    .trim();
  if (!result || result.endsWith(":") || result.endsWith("=")) {
    malformed();
  }
  return result;
}

async function main() {
  if (!existsSync(srcDir)) {
    throw new Error(`Directory "${srcDir}" does not exist.`);
  }

  const errors: string[] = [];

  // Read module files
  const parser = await createParser();
  readModules(parser, srcDir);

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
  const resolveSpec = (
    spec: Spec,
    functions: string[],
    visited: Set<string>
  ) => {
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
          !module.functions.some(
            (moduleFunc) => functionName == moduleFunc.name
          )
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
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
