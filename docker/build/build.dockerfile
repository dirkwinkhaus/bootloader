FROM debian:bullseye

RUN apt update

RUN apt install -y  \
    nasm \
    git \
    mkisofs \
    gdb \
    qemu-system-x86 \
   	vim

WORKDIR /build
