#!/bin/bash

set -e

check_files_create_user() {
    if [ -z $CLIENT_NAME ]; then
        echo "Username is required"
        exit 1
    fi
    
    if [ ! -d "$EASYRSA_SERVER/pki" ]; then
        echo "PKI does not exist please run init-pki"
        exit 1
    fi
    
    if [ -f "$EASYRSA_SERVER/pki/issued/$CLIENT_NAME.crt" ]; then
        echo "Client certificate already exists"
        exit 1
    fi
    
}

create_user() {
    CLIENT_NAME=$1
    check_files_create_user
    
    echo "Generating certificate and key for client: $CLIENT_NAME"

    export EASYRSA_PKI="$EASYRSA_CLIENT/pki"
    $EASYRSA/easyrsa gen-req $CLIENT_NAME nopass
    
    export EASYRSA_PKI="$EASYRSA_SERVER/pki"
    $EASYRSA/easyrsa import-req $EASYRSA_CLIENT/pki/reqs/$CLIENT_NAME.req $CLIENT_NAME
    $EASYRSA/easyrsa sign-req client $CLIENT_NAME
    
    cp $EASYRSA_SERVER/pki/issued/$CLIENT_NAME.crt $EASYRSA_CLIENT/pki/issued/$CLIENT_NAME.crt
    
    exit 0
}