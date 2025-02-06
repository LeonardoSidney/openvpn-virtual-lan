#!/bin/bash

set -e

COMMAND=$1

validCommands=("init-pki" "create-user" "gen-user-ovpn" "revokeuser" "help")

if [ -z "$COMMAND" ]; then
    echo "Command is required"
    exit 1
fi

if [[ ! " ${validCommands[@]} " =~ " ${COMMAND} " ]]; then
    echo "Invalid command"
    exit 1
fi

source start.sh
source init_pki.sh
source create_user.sh
source gen_user_ovpn.sh

start_container

export EASYRSA="/usr/share/easy-rsa"
export EASYRSA_VARS_FILE="$EASYRSA_SERVER/vars"

if [ "$COMMAND" == "init-pki" ]; then
    init_pki
    exit 0
fi

if [ "$COMMAND" == "create-user" ]; then
    create_user $2
    exit 0
fi

if [ "$COMMAND" == "gen-user-ovpn" ]; then
    gen_user_ovpn $2
    exit 0
fi