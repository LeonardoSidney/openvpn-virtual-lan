FROM alpine:latest

WORKDIR /root

RUN apk add --no-cache bash easy-rsa openvpn

COPY build/ca-machine/entrypoint.sh entrypoint.sh
COPY build/ca-machine/start.sh start.sh
COPY build/ca-machine/init_pki.sh init_pki.sh
COPY build/ca-machine/create_user.sh create_user.sh
COPY build/ca-machine/gen_user_ovpn.sh gen_user_ovpn.sh

RUN chmod +x entrypoint.sh
RUN chmod +x start.sh
RUN chmod +x init_pki.sh
RUN chmod +x create_user.sh
RUN chmod +x gen_user_ovpn.sh

ENTRYPOINT ["/root/entrypoint.sh"]


# CMD [ "/bin/bash", "-c", "tail -F anything" ]