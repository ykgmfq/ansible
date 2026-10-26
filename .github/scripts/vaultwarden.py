"""Read Vaultwarden entries via rbw."""
import json
import subprocess


def rbw(*args) -> list | dict:
    """Run rbw and return its parsed JSON output."""
    return json.loads(subprocess.run(["rbw", *args], check=True, capture_output=True, text=True).stdout)


def entry(*args) -> dict:
    """Return an entry's password and custom fields."""
    raw = rbw("get", "--raw", *args)
    return {"password": raw["data"].get("password"), **{f["name"]: f["value"] for f in raw.get("fields", [])}}


def entries(name) -> list[tuple[str, dict]]:
    """Return (device, entry) for every entry with this name, matched case-insensitively."""
    return [
        (listed.get("user") or listed["id"], entry(listed["id"]))
        for listed in rbw("list", "--raw")
        if listed["name"].lower() == name.lower()
    ]


def missing(label, values, required) -> str | None:
    """Return an error naming the required keys that are empty in values, or None."""
    absent = [key for key in required if not values.get(key)]
    return f"{label}: missing {', '.join(absent)}" if absent else None
