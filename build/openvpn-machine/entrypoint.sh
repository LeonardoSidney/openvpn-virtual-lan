#!/bin/sh
set -e

source /root/start.sh

exec openvpn --config /openvpn/server/server.conf --proto "$HOST_PROTOCOL" --server "$VPN_NETWORK" "$VPN_NETMASK"