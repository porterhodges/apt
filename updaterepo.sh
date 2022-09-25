#!/usr/bin/env bash
cd $(dirname "$0") || exit 1 

# Set variable(s)
FTPARCHIVE='apt-ftparchive'
GPG_KEY="4BA7226B690A842DB455F7BAF6823E187E05FC64"

echo "[Repository] Deleting old files..."
rm {Packages{,.xz,.gz,.bz2,.zst},Release{,.gpg}} 2> /dev/null

echo "[Repository] Generating Packages..."
$FTPARCHIVE packages ./pool > Packages
    gzip -c9 Packages > Packages.gz
    xz -c9 Packages > Packages.xz
    xz -5fkev --format=lzma Packages > Packages.lzma
    zstd -c19 Packages > Packages.zst
    bzip2 -c9 Packages > Packages.bz2  
    lz4 -c9 Packages > Packages.lz4

echo "[Repository] Generating Contents..."
$FTPARCHIVE contents ./pool > Contents-iphoneos-arm
    bzip2 -c9 Contents-iphoneos-arm > Contents-iphoneos-arm.bz2
    xz -c9 Contents-iphoneos-arm > Contents-iphoneos-arm.xz
    xz -5fkev --format=lzma Contents-iphoneos-arm > Contents-iphoneos-arm.lzma
    lz4 -c9 Contents-iphoneos-arm > Contents-iphoneos-arm.lz4
    gzip -c9 Contents-iphoneos-arm > Contents-iphoneos-arm.gz
    zstd -c19 Contents-iphoneos-arm > Contents-iphoneos-arm.zst
$FTPARCHIVE release -c ./config/iphoneos-arm64.conf . > Release

echo "[Repository] Signing..."
gpg -vabs -u $GPG_KEY -o Release.gpg Release
echo "[Repository] Generated detached signature"
gpg --clear-sign -u $GPG_KEY -o InRelease Release
echo "[Repository] Generated in-line signature"

echo "[Repository] Done"
done
