"""Create an iPhone on the latest available iOS runtime for CI."""

import json
import os
from pathlib import Path
import subprocess


def simctl(*arguments):
    return subprocess.check_output(["xcrun", "simctl", *arguments], text=True)


runtimes = json.loads(simctl("list", "runtimes", "--json"))["runtimes"]
runtime = max(
    (runtime for runtime in runtimes
     if runtime["isAvailable"] and ".iOS-" in runtime["identifier"]),
    key=lambda runtime: tuple(map(int, runtime["version"].split("."))),
)
device_type = next(
    device for device in runtime["supportedDeviceTypes"]
    if device["productFamily"] == "iPhone"
)
udid = simctl("create", "TouchVisualization CI", device_type["identifier"], runtime["identifier"]).strip()
with Path(os.environ["GITHUB_ENV"]).open("a") as environment:
    environment.write(f"SIMULATOR_UDID={udid}\n")
print(f"Created {device_type['name']} on iOS {runtime['version']}: {udid}")
