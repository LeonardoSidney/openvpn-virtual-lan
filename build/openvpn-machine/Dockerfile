FROM alpine:latest

WORKDIR /root

RUN apk add --no-cache openvpn easy-rsa curl zsh openssl git bash iptables

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

COPY build/openvpn-machine/start.sh start.sh
COPY build/openvpn-machine/entrypoint.sh entrypoint.sh
RUN chmod +x start.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT [ "/root/entrypoint.sh" ]