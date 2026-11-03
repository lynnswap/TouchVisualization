"""Validate and publish an existing Draft Release at an approved commit."""

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
from urllib.parse import quote


def gh(*arguments):
    return json.loads(subprocess.check_output(["gh", *arguments], text=True))


def tag_commit(repository, tag):
    refs = gh("api", f"repos/{repository}/git/matching-refs/tags/{quote(tag, safe='')}")
    ref = next((ref for ref in refs if ref["ref"] == f"refs/tags/{tag}"), None)
    if ref is None:
        return None
    target = ref["object"]
    while target["type"] == "tag":
        target = gh("api", f"repos/{repository}/git/tags/{target['sha']}")["object"]
    return target["sha"]


def validate(repository, release, tag, commit, *, allow_missing_tag=False):
    if release["tag_name"] != tag:
        raise ValueError("The Draft Release tag changed after preparation.")
    actual_commit = tag_commit(repository, tag)
    existing_tag = actual_commit
    if actual_commit is None:
        if not allow_missing_tag:
            raise ValueError(f"Tag {tag} is missing; rerun release preparation.")
        ref = quote(release["target_commitish"], safe="")
        actual_commit = gh("api", f"repos/{repository}/commits/{ref}")["sha"]
    if actual_commit != commit:
        raise ValueError(f"Release target {actual_commit} differs from approved commit {commit}.")
    return existing_tag


def run(mode, repository, tag, commit, release_id=None):
    if not re.fullmatch(r"[0-9a-fA-F]{40}", commit):
        raise ValueError("TARGET_SHA must be a full commit SHA.")
    commit = commit.lower()
    if mode == "prepare":
        # The REST tag endpoint only finds published releases; gh also finds drafts.
        metadata = gh("release", "view", "--repo", repository, "--json", "databaseId", "--", tag)
        release_id = metadata["databaseId"]
    release = gh("api", f"repos/{repository}/releases/{release_id}")
    existing_tag = validate(repository, release, tag, commit, allow_missing_tag=mode == "prepare")

    if mode == "prepare":
        if existing_tag is None:
            try:
                gh("api", "--method", "POST", f"repos/{repository}/git/refs",
                   "--raw-field", f"ref=refs/tags/{tag}", "--raw-field", f"sha={commit}")
            except subprocess.CalledProcessError:
                # A concurrent preparation may already have created the same tag.
                if tag_commit(repository, tag) != commit:
                    raise
            validate(repository, release, tag, commit)
        with Path(os.environ["GITHUB_OUTPUT"]).open("a") as output:
            output.write(f"commit={commit}\nrelease_id={release['id']}\ndraft={str(release['draft']).lower()}\n")
    elif release["draft"]:
        # Keep the approved title, notes, and prerelease status on the same release.
        release = gh(
            "api", "--method", "PATCH", f"repos/{repository}/releases/{release['id']}",
            "--field", "draft=false", "--raw-field", f"target_commitish={commit}",
        )
    print(f"{'Draft' if release['draft'] else 'Published'} release: {release['html_url']}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=["prepare", "publish"])
    arguments = parser.parse_args()
    run(
        arguments.mode,
        os.environ["GH_REPO"],
        os.environ["RELEASE_TAG"],
        os.environ["TARGET_SHA"],
        os.environ.get("RELEASE_ID"),
    )
