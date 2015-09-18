FROM alpine
RUN apk update && apk upgrade && \
    apk add qemu-system-x86_64 && apk add qemu-img && apk add cdrkit && apk add openssh-client
COPY ./ssh_config ./qemu.sh ./ssh.sh /
ENTRYPOINT ["/qemu.sh"]
