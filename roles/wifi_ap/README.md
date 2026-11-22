# wifi_ap

Wi-Fi access point on the router's LAN.

## Purpose

Serves the LAN over Wi-Fi on every configured radio, so clients join the same network as the wired ports.

## Rationale

**Replaces the factory network.** The factory's open network is reconfigured in place, so no unencrypted network is ever left behind.

**WPA2/WPA3 mixed.** Older devices can still join with WPA2, newer ones get WPA3.

**Regulatory domain is mandatory.** The right one depends on where the device is used, so there is no default.
