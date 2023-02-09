#!/bin/bash
buildarch=amd64
apt install libext2fs2 debootstrap wget
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
chroot . /usr/bin/wget https://packages.ntop.org/apt-stable/buster/all/apt-ntop-stable.deb
chroot . /usr/bin/dpkg -i /apt-ntop-stable.deb
chroot . /usr/bin/apt -y install -f
chroot . /usr/bin/apt update
chroot . /usr/bin/apt -y install ntopng
umount dev
umount proc
umount sys
cd ..
umount mnt
gzip smoothwan.img
mv smoothwan.img.gz smoothwan_debuster_x86_64.img.gz
