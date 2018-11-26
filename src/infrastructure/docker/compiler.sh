#!/usr/bin/env bash

export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

cd /root
mkdir -p /root/src/binutils /root/src/gcc

wget https://ftp.gnu.org/gnu/binutils/binutils-2.31.tar.gz
wget https://ftp.gnu.org/gnu/gcc/gcc-8.2.0/gcc-8.2.0.tar.gz

tar -xzf binutils-2.31.tar.gz
tar -xzf gcc-8.2.0.tar.gz

cd /root/src/binutils
../../binutils-2.31/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install

cd /root/src/gcc
../../gcc-8.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc

ln -s /root/opt/cross/bin/i686-elf-gcc /bin/i686-elf-gcc
ln -s /root/opt/cross/bin/i686-elf-ld /bin/i686-elf-ld
ln -s /root/opt/cross/bin/i686-elf-as /bin/i686-elf-as