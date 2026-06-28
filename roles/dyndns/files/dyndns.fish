#!/usr/bin/fish

# Publishes this host's own global IPv6 address to a dynamic-DNS provider as an AAAA record.
#
# Why this exists: the box sits behind a router on a dual-stack line. The router keeps
# updating the IPv4 A record via its own DynDNS client, but with IPv6 there is no NAT, so the
# AAAA record must point at this host's address, not the router's. The router cannot publish
# an internal host's address into a third-party DynDNS record, so this host does it itself.
#
# Configuration comes from the systemd unit:
#   DYNDNS_ENDPOINT   the provider's dyndns2 update URL
#   DYNDNS_HOSTNAME   the hostname to update (also the basic-auth username)
#   DYNDNS_USERNAME   optional override for the basic-auth username (defaults to DYNDNS_HOSTNAME)
#   WAN_IFACE         optional interface override (defaults to the IPv6 default-route interface)
# The provider password is read from the systemd credential "dyndns-password".

set cache_file /var/lib/dyndns/last-ip6

function die --description 'Report an error and abort'
    echo $argv >&2
    exit 1
end

function require_config --description 'Abort unless the unit handed us everything needed to run'
    for var in DYNDNS_ENDPOINT DYNDNS_HOSTNAME
        set --query $var
        or die "$var is not set"
    end

    set --query DYNDNS_USERNAME
    or set --global DYNDNS_USERNAME $DYNDNS_HOSTNAME

    set --query CREDENTIALS_DIRECTORY
    or die "CREDENTIALS_DIRECTORY is not set; run via the systemd unit"

    set --global password_file $CREDENTIALS_DIRECTORY/dyndns-password
    test -r $password_file
    or die "DynDNS password credential not found at $password_file"
end

function read_password --description 'Provider password from the systemd credential'
    string trim (cat $password_file)
end

function detect_wan_iface --description 'WAN interface: explicit override, otherwise the IPv6 default route'
    if set --query WAN_IFACE
        echo $WAN_IFACE
    else
        ip -j -6 route show default | jq -r '.[0].dev // empty'
    end
end

function global_ip6 --argument-names iface --description 'Stable global unicast address (not temporary, deprecated, or unique-local); EUI-64 keeps its suffix across prefix rotations'
    ip -j -6 addr show dev $iface | jq -r '
        [ .[0].addr_info[]
          | select(.family == "inet6" and .scope == "global")
          | select(.temporary != true and .deprecated != true)
          | select(.local | test("^f[cd]") | not)
          | .local ] | first // empty'
end

function address_unchanged --argument-names ip6 --description 'True when the cached address still matches; providers penalize no-change updates'
    test -r $cache_file
    and test (string trim (cat $cache_file)) = "$ip6"
end

function publish_update --argument-names ip6 --description 'Update only the AAAA record (myip carries IPv6); the router still owns the A record'
    set --local url "$DYNDNS_ENDPOINT?hostname=$DYNDNS_HOSTNAME&myip=$ip6"
    set --local response (curl --silent --show-error --fail --user "$DYNDNS_USERNAME:"(read_password) $url)
    or die "DynDNS update request failed (curl exit $status): $response"

    switch $response
        case 'good*' 'nochg*'
            echo "Provider accepted update for $DYNDNS_HOSTNAME -> $ip6 ($response)"
            printf '%s\n' $ip6 >$cache_file
        case '*'
            die "Provider rejected update: $response"
    end
end

require_config

set wan_iface (detect_wan_iface)
test -n "$wan_iface"
or die "Could not determine the WAN interface"

set ip6 (global_ip6 $wan_iface)
test -n "$ip6"
or die "No global IPv6 address found on $wan_iface"

if address_unchanged $ip6
    echo "IPv6 unchanged ($ip6); nothing to do"
    exit 0
end

mkdir -p (dirname $cache_file)
publish_update $ip6
