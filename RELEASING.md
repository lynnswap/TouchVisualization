# Releasing

Prepare a Draft Release with the approved version, title, notes, and full commit SHA. The **Release** workflow tests that commit using the same CI as pull requests, then publishes the same Draft Release. Failed checks leave it as a draft. The workflow preserves its title, notes, and prerelease status.

After fetching `main`, choose the version and confirm the commit and notes before running these commands:

```sh
git fetch origin main
release_tag="v0.1.0"
release_commit="$(git rev-parse origin/main)"

gh release create "$release_tag" \
    --repo lynnswap/TouchVisualization \
    --draft \
    --target "$release_commit" \
    --title "$release_tag" \
    --notes-file /path/to/release-notes.md

gh workflow run release.yml \
    --repo lynnswap/TouchVisualization \
    --ref main \
    -f tag="$release_tag" \
    -f commit="$release_commit"
```

Replace the example version and notes path with the approved values. Add `--prerelease` when creating a prerelease draft. To use the Actions UI instead, run **Release** from `main` and enter the draft's tag and approved commit SHA.

The workflow checks the release target again before publishing. An existing tag must point to the tested commit. A rerun of an already published release with the same commit performs no publication. If a check fails, fix the issue, update the draft to the newly approved commit if necessary, and run the workflow again with that SHA.

## Documentation deployment

The **DocC** workflow builds and deploys the documentation to GitHub Pages on pushes to `main`. It can also be run manually from `main`. The repository's Pages source must be **GitHub Actions**.
