#!/bin/bash
pacman -Syu
pacman -S --noconfirm --needed base-devel git curl wget ccache gendesk git tar xz zstd python python-pip libpng12 gst-plugins-base-libs qt5 qt5-webkit
# use all possible cores for subsequent package builds
sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf
sed -i 's,!ccache,ccache,g' /etc/makepkg.conf
useradd --create-home wulan17
usermod --append --groups wheel wulan17
echo "wulan17 ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers
cp -r qt4 qtwebkit spflashtool-bin /home/wulan17/
chown -R wulan17 /home/wulan17
cd /home/wulan17
su wulan17 -c "git clone https://wulan17:$token@github.com/wulan17/credentials.git -b up upload" 
su wulan17 -c 'pip install telethon tgcrypto'
su wulan17 -c 'pip install -r upload/requirements.txt'
cd spflashtool-bin
su wulan17 -c 'makepkg -s --noconfirm'
ls -lah
su wulan17 -c "bash ../upload/up.sh $(pwd)/*.pkg.tar*"
