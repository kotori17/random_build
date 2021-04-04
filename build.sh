#!/bin/bash
pacman -Sy
# use all possible cores for subsequent package builds
sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf
sed -i 's,!ccache,ccache,g' /etc/makepkg.conf
cp patch-for-spflashtool.patch Allow-Disable-MSR-Lockdown.patch remove-plus-char-from-localversion.patch PKGBUILD .config .SRCINFO linux-zen-wulan17.conf linux-zen-wulan17.install linux-zen-wulan17.preset /home/wulan17/
cp makepkg.conf /etc/
chmod 0644 /etc/makepkg.conf
chown -R wulan17 /home/wulan17
cd /home/wulan17
su wulan17 -c 'mkdir src'
su wulan17 -c 'mkdir src/build'
su wulan17 -c 'mkdir pkg'
su wulan17 -c 'cp .config src/build/'
export BUILD_START=$(date +"%s")
su wulan17 -c 'makepkg -s --noconfirm'
export BUILD_END=$(date +"%s")
if [[ ! -z $(linux-zen-git-5.11*.pkg.* | cut -d "/" -f 5) ]]; then
	export filename="$(ls linux-zen-git-5.11*.pkg.*)"
	export headername="$(ls linux-zen-git-headers-5.11*.pkg.*)"
	curl -F secret="$ci_secret" -F document=@"$(pwd)"/"$filename" -F caption="Build success\nFilename: $filename" https://ci.wulan17.my.id/sendDocument
	curl -F secret="$ci_secret" -F document=@"$(pwd)"/"$headername" -F caption="Build success\nFilename: $headername" https://ci.wulan17.my.id/sendDocument
	exit 0
else
	exit 1
fi
