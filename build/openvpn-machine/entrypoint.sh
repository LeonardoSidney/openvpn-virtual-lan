#!/bin/sh
set -e

source /root/start.sh

exec openvpn --config /openvpn/server/server.conf