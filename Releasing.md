# Releasing `motoko-core`

Steps to publish a new version of the `core` package:

1. In `mops.toml`, update the `version` field.
2. In `README.md`, update the version shown in the `mops.toml` code snippet (checked by CI).
3. In `Changelog.md`:
   * Update the `## Next` header to the new version, e.g. `## 1.2.3` (checked by CI).
   * Create an empty `## Next` section at the top of the file.
4. Open a PR with the above changes.
5. The CI workflow (`.github/workflows/release-tag.yml`) automatically creates and pushes a git tag when the PR is merged. No manual tagging is required.
6. Verify that the [`core` Mops package](https://mops.one/core) was published successfully after the tag is pushed.

## Re-running a failed publish

`mops-publish.yml` runs from the tagged commit, so re-running the failed run
re-uses the broken workflow file. Instead, fix the workflow on `main`, then
dispatch it from `main` with the existing tag as the `tag` input:

```bash
gh workflow run mops-publish.yml --ref main -f tag=v1.2.3
```

The workflow checks out the tag, so the published package is exactly the
tagged tree; only the workflow definition comes from `main`.
