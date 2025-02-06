#!/bin/bash

set -e

init_pki() {
    if [ -d "$EASYRSA_SERVER/pki" ]; then
        echo "PKI already exists please use regen-pki to generate a new one"
        exit 1
    fi

    if [ -d "$EASYRSA_CLIENT/pki" ]; then
        echo "Client PKI already exists please use regen-pki to generate a new one"
        exit 1
    fi

    export EASYRSA_PKI="$EASYRSA_SERVER/pki"
    $EASYRSA/easyrsa init-pki
    $EASYRSA/easyrsa build-ca
    cp $EASYRSA_SERVER/pki/ca.crt $OPENVPN_DIR/server/ca.crt

    echo "creating ta.key"
    openvpn --genkey tls-auth $OPENVPN_DIR/server/ta.key

    export EASYRSA_PKI="$EASYRSA_CLIENT/pki"
    $EASYRSA/easyrsa init-pki

    exit 0
}