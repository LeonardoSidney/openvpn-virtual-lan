#!/bin/sh
set -e

verify_environment() {
    if [ -z "$HOST_PROTOCOL" ]; then
        echo "HOST_PROTOCOL is required"
        exit 1
    fi

    if [ -z "$VPN_NETWORK" ]; then
        echo "VPN_NETWORK is required"
        exit 1
    fi

    if [ -z "$VPN_NETMASK" ]; then
        echo "VPN_NETMASK is required"
        exit 1
    fi
}

verify_dir() {
    if [ ! -c /dev/net/tun ]; then
        echo "Device /dev/net/tun not found."
        exit 1
    fi

    if [ ! -d "/easy-rsa/pki" ]; then
        echo "Folder /easy-rsa/pki not found."
        exit 1
    fi

    if [ ! -f "/easy-rsa/vars" ]; then
        echo "File /easy-rsa/vars not found."
        exit 1
    fi

    if [ ! -d "/openvpn/logs" ]; then
        mkdir -p /openvpn/logs
    fi

    if [ ! -d "/openvpn/client" ]; then
        mkdir -p /openvpn/client
    fi
}

set_iptables_rules() {
    iptables -t nat -F
    iptables -F

    VPN_SUBNET="$VPN_NETWORK/$VPN_NETMASK"

    iptables -P FORWARD DROP
    iptables -A FORWARD -s "$VPN_SUBNET" -d "$VPN_SUBNET" -j ACCEPT
    iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
    # iptables -t nat -A POSTROUTING -s "$VPN_SUBNET" ! -d "$VPN_SUBNET" -o eth0 -j MASQUERADE

    iptables-save > /etc/iptables/rules.v4
}

verify_environment
verify_dir
set_iptables_rules
