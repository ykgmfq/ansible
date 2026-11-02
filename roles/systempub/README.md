# systempub

Points the host's systempub (installed by `common`) at an MQTT broker over a websocket, so ZFS pool and systemd unit state reaches Home Assistant — and from there the phone.

## Rationale

**Websocket transport.** The broker is reached as a `ws://`/`wss://` URL, so the connection can run through the WireGuard tunnel or an HTTP reverse proxy instead of needing a raw MQTT port reachable from offsite.

**Generated at deploy, enrolled like the syncoid key.** On first run the password is generated, enrolled on the broker through the appserver (the way the syncoid key is authorized on its source), and only then stored on the host as an encrypted systemd credential that systempub reads in preference to the config file. No vault is involved, so neither host depends on one. The credential is bound to the host; delete it to rotate the password on the next run.
