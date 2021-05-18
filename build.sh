#!/bin/bash

pacman -Sy
pacman -S --noconfirm wget jdk15-openjdk git python python-pip
# use all possible cores for subsequent package builds
sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf
sed -i 's,!ccache,ccache,g' /etc/makepkg.conf
cp jdk/* /home/wulan17/
cp -r upload /home/wulan17
chown -R wulan17 /home/wulan17
cd /home/wulan17/
export BUILD_START=$(date +"%s")
cd /home/wulan17
su wulan17 -c 'makepkg -s --noconfirm'
export BUILD_END=$(date +"%s")
if [[ ! -z $(ls *jdk*.pkg.* | cut -d "/" -f 5) ]]; then
	export filename="$(ls *jdk*.pkg.*)"
	export headername="$(ls *jre*.pkg.*)"
	#curl -F secret="$ci_secret" -F document=@"$(pwd)"/"$filename" -F caption="Build success\nFilename: $filename" https://ci.wulan17.my.id/sendDocument
	#curl -F secret="$ci_secret" -F document=@"$(pwd)"/"$headername" -F caption="Build success\nFilename: $headername" https://ci.wulan17.my.id/sendDocument
	pacman -Syu --noconfirm
	su wulan17 -c 'pip install -r /home/wulan17/upload/requirements.txt'
	su wulan17 -c "bash /home/wulan17/upload/up.sh /home/wulan17/*jdk*.pkg.tar*"
	su wulan17 -c "bash /home/wulan17/upload/up.sh /home/wulan17/*jre*.pkg.tar*"
	exit 0
else
	exit 1
fi
