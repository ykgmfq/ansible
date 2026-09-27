#!/usr/bin/env python3
"""Syntax-check nftables templates with `nft -c`."""
import os
import subprocess
import sys
from pathlib import Path

import jinja2
import yaml

ROOT = Path(__file__).resolve().parents[2]
GROUP_VARS = ROOT / "group_vars/router/main.yml"


def load(path):
    return yaml.safe_load(path.read_text()) or {} if path.exists() else {}


def main():
    env = jinja2.Environment(undefined=jinja2.StrictUndefined)
    # Unprivileged `nft -c` still needs CAP_NET_ADMIN, so check inside a throwaway netns.
    nft = ["nft", "-c", "-f", "-"] if os.geteuid() == 0 else ["unshare", "-rn", "nft", "-c", "-f", "-"]
    failed = False
    for template in sorted(ROOT.glob("roles/*/templates/*.nft")):
        role = template.parent.parent
        context = {**load(role / "defaults/main.yml"), **load(GROUP_VARS)}
        rules = env.from_string(template.read_text()).render(context)
        # Snippets are included at chain level (fw4 chain-pre), so wrap them in a chain.
        ruleset = f"table inet nft_lint {{\nchain c {{\n{rules}\n}}\n}}\n"
        result = subprocess.run(nft, input=ruleset, capture_output=True, text=True, check=False)
        if result.returncode != 0:
            failed = True
            print(f"{template.relative_to(ROOT)}:\n{result.stderr}", file=sys.stderr)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
