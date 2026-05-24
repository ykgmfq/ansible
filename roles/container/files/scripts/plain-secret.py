#!/usr/bin/env python3
"""Create a podman secret from the first stringData entry of a Kubernetes Secret YAML."""

import argparse
import subprocess
from pathlib import Path

import yaml

parser = argparse.ArgumentParser(
    description="Create a podman secret from a Kubernetes Secret YAML file. "
    "Extracts the first stringData value and creates a plain podman secret."
)
parser.add_argument("file", type=Path, help="Kubernetes Secret YAML file")
parser.add_argument(
    "--suffix", default="_plain", help="suffix appended to the secret name (default: _plain)"
)
args = parser.parse_args()

doc = yaml.safe_load(args.file.read_text())

name = doc["metadata"]["name"]
value = next(iter(doc["stringData"].values()))
secret_name = f"{name}{args.suffix}"

subprocess.run(
    ["podman", "secret", "create", "--replace", secret_name, "-"],
    input=value.encode(),
    check=True,
)
print(f"Created secret: {secret_name}")
