FROM alpine
RUN apk update && apk upgrade && apk add qemu-system-x86_64 && apk add qemu-img && apk add cdrkit
COPY ./qemu.sh /
ENTRYPOINT ["/qemu.sh"]
