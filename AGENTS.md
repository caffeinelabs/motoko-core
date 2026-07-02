# AGENTS.md

`core` is the Motoko standard library, distributed as a Mops package.

## Setup

- Requires Node.js >= 22 (CI uses 24).
- First-time setup: `npm ci` then `npx mops toolchain init`.
- `npm ci` runs `mops install` via the `postinstall` script.
- The Motoko toolchain is pinned in `mops.toml` under `[toolchain]` (`moc`, `wasmtime`); do not change these casually.

## Build, test, lint, format

All commands are `package.json` scripts:

- Test everything: `npm test` (runs `test:ts` then `test:mops`).
- Motoko tests only: `npm run test:mops`. TypeScript tests only: `npm run test:ts`.
- Format Motoko files: `npm run format`. Check formatting: `npm run format:check`.
- Benchmarks: `npm run bench`.
- Validate (changelog, version, API): `npm run validate`.
- Generate docs: `npm run docs`.

Formatting uses Prettier with `prettier-plugin-motoko`; `.mo` files use 2-space indent, no semicolons, no trailing commas (`.prettierrc`).

## CI gotchas

- `format:check` must pass; run `npm run format` before committing.
- `validate:api` regenerates `validation/api/api.lock.json`. CI fails if it produces a diff: after any public API change run `npm run validate` and commit the result.
- When any `src/*.mo` file changes, `Changelog.md` must be updated in the same PR or the changelog check fails.
- When `src/*.mo` changes, `validate:docs` runs the doc-comment code examples for the changed files; keep examples working.
- `validate:version` enforces that the `mops.toml` version is consistent.

## Layout

- `src/` — library source; `src/internal/` holds private helpers, `src/pure/` holds the immutable/persistent collections.
- `test/` — Motoko tests (`*.test.mo`); `test/ts/` holds the TypeScript test runner and `test/ts/validate/` the validation scripts.
- `validation/` — API lockfile and JSON schemas used by validation; `validation/api/api.lock.json` is generated — never hand-edit it.
- `bench/` — Mops benchmarks.

## Conventions

- Generated/ignored: `docs/`, `.mops/`, `mops.lock`, `test/generated/`, `node_modules/` (see `.gitignore`); do not commit these.
- Public functions should carry a doc comment with a runnable `motoko` example (see `Styleguide.md`).
