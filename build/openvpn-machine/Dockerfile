FROM alpine:3.24

WORKDIR /root

RUN apk add --no-cache openvpn bash iptables

COPY build/openvpn-machine/start.sh start.sh
COPY build/openvpn-machine/entrypoint.sh entrypoint.sh
RUN chmod +x start.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT [ "/root/entrypoint.sh" ]