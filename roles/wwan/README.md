# wwan

Mobile-broadband uplink for an OpenWRT router, through a USB modem.

## Purpose

Gives a travel router an internet connection wherever there is mobile coverage.
The interface is named for what it is, not for the radio generation, so a later 5G modem replaces the role's internals rather than its name.

## Rationale

**Dual-stack only.** Everything downstream, including encrypted DNS, expects both address families, so the session always requests IPv4 and IPv6 and there is no IPv4-only mode.

**No prefix delegation.** Mobile networks hand out a single /64, so the router relays it to the LAN rather than delegating a prefix, which is what the home WAN does.

**Metric above the wired WAN.** Plugging in Ethernet at a hotel or office should win over the modem, saving mobile data.

**Modem-specific by design.** Driver packages and control port suit a Huawei E3372 in stick (NCM) mode; the HiLink variant shows up as an Ethernet device and needs none of this.
