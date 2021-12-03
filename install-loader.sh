#!/bin/bash

# The UUID of your disk.
# Note: if using LVM, this should be the LVM partition.
UUID="842618d9-9450-4fe1-a460-b0866c2e7b24"

# The LUKS volume slug you want to use, which will result in the
# partition being mounted to /dev/ "CHANGEME" or "mapper/CHANGEME.
# example: "sda1" or "mapper/rootfs".
VOLUME="sda4"

# Any rootflags you wish to set.
ROOTFLAGS="quiet"



# Our kernels.
KERNELS=()
FIND="find /boot -maxdepth 1 -name 'vmlinuz-*' -type f -print0 | sort -rz"
while IFS= read -r -u3 -d $'\0' LINE; do
    KERNEL=$(basename "${LINE}")
    KERNELS+=("${KERNEL:8}")
done 3< <(eval "${FIND}")

# There has to be at least one kernel.
if [ ${#KERNELS[@]} -lt 1 ]; then
    echo -e "\e[2msystemd-boot\e[0m \e[1;31mNo kernels found.\e[0m"
    exit 1
fi



# Perform a nuclear clean to ensure everything is always in perfect
# sync.
rm /boot/efi/loader/entries/*.conf
rm -rf /boot/efi/ubuntu
mkdir /boot/efi/ubuntu



# Copy the latest kernel files to a consistent place so we can keep
# using the same loader configuration.
LATEST="${KERNELS[@]:0:1}"
echo -e "\e[2msystemd-boot\e[0m \e[1;32m${LATEST}\e[0m"
for FILE in config initrd.img System.map vmlinuz; do
    cp "/boot/${FILE}-${LATEST}" "/boot/efi/ubuntu/${FILE}"
    cat << EOF > /boot/efi/loader/entries/ubuntu.conf
title   Ubuntu GNOME
linux   /ubuntu/vmlinuz
initrd  /ubuntu/initrd.img
options cryptdevice=UUID=${UUID}:${VOLUME} root=/dev/${VOLUME} ro rootflags=${ROOTFLAGS}
EOF
done



# Copy any legacy kernels over too, but maintain their version-based
# names to avoid collisions.
if [ ${#KERNELS[@]} -gt 1 ]; then
    LEGACY=("${KERNELS[@]:1}")
    for VERSION in "${LEGACY[@]}"; do
        echo -e "\e[2msystemd-boot\e[0m \e[1;32m${VERSION}\e[0m"
        for FILE in config initrd.img System.map vmlinuz; do
            cp "/boot/${FILE}-${VERSION}" "/boot/efi/ubuntu/${FILE}-${VERSION}"
            cat << EOF > /boot/efi/loader/entries/ubuntu-${VERSION}.conf
title   Ubuntu GNOME ${VERSION}
linux   /ubuntu/vmlinuz-${VERSION}
initrd  /ubuntu/initrd.img-${VERSION}
options cryptdevice=UUID=${UUID}:${VOLUME} root=/dev/${VOLUME} ro rootflags=${ROOTFLAGS}
EOF
        done
    done
fi



# Success!
exit 0
