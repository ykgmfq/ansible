#!/usr/bin/python3
import subprocess
import questionary
import sys
from pathlib import Path

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

# Rücksetzung der Datenbank
# -o value: nur Wert der Abfrage ausgeben
mountpoint = subprocess.check_output(
    ["/usr/sbin/zfs", "get", "mountpoint", "-H", "-o", "value", ds],
    universal_newlines=True,
).strip()
db = Path(ds).name
pg = Path(mountpoint) / f"pgdump_{db}"
if pg.exists():
    print(f"Backup von PG-Datenbank gefunden: {pg}")
    restore_db = questionary.confirm("Datenbank im Anschluss zurücksetzen?").ask()

# Rücksetzung ausführen
if questionary.confirm(
    "Auf Stand zurücksetzen?", auto_enter=False, default=False
).ask():
	# -r: rekursiv, roll auch mittlere Schnappschüsse zurück
    zfs_rollback = subprocess.run(
        ["/usr/sbin/zfs", "rollback", "-r", snap],
        capture_output=True,
        universal_newlines=True,
    )
    if zfs_rollback.returncode == 0:
        print("Datensatz zurückgesetzt.")
        if restore_db:
            # --clean: entfernt alle vorhandenen Objekte
            pg_restore = subprocess.run(
                [
                    "/usr/bin/pg_restore",
                    "--clean",
                    "--single-transaction",
                    "-d",
                    db,
                    pg,
                ],
                capture_output=True,
                universal_newlines=True,
            )
            if pg_restore.returncode == 0:
                print("Datenbank zurückgesetzt.")
            else:
                print(
                    f"Fehler in pg_restore:\n{pg_restore.stderr}\n🔥 ACHTUNG! Datenbank und ZFS-Datensatz nicht passend! 🔥"
                )
                sys.exit(1)
    else:
        print(f"Fehler in ZFS Rollback:\n{zfs_rollback.stdout}")
        sys.exit(1)
    print("Abgeschlossen.")
else:
    print("Abgebrochen.")
