FROM debian:bullseye

RUN apt update

RUN apt install -y  \
    nasm \
    git \
    mkisofs \
    gdb \
    qemu-system-x86 \
    x11-apps \
     x11-xserver-utils \
   	vim

EXPOSE 6000

ENV DISPLAY=host.docker.internal:0

WORKDIR /build
