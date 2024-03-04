#!/bin/bash

set -eEo pipefail

wget_with_status() (
    set -eEo pipefail
    local status=$( wget --server-response "$1" 2>&1 | grep -F 'HTTP/' 2>&1 | tail -1 2>&1 | sed -r "s/^.*HTTP\/[0-9\.]+ ([0-9]+).*$/\1/" )
    echo "$status"
)

main() (
    set -eEo pipefail

    local xz_level="$1"
    if [ "$xz_level" = "" ]; then
        echo "ERROR: Provide xz_level"
        exit 1
    fi

    local xz_threads="$2"
    if [ "$xz_threads" = "" ]; then
        echo "ERROR: Provide xz_threads"
        exit 1
    fi

    echo "- Getting the latest Clear Linux version..."
    local ver=$( curl -s "https://cdn.download.clearlinux.org/latest" )
    if [[ "$ver" = "41150" ]]; then ver="41160"; fi # broken release
    CLEAR_LINUX_VERSION="$ver"

    echo "- Downloading Clear Linux latest ($ver) release..."
    local iso_name="clear-$ver-live-server.iso"
    local iso_url="https://cdn.download.clearlinux.org/releases/$ver/clear/$iso_name"
    local wget_status=$( wget_with_status $iso_url  )
    if [[ "$wget_status" != 200 ]]; then
        echo "ERROR: Wrong respone status code ($wget_status), check your internet connection & file ($iso_url) availability"
        exit 1
    fi

    echo "- Mounting $iso_name ..."
    local mnt_iso_path="/mnt/clear_linux_iso"
    sudo mkdir $mnt_iso_path || exit 1
    sudo mount -o loop $iso_name $mnt_iso_path || exit 1

    echo "- Mounting rootfs.img ..."
    local mnt_img_path="/mnt/clear_linux_rootfs_img"
    sudo mkdir $mnt_img_path || exit 1
    sudo mount -o loop "$mnt_iso_path/images/rootfs.img" $mnt_img_path || exit 1

    echo "- Copying files..."
    local copy_name="clear_linux_rootfs_copy"
    mkdir $copy_name || exit 1
    sudo cp -r $mnt_img_path/* ./$copy_name || exit 1

    echo "- Unmounting..."
    sudo umount $mnt_img_path || exit 1
    sudo umount $mnt_iso_path || exit 1
    sudo rm -rf $mnt_img_path || exit 1
    sudo rm -rf $mnt_iso_path || exit 1

    echo "- Creating tarball..."
    cd $copy_name
    sudo tar -cf ../clear_linux_rootfs.tar * || exit 1
    cd ..
    echo $(du -h clear_linux_rootfs.tar)
    sudo xz -$xz_level -T$xz_threads clear_linux_rootfs.tar || exit 1
    echo $(du -h clear_linux_rootfs.tar.xz)

    echo "- Cleaning up..."
    rm $iso_name
    sudo rm -rf $copy_name
    sudo rm -rf clear_linux_rootfs.tar

    echo "SUCCESS"
)

main "$@" || exit 1
