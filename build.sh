#!/bin/bash
# use all possible cores for subsequent package builds
#sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf
#sed -i 's,!ccache,ccache,g' /etc/makepkg.conf
cp PKGBUILD .SRCINFO linux-zen-wulan17.conf linux-zen-wulan17.install linux-zen-wulan17.preset config /home/wulan17/
cp makepkg.conf /etc/
chmod 0644 /etc/makepkg.conf
chown -R wulan17 /home/wulan17
cd /home/wulan17
su wulan17 -c 'mkdir src'
su wulan17 -c 'mkdir src/build'
su wulan17 -c 'mkdir pkg'
su wulan17 -c 'cp config src/build/.config'
su wulan17 -c 'chown -R wulan17 /home/wulan17/src/build'
cd /home/wulan17
export BUILD_START=$(date +"%s")
su wulan17 -c 'makepkg -s --noconfirm'
export BUILD_END=$(date +"%s")
if [[ ! -z $(ls linux-zen-git-5.12*.pkg.* | cut -d "/" -f 5) ]]; then
	export filename="$(ls linux-zen-git-5.18*.pkg.*)"
	export headername="$(ls linux-zen-git-headers-5.18*.pkg.*)"
	curl -X "POST" -F secret="$ci_secret4" -F document=@"$(pwd)"/"$filename" https://wulan17.my.id:8443/gd
	curl -X "POST" -F secret="$ci_secret4" -F document=@"$(pwd)"/"$headername" https://wulan17.my.id:8443/gd
	exit 0
else
	exit 1
fi
