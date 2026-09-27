#!/usr/bin/env python3
"""Syntax-check nftables templates with `nft -c`."""
import os
import subprocess
import sys
from pathlib import Path
from typing import Literal

import jinja2
import yaml

ROOT = Path(__file__).resolve().parents[2]
GROUP_VARS = ROOT / "group_vars/router/main.yml"


def load(path) -> dict:
    """Return a YAML file's contents, or an empty dict if it doesn't exist."""
    if not path.exists():
        return {}
    data = yaml.safe_load(path.read_text())
    return {} if data is None else data


def render(template) -> str:
    """Render a template into a standalone ruleset."""
    role = template.parent.parent
    context = {**load(role / "defaults/main.yml"), **load(GROUP_VARS)}
    env = jinja2.Environment(undefined=jinja2.StrictUndefined)
    rules = env.from_string(template.read_text()).render(context)
    # Snippets are included at chain level (fw4 chain-pre), so wrap them in a chain.
    return f"table inet nft_lint {{\nchain c {{\n{rules}\n}}\n}}\n"


def check(ruleset) -> str | None:
    """Return nft's error output for an invalid ruleset, or None."""
    # Unprivileged `nft -c` still needs CAP_NET_ADMIN, so check inside a throwaway netns.
    nft = ["nft", "-c", "-f", "-"] if os.geteuid() == 0 else ["unshare", "-rn", "nft", "-c", "-f", "-"]
    result = subprocess.run(nft, input=ruleset, capture_output=True, text=True, check=False)
    if result.returncode == 0:
        return
    return result.stderr


def main() -> Literal[1] | Literal[0]:
    """Render all templates, then check each; return the exit code."""
    rendered = {template: render(template) for template in sorted(ROOT.glob("roles/*/templates/*.nft"))}
    failed = False
    for template, ruleset in rendered.items():
        error = check(ruleset)
        if error is None:
            continue
        failed = True
        print(f"{template.relative_to(ROOT)}:\n{error}", file=sys.stderr)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
