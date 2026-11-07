#!/usr/bin/python3
import subprocess

import questionary

periods = {"stündlich": "hourly", "täglich": "daily", "monatlich": "monthly"}
datasets = subprocess.check_output(
    ["/usr/sbin/zfs", "list", "-H", "-o", "name"], universal_newlines=True
).splitlines()
if not datasets:
    raise ValueError("Keine Datensätze verfügbar!")
ds = questionary.select(
    "Welcher datensatz soll zurückgesetzt werden?", choices=datasets
).ask()
snaps = subprocess.check_output(
    [
        "/usr/sbin/zfs",
        "list",
        "-H",
        "-o",
        "name",
        "-S",
        "creation",
        "-t",
        "snapshot",
        ds,
    ],
    universal_newlines=True,
).splitlines()
if not snaps:
    raise ValueError("Keine Schnappschüsse verfügbar!")
period = periods.get(
    questionary.select(
        "Häufigkeit des Zielschnappschusses?", choices=periods.keys()
    ).ask()
)
candidates = [c for c in snaps if period in c][:10]
if not candidates:
    raise ValueError("Keine Kandidaten verfügbar!")
snap = questionary.select(
    "Welcher snapshot soll zurückgesetzt werden?", choices=candidates
).ask()
if questionary.confirm(
    "Auf Stand zurücksetzen?", auto_enter=False, default=False
).ask():
    zfs_rollback = subprocess.run(
        ["/usr/sbin/zfs", "rollback", "-r", snap],
        capture_output=True,
        universal_newlines=True,
        check=True,
    )
    print("Datensatz zurückgesetzt.")
else:
    print("Abgebrochen.")
