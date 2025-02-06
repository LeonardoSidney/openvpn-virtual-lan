#!/bin/sh
set -e

verify_dir() {
    if [ ! -c /dev/net/tun ]; then
        mkdir -p /dev/net
        mknod /dev/net/tun c 10 200
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

    iptables -A INPUT -p udp --dport 25570 -j ACCEPT
    iptables -P FORWARD DROP
    iptables -A FORWARD -s 192.168.100.0/24 -d 192.168.100.0/24 -j ACCEPT
    iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
    # iptables -t nat -A POSTROUTING -s 192.168.100.0/24 ! -d 192.168.100.0/24 -o eth0 -j MASQUERADE

    iptables-save > /etc/iptables/rules.v4
}

verify_dir
set_iptables_rules
