# AGENTS.md

`core` is the Motoko standard library, published as the Mops package `core`.

## Setup

- Requires Node.js `>= 22` (CI uses Node 24).
- Install dependencies: `npm ci` (the `postinstall` script runs `mops install`).
- Initialize the Motoko toolchain before building/testing: `npx mops toolchain init`.
- Pinned tool versions live in `mops.toml` under `[toolchain]` (`moc`, `wasmtime`, `pocket-ic`).

## Build, test, lint, format

All commands are `package.json` scripts run with `npm run <name>` (or `npm test`):

- `npm test` — runs `test:ts` (`tsx` suite under `test/ts`) then `test:mops` (`mops test`).
- `npm run bench` — runs `mops bench`.
- `npm run check:orphans` — type-checks modules not covered by tests.
- `npm run format` — format all `*.mo` files with Prettier; `npm run format:check` verifies formatting (CI fails if unformatted).
- `npm run validate` — runs `validate:changelog`, `validate:version`, `validate:api`.
- `npm run validate:api` — regenerates `validation/api/api.lock.json`.
- `npm run validate:docs -- src/Foo.mo` — runs doc-comment code examples for the given file(s).

## CI gotchas

- `validation/api/api.lock.json` is generated. After changing a public API, run `npm run validate` and commit the result, or the `validate-api` job fails on the diff.
- Editing any `src/*.mo` requires a matching `Changelog.md` update, or the changelog check fails.
- The `version` field in `mops.toml` is validated against release state (`validate:version`).
- Formatting follows `.prettierrc` (`*.mo`: 2-space indent, no semicolons, no trailing commas).

## Layout

- `src/` — library modules (top-level = mutable structures; `src/pure/` = immutable variants).
- `src/internal/` — implementation helpers, not part of the public API.
- `test/` — Motoko tests (`*.test.mo`); `test/ts/` holds the TypeScript test/validation harness; `test/pure/` mirrors `src/pure`.
- `bench/` — `mops` benchmarks (`*.bench.mo`).
- `validation/` — API lockfile and schemas used by the validate scripts.

## Conventions

- Interface and code-style rules are in `Styleguide.md`; every public function needs a doc comment with a runnable example, and public types are defined in `src/Types.mo`.
- Generated/ignored paths (`.mops`, `mops.lock`, `docs`, `test/generated`, `_build`) must not be hand-edited.
