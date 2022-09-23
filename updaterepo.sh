#!/usr/bin/env bash
script_full_path=$(dirname "$0")
cd $script_full_path || exit 1

# Set variable(s)
FTPARCHIVE='apt-ftparchive'

# Remove old files
rm {Packages{,.xz,.gz,.bz2,.zst},Release{,.gpg}} 2> /dev/null

$FTPARCHIVE packages ./pool > Packages
    gzip -c9 Packages > Packages.gz
    xz -c9 Packages > Packages.xz
    xz -5fkev --format=lzma Packages > Packages.lzma
    zstd -c19 Packages > Packages.zst
    bzip2 -c9 Packages > Packages.bz2  
    lz4 -c9 Packages > Packages.lz4

$FTPARCHIVE contents ./pool > Contents-iphoneos-arm
    bzip2 -c9 Contents-iphoneos-arm > Contents-iphoneos-arm.bz2
    xz -c9 Contents-iphoneos-arm > Contents-iphoneos-arm.xz
    xz -5fkev --format=lzma Contents-iphoneos-arm > Contents-iphoneos-arm.lzma
    lz4 -c9 Contents-iphoneos-arm > Contents-iphoneos-arm.lz4
    gzip -c9 Contents-iphoneos-arm > Contents-iphoneos-arm.gz
    zstd -c19 Contents-iphoneos-arm > Contents-iphoneos-arm.zst
$FTPARCHIVE release -c ./config/iphoneos-arm.conf . > Release

# Sign repository
gpg -abs -u 4BA7226B690A842DB455F7BAF6823E187E05FC64 -o Release.gpg Release
gpg -abs -u 4BA7226B690A842DB455F7BAF6823E187E05FC64 --clearsign -o InRelease Release

echo "Done"
