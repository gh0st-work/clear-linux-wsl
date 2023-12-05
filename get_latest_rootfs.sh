#!/bin/bash

xz_level="$1"
if [ "$xz_level" = "" ]; then
    xz_level="$XZ_LEVEL"
    if [ "$xz_level" = "" ]; then
        echo "ERROR: Provide XZ_LEVEL"
        exit 1
    fi
fi

xz_threads="$1"
if [ "$xz_threads" = "" ]; then
    xz_threads="$XZ_THREADS"
    if [ "$xz_threads" = "" ]; then
        echo "ERROR: Provide XZ_THREADS"
        exit 1
    fi
fi

wget_with_status() {
    local _wget_status=($( wget --server-response "$1" 2>&1 | awk '{ if (match($0, /.*HTTP\/[0-9\.]+ ([0-9]+).*/, m)) print m[1] }' ))
    _wget_status="${_wget_status[${#_wget_status[@]} - 1]}"
    echo "$_wget_status"
}


echo "- Getting the latest Clear Linux version..."
ver=$( curl -s "https://raw.githubusercontent.com/clearlinux/docker-brew-clearlinux/base/VERSION" )

echo "- Downloading Clear Linux latest ($ver) release..."
iso_name="clear-$ver-live-server.iso"
iso_url="https://cdn.download.clearlinux.org/releases/$ver/clear/$iso_name"
wget_status=$( wget_with_status $iso_url  )
if [[ "$wget_status" != 200 ]]; then
    echo "ERROR: Wrong respone status code ($wget_status), check your internet connection & file ($iso_url) availability"
    exit 1
fi

echo "- Mounting $iso_name ..."
mnt_iso_path="/mnt/clear_linux_iso"
sudo mkdir $mnt_iso_path 
sudo mount -o loop $iso_name $mnt_iso_path 

echo "- Mounting rootfs.img ..."
mnt_img_path="/mnt/clear_linux_rootfs_img"
sudo mkdir $mnt_img_path 
sudo mount -o loop "$mnt_iso_path/images/rootfs.img" $mnt_img_path 

echo "- Copying files..."
copy_name="clear_linux_rootfs_copy"
mkdir $copy_name
sudo cp -r $mnt_img_path/* ./$copy_name

echo "- Unmounting..."
sudo umount $mnt_img_path
sudo umount $mnt_iso_path
sudo rm -rf $mnt_img_path
sudo rm -rf $mnt_iso_path

echo "- Creating tarball..."
cd $copy_name
sudo tar -cf ../clear_linux_rootfs.tar *
cd ..
echo $(du -h clear_linux_rootfs.tar)
sudo xz -$xz_level -T$xz_threads clear_linux_rootfs.tar
echo $(du -h clear_linux_rootfs.tar.xz)

echo "- Cleaning up..."
rm $iso_name
sudo rm -rf $copy_name
sudo rm -rf clear_linux_rootfs.tar

echo "SUCCESS"
