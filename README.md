# OpenVPN virtual LAN

## fisrt run
```bash
docker compose run --rm 'ca-machine' init-pki
```

## create user
```bash
docker compose run --rm 'ca-machine' create-user
```