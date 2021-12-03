#!/bin/bash

EFIDRIVE=/dev/sda1
EFIDIR=/boot/efi
EFILOADER=/boot/efi/ubuntu
BOOTDIR=/boot

CONF=$(ls -r $BOOTDIR/config-* | head -n1)
IMG=$(ls -r $BOOTDIR/initrd.img-* | head -n1)
MAP=$(ls -r $BOOTDIR/System.map-* | head -n1)
VM=$(ls -r $BOOTDIR/vmlinuz-* | head -n1)

mount $EFIDRIVE $EFIDIR && \
echo 'Mount EFI complate' && \
rm -f $EFILOADER/config && \
rm -f $EFILOADER/initrd.img && \
rm -f $EFILOADER/System.map && \
rm -f $EFILOADER/vmlinuz && \
echo 'Removed old files' && \
cp $CONF $EFILOADER/config && \
cp $IMG $EFILOADER/initrd.img && \
cp $MAP $EFILOADER/System.map && \
cp $VM $EFILOADER/vmlinuz && \
umount $EFIDIR && \
echo 'Unmount EFI complate' && \
echo 'Update linux files in EFI complate'
