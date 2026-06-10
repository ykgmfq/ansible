#!/usr/bin/env python3
import argparse
import shutil
import subprocess
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="pgupgrade.py",
        description="Upgrade a PostgreSQL container service to a new major version using podman and ZFS snapshots.",
    )
    parser.add_argument("svc", help="systemd service name (also used to locate the data dir under /var/mnt/persist/<svc>/db)")
    parser.add_argument("target_major", help="target PostgreSQL major version (e.g. 17)")
    parser.add_argument("--just-dump", action="store_true", help="stop after writing the SQL dump, skip bootstrap")
    return parser.parse_args()


def main():
    args = parse_args()

    if not args.target_major.isdigit():
        print("❌ target_pg_major must be numeric (e.g. 18)")
        sys.exit(2)

    datadir = Path(f"/var/mnt/persist/{args.svc}/db")
    backup = Path("/tmp/backup.sql")
    log_path = Path("/tmp/pgupgrade.log")
    pg_version_file = datadir / "PG_VERSION"

    if not pg_version_file.exists():
        print(f"❌ Cannot find PG_VERSION at {pg_version_file}")
        print("Is the data directory correct?")
        sys.exit(1)

    current_major = pg_version_file.read_text().strip()
    if not current_major.isdigit():
        print(f"❌ Invalid PG_VERSION content: {current_major}")
        sys.exit(1)

    if current_major == args.target_major:
        print(f"❌ Current and target major versions are both {current_major}, nothing to do")
        sys.exit(0)

    print(f"▶ Service:          {args.svc}")
    print(f"▶ Current PG major: {current_major}")
    print(f"▶ Target PG major:  {args.target_major}")
    print(f"▶ Data dir:         {datadir}")
    print(f"▶ Backup file:      {backup}")
    print(f"▶ Log file:         {log_path}")

    print(f"⏹ Stopping service: {args.svc}")
    with log_path.open("w") as log:
        r = subprocess.run(["systemctl", "stop", args.svc], capture_output=True, text=True)
        if r.returncode != 0:
            log.write(r.stdout)
            log.write(r.stderr)
            raise subprocess.CalledProcessError(r.returncode, r.args)

        snapshot = f"data/persist/{args.svc}/db@pre-pg-upgrade"

        def rollback():
            print(f"⏪ Rolling back to snapshot {snapshot}")
            subprocess.run(["zfs", "rollback", snapshot], stdout=log, stderr=subprocess.STDOUT)
            print(f"▶ Restart service with: systemctl start {args.svc}")

        if subprocess.run(["zfs", "list", "-t", "snapshot", snapshot], capture_output=True).returncode == 0:
            subprocess.run(["zfs", "destroy", snapshot], check=True, stdout=log, stderr=subprocess.STDOUT)
        subprocess.run(["zfs", "snapshot", snapshot], check=True, stdout=log, stderr=subprocess.STDOUT)

        print(f"📦 Extracting SQL backup from PostgreSQL {current_major}")
        dump_script = (
            "docker-entrypoint.sh postgres >&2 &\n"
            "until pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done\n"
            "pg_dumpall -U postgres\n"
        )
        with backup.open("w") as f:
            result = subprocess.run(
                [
                    "podman", "run", "--rm",
                    "-v", f"{datadir}:/var/lib/postgresql/data:Z",
                    f"docker.io/library/postgres:{current_major}-alpine",
                    "sh", "-c", dump_script,
                ],
                stdout=f,
                stderr=log,
            )
        if result.returncode != 0:
            print("❌ Backup extraction failed")
            rollback()
            sys.exit(1)

        print(f"✅ Backup written to {backup}")

        if args.just_dump:
            print("▶ --just-dump: stopping after backup")
            sys.exit(0)

        print("🧹 Clearing data directory")
        try:
            for child in datadir.iterdir():
                shutil.rmtree(child) if child.is_dir() else child.unlink()
        except Exception as e:
            print(f"❌ {e}")
            rollback()
            sys.exit(1)

        pgdata = f"/var/lib/postgresql/{args.target_major}/docker"
        mountpoint = "/var/lib/postgresql"
        initdb_args = "--locale-provider=icu --icu-locale=de-DE --locale=C"
        image = f"docker.io/library/postgres:{args.target_major}-alpine"
        print("▶ ICU locale:       de-DE")

        print(f"🚀 Bootstrapping PostgreSQL {args.target_major}")
        restore_script = (
            "docker-entrypoint.sh postgres &\n"
            "until pg_isready -U postgres; do sleep 1; done\n"
            "psql -q -U postgres < /restore.sql\n"
            "psql -U postgres -c \"select version();\" -c \"\\l\"\n"
        )
        result = subprocess.run(
            [
                "podman", "run", "--rm",
                "-e", "POSTGRES_PASSWORD=a",
                "-e", f"PGDATA={pgdata}",
                "-e", f"POSTGRES_INITDB_ARGS={initdb_args}",
                "-e", "PGOPTIONS=--client-min-messages=warning",
                "-v", f"{datadir}:{mountpoint}:Z",
                "-v", f"{backup}:/restore.sql:ro",
                image,
                "sh", "-c", restore_script,
            ],
            stdout=log,
            stderr=subprocess.STDOUT,
        )
        if result.returncode != 0:
            rollback()
            sys.exit(1)

    print("✅ Upgrade complete")
    print(f"▶ Start service with: systemctl start {args.svc}")


if __name__ == "__main__":
    main()
