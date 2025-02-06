#!/bin/bash

set -e

start_container() {
    echo "Starting container"
    
    if [ -z $EASYRSA_SERVER ]; then
        echo "Easyrsa server directory is required"
        exit 1
    fi
    
    if [ -z $EASYRSA_CLIENT ]; then
        echo "Easyrsa client directory is required"
        exit 1
    fi
    
    if [ ! -d $EASYRSA_SERVER ]; then
        echo "Easyrsa server directory is not mounted"
        exit 1
    fi
    
    if [ ! -f "$EASYRSA_SERVER/vars" ]; then
        echo "Server vars file not found"
        exit 1
    fi
    
    if [ ! -d $EASYRSA_CLIENT ]; then
        echo "Easyrsa client directory is not mounted"
        exit 1
    fi
    
    if [ ! -f "$EASYRSA_CLIENT/vars" ]; then
        echo "Client vars file not found"
        exit 1
    fi

    if [ ! -d $OPENVPN_DIR ]; then
        echo "Openvpn directory is not mounted"
        exit 1
    fi
}
