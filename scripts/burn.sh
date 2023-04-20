#!/bin/bash

# https://wiki.osdev.org/Mkisofs
cd /build
mkisofs -o /build/rc/preOS.iso -b ../rc/kernel.bin -J -V preOS /build/data
# mkisofs -r -o /build/rc/preOS.iso -b boot/kernel.bin -J  --no-emul-boot  -V preOS data
#mkisofs -J -R -T -V "NGS-8.4-0 Server" \
#    -o ngs-8.4-0.iso \
#    -b isolinux/isolinux.bin \
#    -c isolinux/boot.cat \
#    --no-emul-boot \
#    --boot-load-size 4 \
#    --boot-info-table \
#    --eltorito-alt-boot \
#    -e images/efiboot.img \
#    -m TRANS.TBL \
#    ngs-dvd