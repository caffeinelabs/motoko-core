# AGENTS.md

`core` is the Motoko standard library, distributed as the Mops package `core`.

## Setup

- Requires Node.js 24 (CI uses `node-version: 24`).
- Run `npm ci`. The `postinstall` script runs `mops install`, which fetches Motoko dependencies and the pinned toolchain declared in `mops.toml`.
- The Motoko toolchain versions (`moc`, `wasmtime`, `pocket-ic`) are pinned under `[toolchain]` in `mops.toml`; do not assume system-installed versions. `[requirements] moc` is a minimum floor; `[toolchain] moc` is what CI pins and runs on.

## Build, test, lint, format

Use the `package.json` scripts:

- `npm test` — full test suite (`test:ts` then `test:mops`).
- `npm run test:mops` — Motoko unit tests via `mops test`.
- `npm run test:ts` — TypeScript integration tests (`test/ts`).
- `npm run bench` — benchmarks (`mops bench`); run in CI by the `bench` job.
- `npm run check:orphans` — type-checks Motoko modules not otherwise imported.
- `npm run format:check` — Prettier check on `*.mo` files. `npm run format` rewrites them.
- `npm run validate` — runs `validate:changelog`, `validate:version`, `validate:api`.
- `npm run validate:docs [Module ...]` — runs doc-comment code examples for the named `src/*.mo` modules (or all when no argument).
- `npm run docs` — generates `docs/` via mo-doc (run manually; there is no CI pages deploy).
- `npm run check:mo` — runs `test:mops`, `bench`, and `check:orphans` together.

Formatting is enforced by the `prettier-plugin-motoko` plugin with the `*.mo` overrides in `.prettierrc` (2-space indent, no semicolons, no trailing commas).

## Layout

- `src/` — library modules; `src/internal/` is private helpers, `src/pure/` is the immutable/persistent variants.
- `test/` — Motoko tests (`*.test.mo`); `test/ts/` holds TypeScript tests and the `test/ts/validate/` validation scripts.
- `bench/` — benchmarks (`*.bench.mo`).
- `validation/` — checked-in fixtures, including the public API lockfile `validation/api/api.lock.json`.

## Interface conventions

- Prefer `toX` with `self` as first parameter over `fromX`; `fromX` may exist for legacy reasons but must never take the `self` parameter (exception: legacy preexisting functions).
- Every context-dot function whose first parameter is `self` must type it as the module's own type, e.g. `toX(self : Nat) : X` belongs in `Nat.mo`. CI-enforced; escape hatch is a `// ignore-self-type-check` comment.
- Every data-structure/primitive module provides `equal`, `compare`, `toText`; `compare` returns `Types.Order`.
- Public modules open with a one-line purpose, then a `/// ```motoko name=import``` snippet preceded by "Import from the core package to use this module." (see `src/Nat.mo`).
- Data-structure functions document asymptotic cost as `Runtime: O(...)` and `Space: O(...)` lines at the end of the doc comment.

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
- CI requires `Changelog.md` to be updated when any `src/*.mo` file changes — advisory in `tests.yml` (warns only), mandatory on a release PR where `release-tag.yml` blocks the tag if it does not match the bumped version.
- `npm run validate:version` cross-checks the version; the `version` in `mops.toml` is the source of truth (`package.json` version is `0.0.0`).
- See `Releasing.md` for the release steps (version bump, changelog, tag, publish).
- Every public function should carry a doc comment with a runnable example, since `validate:docs` executes them (see `Styleguide.md`).
- Follow `Styleguide.md` for interface and code-style conventions.
- Generated/local directories are git-ignored and must not be committed: `.mops/`, `docs/`, `test/generated/`, `_build/`, `_out/`.
- `.npmrc` sets `min-release-age=7`; newly published dependency versions younger than 7 days are not installed.
- `mops.toml` sets `[moc] args = ["-E=M0154,M0223"]`, demoting those two unused-identifier errors to warnings.
- `tests.yml` gates all jobs on one required aggregate job `ci:required` (most jobs are conditional; a skipped job would otherwise satisfy its required check). `test` and `bench` run only on `.mo`/mops/tooling changes.
- The `test` job also runs one Motoko test under legacy persistence: `npx ic-mops test List.allocation -- --legacy-persistence`.
