#!/usr/bin/python3
import subprocess

import questionary

periods = {"stündlich": "hourly", "täglich": "daily", "monatlich": "monthly"}

# -H: keinen Header ausgeben
# -o name: nur name des Datensatzes ausgeben
datasets = subprocess.check_output(
    ["/usr/sbin/zfs", "list", "-H", "-o", "name"], universal_newlines=True
).splitlines()
if not datasets:
    raise ValueError("Keine Datensätze verfügbar!")

# Datensatz auswählen und Schnappschüsse holen
ds = questionary.select(
    "Welcher datensatz soll zurückgesetzt werden?", choices=datasets
).ask()
# -S creation: Sortierung nach Erstellungsdatum, neueste zuerst
# -t snapshot: Ziel Snapshots
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

# Kandidaten für Rücksetzung ermitteln, nur erste zehn
period = periods.get(
    questionary.select(
        "Häufigkeit des Zielschnappschusses?", choices=periods.keys()
    ).ask()
)
candidates = [c for c in snaps if period in c][:10]
if not candidates:
    raise ValueError("Keine Kandidaten verfügbar!")

# Schnappschuss für Rücksetzung setzen
snap = questionary.select(
    "Welcher snapshot soll zurückgesetzt werden?", choices=candidates
).ask()

# Rücksetzung ausführen
if questionary.confirm(
    "Auf Stand zurücksetzen?", auto_enter=False, default=False
).ask():
    # -r: rekursiv, roll auch mittlere Schnappschüsse zurück
    zfs_rollback = subprocess.run(
        ["/usr/sbin/zfs", "rollback", "-r", snap],
        capture_output=True,
        universal_newlines=True,
        check=True,
    )
    print("Datensatz zurückgesetzt.")
else:
    print("Abgebrochen.")
