#!/bin/bash

set -e

verify_files_gen_user_ovpn() {
    if [ -z $CLIENT_NAME ]; then
        echo "Username is required"
        exit 1
    fi
    
    if [ ! -d "$EASYRSA_SERVER/pki" ]; then
        echo "PKI does not exist please run init-pki"
        exit 1
    fi
    
    if [ ! -f "$EASYRSA_SERVER/pki/issued/$CLIENT_NAME.crt" ]; then
        echo "Client certificate does not exist"
        exit 1
    fi
    
    if [ ! -f "$CA_CERT" ]; then
        echo "Error: CA certificate not found!"
        exit 1
    fi
    
    if [ ! -f "$CLIENT_CERT" ]; then
        echo "Error: Client certificate not found!"
        exit 1
    fi
    
    if [ ! -f "$CLIENT_KEY" ]; then
        echo "Error: Client key not found!"
        exit 1
    fi
    
    if [ ! -f "$TA_KEY" ]; then
        echo "Error: TA key not found!"
        exit 1
    fi
    
    if [ -z $HOST_ADDR ]; then
        echo "Error: HOST_ADDR is required"
        exit 1
    fi
}


gen_user_ovpn() {
    CLIENT_NAME=$1
    CA_CERT=$OPENVPN_DIR/server/ca.crt
    CLIENT_CERT=$EASYRSA_SERVER/pki/issued/$CLIENT_NAME.crt
    CLIENT_KEY=$EASYRSA_CLIENT/pki/private/$CLIENT_NAME.key
    TA_KEY=$OPENVPN_DIR/server/ta.key
    
    verify_files_gen_user_ovpn
    
    echo "Generating ovpn file for client: $CLIENT_NAME"
    
    OVPN_FILE="/$OPENVPN_DIR/client/$CLIENT_NAME.ovpn"
    echo "client" > $OVPN_FILE
    echo "dev tun" >> $OVPN_FILE
    echo "remote $HOST_ADDR $HOST_PORT $HOST_PROTOCOL" >> $OVPN_FILE # TODO: Support for multiples protocols
    echo "resolv-retry infinite" >> $OVPN_FILE
    echo "nobind" >> $OVPN_FILE
    echo "persist-key" >> $OVPN_FILE
    echo "persist-tun" >> $OVPN_FILE
    echo "remote-cert-tls server" >> $OVPN_FILE
    echo "cipher AES-256-GCM" >> $OVPN_FILE
    echo "auth SHA512" >> $OVPN_FILE
    echo "verb 3" >> $OVPN_FILE
    echo "key-direction 1" >> $OVPN_FILE
    echo "route-nopull" >> $OVPN_FILE
    echo "" >> $OVPN_FILE
    
    echo "<ca>" >> $OVPN_FILE
    cat $CA_CERT >> $OVPN_FILE
    echo "</ca>" >> $OVPN_FILE
    
    echo "<cert>" >> $OVPN_FILE
    cat $CLIENT_CERT >> $OVPN_FILE
    echo "</cert>" >> $OVPN_FILE
    
    echo "<key>" >> $OVPN_FILE
    cat $CLIENT_KEY >> $OVPN_FILE
    echo "</key>" >> $OVPN_FILE
    
    echo "<tls-auth>" >> $OVPN_FILE
    cat $TA_KEY >> $OVPN_FILE
    echo "</tls-auth>" >> $OVPN_FILE

    echo EOF >> $OVPN_FILE

    echo "OVPN file generated: $OVPN_FILE"

    exit 0
}