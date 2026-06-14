# dyndns

Keeps the host's public DNS record at Strato pointed at its current global IPv6
address, so the homeserver stays reachable when the ISP rotates the IPv6 prefix.

A systemd timer refreshes the record periodically and a NetworkManager dispatcher
hook refreshes it immediately when IPv6 connectivity changes.

## Operator setup

The Strato DynDNS password is a host-side secret and is **not** stored in this
repository. The service loads it as the encrypted systemd credential
`strato-password` from `/etc/strato-dyndns.cred`. Create that file once, on the
host (it is bound to the host/TPM and cannot be decrypted elsewhere):

```
echo -n 'YOUR_DYNDNS_PASSWORD' \
  | systemd-creds encrypt --name=strato-password - /etc/strato-dyndns.cred
```

Use the DynDNS password configured in the Strato control panel. The non-secret
username and hostname are set in `strato-dyndns.service`.

Inbound IPv6 must also be permitted by the home router/ISP; that is outside the
scope of this role.
