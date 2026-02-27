# `core`

* 📦 [Mops Package](https://mops.one/core)
* ✨ [Documentation](https://internetcomputer.org/docs/motoko/core)

---

The `core` package is the official standard library for the [Motoko](https://github.com/dfinity/motoko) programming language. 

This replaces the original `base` library, which is available [here](https://github.com/dfinity/motoko-base). 

An official [migration guide](https://internetcomputer.org/docs/motoko/base-core-migration) is available for upgrading projects from `base` to `core`.

## Quick Start

1. Install the [Mops](https://docs.mops.one/quick-start) package manager
2. Open a terminal in your project directory
3. Run `mops add core`

This adds the following dependency to your `mops.toml` config file:

```toml
[dependencies]
core = "2.1.0"
```

## Contributing

This repository is currently closed to external contributions. Please feel free to report a bug, ask a question, or request a feature on the project's [GitHub issues](https://github.com/dfinity/motoko-core/issues) page.

Interface design and code style guidelines for the repository can be found [here](https://github.com/dfinity/motoko-core/blob/main/Styleguide.md).

### Dev Environment

> Make sure that [Node.js](https://nodejs.org/en/) `>= 22.x` is installed on your system.

Run the following commands to configure your local development branch:

```sh
# First-time setup
git clone https://github.com/dfinity/motoko-core
cd motoko-core
npm ci
npx ic-mops toolchain init
```

Below is a quick reference for commonly-used scripts during development:

```sh
npm test # Run all tests
npm run format # Format Motoko files
npm run validate:api # Update the public API lockfile
npm run validate:docs Array # Run code snippets in `src/Array.mo`
```

All available scripts can be found in the project's [`package.json`](https://github.com/dfinity/motoko-core/blob/main/package.json) file.

### Major Contributors

Big thanks to the following community contributors:

* [MR Research AG (A. Stepanov, T. Hanke)](https://github.com/research-ag): [`vector`](https://github.com/research-ag/vector), [`prng`](https://github.com/research-ag/prng)
* [Byron Becker](https://github.com/ByronBecker): [`StableHeapBTreeMap`](https://github.com/canscale/StableHeapBTreeMap)
* [Zen Voich](https://github.com/ZenVoich): [`test`](https://github.com/ZenVoich/test)
