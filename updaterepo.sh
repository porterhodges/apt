#!/usr/bin/env bash
cd $(dirname "$0")

# Set variable(s)
FTPARCHIVE='apt-ftparchive'
GPG_KEY="4BA7226B690A842DB455F7BAF6823E187E05FC64"

for dist in main testing; do
	if [[ "${dist}" == "main" ]]; then
		arch=iphoneos-arm
	elif [[ "${dist}" == "testing" ]]; then
		arch=iphoneos-arm64
	else
		arch=$(echo "${dist}" | cut -f1 -d '/')
	fi
	echo $dist
	binary=binary-${arch}
	contents=Contents-${arch}
	mkdir -p dists/${dist}
	rm -f dists/${dist}/{Release{,.gpg},InRelease}

	cp -a CydiaIcon*.png dists/${dist}

	for comp in main testing; do
		if [ ! -d pool/${comp}/${dist} ]; then
			continue;
		fi
		mkdir -p dists/${dist}/${comp}/${binary}
		rm -f dists/${dist}/${comp}/${binary}/{Packages{,.xz,.gz,.bz2,.zst,.lzma,.lz4},Release{,.gpg},InRelease}

		$FTPARCHIVE packages pool/${comp}/${dist} > \
			dists/${dist}/${comp}/${binary}/Packages 2>/dev/null
		xz -c9 dists/${dist}/${comp}/${binary}/Packages > dists/${dist}/${comp}/${binary}/Packages.xz
        xz -5fkev --format=lzma dists/${dist}/${comp}/${binary}/Packages > dists/${dist}/${comp}/${binary}/Packages.lzma
		zstd -q -c19 dists/${dist}/${comp}/${binary}/Packages > dists/${dist}/${comp}/${binary}/Packages.zst
        gzip -c9 dists/${dist}/${comp}/${binary}/Packages > dists/${dist}/${comp}/${binary}/Packages.gz
        bzip2 -c9 dists/${dist}/${comp}/${binary}/Packages > dists/${dist}/${comp}/${binary}/Packages.bz2
        lz4 -c9 dists/${dist}/${comp}/${binary}/Packages > dists/${dist}/${comp}/${binary}/Packages.lz4

		$FTPARCHIVE contents pool/${comp}/${dist} > \
			dists/${dist}/${comp}/${contents}
		xz -c9 dists/${dist}/${comp}/${contents} > dists/${dist}/${comp}/${contents}.xz
        xz -5fkev --format=lzma dists/${dist}/${comp}/${contents} > dists/${dist}/${comp}/${contents}.lzma
		zstd -q -c19 dists/${dist}/${comp}/${contents} > dists/${dist}/${comp}/${contents}.zst
        gzip -c9 dists/${dist}/${comp}/${contents} > dists/${dist}/${comp}/${contents}.gz
        bzip2 -c9 dists/${dist}/${comp}/${contents} > dists/${dist}/${comp}/${contents}.bz2
        lz4 -c9 dists/${dist}/${comp}/${contents} > dists/${dist}/${comp}/${contents}.lz4

		$FTPARCHIVE release -c config/${arch}-basic.conf dists/${dist}/${comp}/${binary} > dists/${dist}/${comp}/${binary}/Release 2>/dev/null
	done

	$FTPARCHIVE release -c config/${arch}-basic.conf dists/${dist} > dists/${dist}/Release 2>/dev/null

	gpg -vabs -u $GPG_KEY -o dists/${dist}/Release.gpg dists/${dist}/Release
	gpg --clear-sign -u $GPG_KEY -o dists/${dist}/InRelease dists/${dist}/Release
done