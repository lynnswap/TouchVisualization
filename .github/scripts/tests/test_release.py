import importlib.util
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location("release", Path(__file__).parents[1] / "release.py")
release = importlib.util.module_from_spec(spec)
spec.loader.exec_module(release)

SHA = "a" * 40
OTHER_SHA = "b" * 40
DRAFT = {
    "id": 1,
    "tag_name": "v1.0.0",
    "target_commitish": SHA,
    "draft": True,
    "html_url": "https://github.com/example/package/releases/tag/v1.0.0",
}


class ReleaseTests(unittest.TestCase):
    def test_preparation_records_the_approved_commit_and_draft(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "output"
            with patch.dict(os.environ, {"GITHUB_OUTPUT": str(output)}):
                with patch.object(release, "gh", side_effect=[{"databaseId": 1}, DRAFT, [], {"sha": SHA}]) as gh:
                    release.run("prepare", "example/package", "v1.0.0", SHA)
            self.assertEqual(output.read_text(), f"commit={SHA}\nrelease_id=1\ndraft=true\n")
            self.assertFalse(any("PATCH" in call.args for call in gh.call_args_list))

    def test_a_moved_tag_prevents_publication(self):
        ref = {"ref": "refs/tags/v1.0.0", "object": {"type": "commit", "sha": OTHER_SHA}}
        with patch.object(release, "gh", side_effect=[DRAFT, [ref]]) as gh:
            with self.assertRaisesRegex(ValueError, "differs from approved commit"):
                release.run("publish", "example/package", "v1.0.0", SHA, "1")
            self.assertEqual(gh.call_count, 2)

    def test_a_changed_draft_target_prevents_publication(self):
        with patch.object(release, "gh", side_effect=[DRAFT, [], {"sha": OTHER_SHA}]) as gh:
            with self.assertRaisesRegex(ValueError, "differs from approved commit"):
                release.run("publish", "example/package", "v1.0.0", SHA, "1")
            self.assertEqual(gh.call_count, 3)

    def test_publication_preserves_release_content(self):
        published = DRAFT | {"draft": False}
        with patch.object(release, "gh", side_effect=[DRAFT, [], {"sha": SHA}, published]) as gh:
            release.run("publish", "example/package", "v1.0.0", SHA, "1")
            self.assertEqual(gh.call_args.args, (
                "api", "--method", "PATCH", "repos/example/package/releases/1",
                "--field", "draft=false", "--raw-field", f"target_commitish={SHA}",
            ))

    def test_an_already_published_release_is_not_modified(self):
        published = DRAFT | {"draft": False}
        ref = {"ref": "refs/tags/v1.0.0", "object": {"type": "commit", "sha": SHA}}
        with patch.object(release, "gh", side_effect=[published, [ref]]) as gh:
            release.run("publish", "example/package", "v1.0.0", SHA, "1")
            self.assertEqual(gh.call_count, 2)

    def test_annotated_tags_are_resolved_to_their_commit(self):
        ref = {"ref": "refs/tags/v1.0.0", "object": {"type": "tag", "sha": OTHER_SHA}}
        with patch.object(release, "gh", side_effect=[[ref], {"object": {"type": "commit", "sha": SHA}}]):
            self.assertEqual(release.tag_commit("example/package", "v1.0.0"), SHA)


if __name__ == "__main__":
    unittest.main()
