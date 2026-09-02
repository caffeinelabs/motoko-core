# AGENTS.md

`core` is the Motoko standard library, distributed as the Mops package `core`.

## Setup

- Requires Node.js 24 (CI uses `node-version: 24`).
- Run `npm ci`. The `postinstall` script runs `mops install`, which fetches Motoko dependencies and the pinned toolchain declared in `mops.toml`.
- The Motoko toolchain versions (`moc`, `wasmtime`, `pocket-ic`) are pinned under `[toolchain]` in `mops.toml`; do not assume system-installed versions.

## Build, test, lint, format

Use the `package.json` scripts:

- `npm test` — full test suite (`test:ts` then `test:mops`).
- `npm run test:mops` — Motoko unit tests via `mops test`.
- `npm run test:ts` — TypeScript integration tests (`test/ts`).
- `npm run bench` — benchmarks (`mops bench`); run in CI as `check:bench`.
- `npm run check:orphans` — type-checks Motoko modules not otherwise imported.
- `npm run format:check` — Prettier check on `*.mo` files. `npm run format` rewrites them.
- `npm run validate` — runs `validate:changelog`, `validate:version`, `validate:api`.
- `npm run validate:docs [Module ...]` — runs doc-comment code examples for the named `src/*.mo` modules (or all when no argument).

Formatting is enforced by the `prettier-plugin-motoko` plugin with the `*.mo` overrides in `.prettierrc` (2-space indent, no semicolons, no trailing commas).

## Layout

- `src/` — library modules; `src/internal/` is private helpers, `src/pure/` is the immutable/persistent variants.
- `test/` — Motoko tests (`*.test.mo`); `test/ts/` holds TypeScript tests and the `test/ts/validate/` validation scripts.
- `bench/` — benchmarks (`*.bench.mo`).
- `validation/` — checked-in fixtures, including the public API lockfile `validation/api/api.lock.json`.

## Consistency

- Same-name functions are defined on all modules where they make sense (e.g. `values` on every data structure).
- Same-name functions return consistent types: either both trap on a failing case, or both return a safe option (`?T`).
- Same-name functions take the same arguments, in the same places, with the same names.

These are the target convention, not a description of the current state — divergences exist in the codebase today.

Concrete checks:
- Every collection module provides `size` and `isEmpty`.
- `get` is a safe-optional lookup (`?T`/`?V`) that never traps; a trapping indexed access is a separate name (`at`) or native `[]`.
- Head and removal reads (`first`/`peek`/`pop`/`last`) return optionals, never trap on empty.
- A mutating-named operation returns the updated structure in `src/pure/` (`Map.add` returns the new `Map`), but `()` or a flag in the matching `src/` module.
- `fromIter`/`fromArray`/`toArray` conversions exist broadly; ordered modules (Map, Set, PriorityQueue) take `compare` as the last argument.
- User-supplied equality/ordering/rendering are trailing `implicit` arguments named `equal`/`compare`/`toText` (`compare` returns an `Order`); callers pass module functions like `Nat.compare`.
- Failure-implying names trap (`unwrap`/`assert*`); `get`-style total lookups never do.
- Boundary constants are `minValue`/`maxValue` literals (no `bitSize`); sized-unsigned modules define only `maxValue`.

## Conventions and CI gotchas

- The public API is locked in `validation/api/api.lock.json`. CI fails if `npm run validate:api` produces a diff; regenerate with `npm run validate` and commit the result when the public API changes intentionally.
- CI requires `Changelog.md` to be updated when any `src/*.mo` file changes (advisory) — keep it current.
- `npm run validate:version` cross-checks the version; the `version` in `mops.toml` is the source of truth (`package.json` version is `0.0.0`).
- Every public function should carry a doc comment with a runnable example, since `validate:docs` executes them (see `Styleguide.md`).
- Follow `Styleguide.md` for interface and code-style conventions.
- Generated/local directories are git-ignored and must not be committed: `.mops/`, `docs/`, `test/generated/`, `_build/`, `_out/`.
- `.npmrc` sets `min-release-age=7`; newly published dependency versions younger than 7 days are not installed.
