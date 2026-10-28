# OpenVPN Virtual LAN

A self-hosted virtual LAN built on OpenVPN and Docker Compose. Devices connected to the VPN can reach each other as if they were on the same local network (`192.168.100.0/24`), without routing their internet traffic through the server.

It ships with its own certificate authority: a separate container manages the PKI with Easy-RSA, issues client certificates and generates ready-to-import `.ovpn` profiles.

Typical uses: LAN gaming with friends, reaching homelab services remotely, or connecting machines behind NAT.

## Architecture

| Container | Role |
| --- | --- |
| `ca-machine` | Certificate authority. Runs on demand to initialize the PKI, issue client certificates and generate `.ovpn` files. |
| `openvpn-machine` | OpenVPN server. Runs continuously, applies firewall rules and serves the virtual LAN. |

The two containers share only the volumes they need. The CA private key stays in `volumes/ca-machine` and is never mounted into the VPN server.

## Security choices

- Elliptic-curve PKI (`secp521r1`) with SHA-512 signatures
- TLS 1.2+ with ECDHE cipher suites and `tls-auth` HMAC protection
- AES-256-GCM data channel
- Server and client certificate roles enforced (`remote-cert-tls`)
- Split tunnel: client profiles use `route-nopull`, so clients ignore any route pushed by the server and never get a default gateway through the VPN

## Requirements

- Docker with the Compose plugin
- A host with a public address or domain and the VPN port open (UDP `25570` by default)
- The TUN device (`/dev/net/tun`) available on the host

## Configuration

Copy `.env.example` to `.env` and edit it. Every command fails until `.env` exists with all variables set.

```bash
cp .env.example .env
```

| Variable | Description | Default |
| --- | --- | --- |
| `HOST_ADDR` | Public address or domain clients connect to | `youraddress.com` |
| `HOST_PORT` | Port published on the host | `25570` |
| `HOST_PROTOCOL` | Transport protocol (`udp4`, `udp6`, `tcp4`, `tcp6`) | `udp4` |
| `VPN_NETWORK` | Virtual LAN network address | `192.168.100.0` |
| `VPN_NETMASK` | Virtual LAN netmask | `255.255.255.0` |

These values are the single source for the server, the firewall rules, the published port and the generated `.ovpn` files. After changing them, restart the server and regenerate the client profiles.

Other server settings (ciphers, logging, pushed options) live in `volumes/openvpn-machine/openvpn/server/server.conf`.

## Usage

### 1. Initialize the PKI (first run only)

```bash
docker compose run --rm ca-machine init-pki
```

Creates the certificate authority, the `tls-auth` key and the client-side PKI. You will be asked for a CA passphrase; keep it safe.

### 2. Create the server certificate (first run only)

```bash
docker compose run --rm ca-machine create-server
```

Generates the server key and certificate (`openvpnserver.crt` / `.key`) and copies them to `volumes/openvpn-machine/openvpn/server`.

### 3. Create a user

```bash
docker compose run --rm ca-machine create-user alice
```

Generates a key and certificate request for `alice` and signs it with the CA.

Both `create-server` and `create-user` are interactive: Easy-RSA asks for the certificate common name, a `yes` confirmation before signing, and the CA passphrase.

### 4. Generate the client profile

```bash
docker compose run --rm ca-machine gen-user-ovpn alice
```

Writes `volumes/openvpn-machine/openvpn/client/alice.ovpn`, a single file with all certificates embedded. Import it into any OpenVPN client.

The profile contains the user's private key. Send it over a secure channel and delete copies you no longer need.

### 5. Start the server

```bash
docker compose up -d openvpn-machine
```

Logs, connection status and the IP pool (`ipp.txt`) are written to `volumes/openvpn-machine/openvpn/logs`.

## Roadmap

- [ ] `revoke-user` and `help` commands
- [ ] Support for multiple protocols per profile
- [ ] Optional reverse proxy service

## License

GPL-3.0
