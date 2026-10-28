#!/bin/bash

set -e

check_files_create_server() {
    if [ ! -d "$EASYRSA_SERVER/pki" ]; then
        echo "PKI does not exist please run init-pki"
        exit 1
    fi

    if [ -f "$EASYRSA_SERVER/pki/issued/$SERVER_NAME.crt" ]; then
        echo "Server certificate already exists"
        exit 1
    fi
}

create_server() {
    SERVER_NAME="openvpnserver"
    check_files_create_server

    echo "Generating certificate and key for server: $SERVER_NAME"

    export EASYRSA_PKI="$EASYRSA_CLIENT/pki"
    $EASYRSA/easyrsa gen-req "$SERVER_NAME" nopass

    export EASYRSA_PKI="$EASYRSA_SERVER/pki"
    $EASYRSA/easyrsa import-req "$EASYRSA_CLIENT/pki/reqs/$SERVER_NAME.req" "$SERVER_NAME"
    $EASYRSA/easyrsa sign-req server "$SERVER_NAME"

    cp "$EASYRSA_SERVER/pki/issued/$SERVER_NAME.crt" "$OPENVPN_DIR/server/$SERVER_NAME.crt"
    cp "$EASYRSA_CLIENT/pki/private/$SERVER_NAME.key" "$OPENVPN_DIR/server/$SERVER_NAME.key"

    exit 0
}
