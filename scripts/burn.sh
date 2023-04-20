#!/bin/bash

# https://wiki.osdev.org/Mkisofs

mkisofs -o /build/rc/preOS.iso -b /build/rc/kernel.bin -J -V preOS /build/data