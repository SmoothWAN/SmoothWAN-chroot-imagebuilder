#!/bin/bash
buildarch=armhf
apt install libext2fs2 debootstrap qemu-user-static wget
fallocate -l 1.8G smoothwan.img
mkfs.ext4 smoothwan.img
tune2fs -U 337d0b9f-8716-42b2-b316-312811aef984 smoothwan.img
mkdir mnt
mount smoothwan.img mnt/
cd mnt
debootstrap --arch=$buildarch buster . http://ftp.de.debian.org/debian
mount --bind /dev dev
mount --bind /proc proc
mount --bind /sys sys
ln -s /bin/bash bin/ash
chroot . sh -c "/usr/bin/apt update && apt -y install wget"
chroot . /usr/bin/echo "deb https://packages.ntop.org/apt/buster_pi/ armhf/" >> etc/apt/sources.list
chroot . /usr/bin/echo "deb https://packages.ntop.org/apt/buster_pi/ all/" >> etc/apt/sources.list
chroot . /usr/bin/apt -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true update
chroot . /usr/bin/apt-get -y -o APT::Get::AllowUnauthenticated=true install ntopng
chroot . /usr/bin/fallocate -l 512M /swapfile
chroot . /usr/sbin/mkswap /swapfile
chroot . /usr/bin/chmod 0600 /swapfile
umount dev
umount proc
umount sys
cd ..
umount mnt
gzip smoothwan.img
mv smoothwan.img.gz smoothwan_debuster_$buildarch.img.gz
