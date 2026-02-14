# Release process

Please refer to the [release instructions](https://github.com/dfinity/motoko/blob/master/Building.md#making-releases) in the Motoko repository.

## The `next-moc` branch

The `next-moc` branch contains changes that make base compatible with the
in-development version of `moc`. This repository's public CI does _not_ run
on that branch.

External contributions are best made against `main`.

- `main` branch is meant for the newest **released** version of `moc`
  - The CI runs on this branch
- `next-moc` branch is meant for the **in-development** version of `moc`
  - This branch is used by the [`motoko` repository](https://github.com/dfinity/motoko)'s CI

Both branches are kept in sync with each other by mutual, circular merges:
- `next-moc` is updated automatically on each push to `main` via the [sync.yml](.github/workflows/sync.yml) workflow
- `main` is updated **manually** on each release of `moc` as part of the `motoko` release process

Only *normal* merges are allowed between `main` and `next-moc`, because development is permitted on both branches.
This policy makes every PR (to either branch) visible in the history of both branches.