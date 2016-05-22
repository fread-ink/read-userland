#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" >&2
   exit 1
fi

set -e

VAGRANT_DIR="/vagrant"
CHROOT="./arm_chroot"

echo "Running debootstrap"
qemu-debootstrap --arch=armhf jessie $CHROOT http://ftp.debian.org/debian/

cp /usr/bin/qemu-arm-static ${CHROOT}/usr/bin/
cp -a /etc/resolv.conf ${CHROOT}/etc/
cp -a /etc/apt/sources.list ${CHROOT}/etc/apt/

cat <<EOT > ${CHROOT}/etc/apt/apt.conf.d/71-no-recommends
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOT

echo fread-cross > /etc/hostname

cp ${VAGRANT_DIR}/finalize_chroot_env.sh ${CHROOT}/root/

echo "This is a magic file for scripts to check to know they're in the right chroot env" > ${CHROOT}/etc/fread_qemu_cross_compile_chroot

echo ""
echo "First stage completed!"
echo "To complete second (and final) stage:"
echo "  sudo chroot ${CHROOT} /bin/su -"
echo "  ./finalize_chroot_env.sh" 
echo ""

set +e