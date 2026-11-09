# systempub

Publishes ZFS pool and systemd unit state to an MQTT broker so it reaches Home Assistant.

## Rationale

**Websocket transport.** The broker is reached over a websocket, so the connection can run through the WireGuard tunnel or an HTTP reverse proxy instead of needing a raw MQTT port reachable from offsite.

**Generated at deploy, enrolled like the syncoid key.** On first run the password is generated, enrolled on the broker through the appserver, and only then stored on the host as an encrypted systemd credential.
No vault is involved, so neither host depends on one.
The credential is bound to the host; delete it to rotate the password on the next run.

**Local broker.** With no broker URL set, as on the broker's own host, systempub keeps its default of the local unauthenticated listener and no credential is enrolled.
