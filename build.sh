#!/bin/bash
export repo="scrcpy"
pacman -Syu
pacman -S --noconfirm --needed base-devel git curl wget ccache git tar xz zstd python python-pip
# use all possible cores for subsequent package builds
sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf
sed -i 's,!ccache,ccache,g' /etc/makepkg.conf
useradd --create-home wulan17
usermod --append --groups wheel wulan17
echo "wulan17 ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers
chown -R wulan17 /home/wulan17
cd /home/wulan17
su wulan17 -c "git clone https://wulan17:$token@github.com/wulan17/credentials.git -b up upload" 
su wulan17 -c 'pip install telethon tgcrypto'
su wulan17 -c 'pip install -r upload/requirements.txt'
su wulan17 -c "git clone https://aur.archlinux.org/$repo.git" 
cd "$repo"
su wulan17 -c 'makepkg -s --noconfirm'
ls -lah
su wulan17 -c "bash ../upload/up.sh $(pwd)/*.pkg.tar*"
