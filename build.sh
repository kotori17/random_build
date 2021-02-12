#!/bin/bash
apt update && apt install -y ccache wget bc build-essential make autoconf automake curl git
# Export
export TELEGRAM_TOKEN
export TELEGRAM_CHAT
export ARCH="arm"
export SUBARCH="arm"
export KBUILD_BUILD_USER="wulan17"
export KBUILD_BUILD_HOST="CircleCI"
export branch="staging/4.9.190"
export device="cactus"
export LOCALVERSION="-wulan17"
export kernel_repo="https://github.com/Ghost719/android_kernel_xiaomi_mt6765.git"
export tc_repo="https://github.com/wulan17/linaro_arm-linux-gnueabihf-7.5.git"
export tc_name="arm-linux-gnueabihf"
export tc_branch="master"
export tc_v="7.5"
export zip_name="kernel-""$device""-Q-"$(env TZ='Asia/Jakarta' date +%Y%m%d)""
export KERNEL_DIR=$(pwd)
export KERN_IMG="$KERNEL_DIR"/kernel/out/arch/"$ARCH"/boot/zImage-dtb
export ZIP_DIR="$KERNEL_DIR"/AnyKernel
export CONFIG_DIR="$KERNEL_DIR"/kernel/arch/"$ARCH"/configs
export CORES=$(grep -c ^processor /proc/cpuinfo)
export THREAD="-j$CORES"
CROSS_COMPILE+="ccache "
CROSS_COMPILE+="$KERNEL_DIR"/"$tc_name"-"$tc_v"/bin/"$tc_name"-
export CROSS_COMPILE

function sync(){
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$branch" "$kernel_repo" --depth 1 kernel > /dev/null
	cd "$KERNEL_DIR" && git clone --quiet "$THREAD" -b "$tc_branch" "$tc_repo" --depth 1 "$tc_name"-"$tc_v" > /dev/null
	chmod -R a+x "$KERNEL_DIR"/"$tc_name"-"$tc_v"
}
function build(){
	BUILD_START=$(date +"%s")
	cd "$KERNEL_DIR"/kernel
	export last_tag=$(git log -1 --oneline)
	script "$KERNEL_DIR"/kernel.log -c 'make O=out '"$device"'_defconfig '"$THREAD"' && make '"$THREAD"' O=out'
}
function success(){
	curl -s -v -F "chat_id=$TELEGRAM_CHAT" -F document=@"$ZIP_DIR"/"$zip_name".zip -F "parse_mode=html" -F caption="Build completed successfully in $((BUILD_DIFF / 60)):$((BUILD_DIFF % 60))
	Dev : ""$KBUILD_BUILD_USER""
	Product : Kernel
	Device : #""$device""
	Branch : ""$branch""
	Host : ""$KBUILD_BUILD_HOST""
	Commit : ""$last_tag""
	Compiler : ""$(${CROSS_COMPILE}gcc --version | head -n 1)""
	Date : ""$(env TZ=Asia/Jakarta date)""" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument

	curl -s -v -F "chat_id=$TELEGRAM_CHAT" -F document=@"$KERNEL_DIR"/kernel.log https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument > /dev/null
	exit 0
}
function failed(){
	curl -s -v -F "chat_id=$TELEGRAM_CHAT" -F document=@"$KERNEL_DIR"/kernel.log -F "parse_mode=html" -F "caption=Build failed in $((BUILD_DIFF / 60)):$((BUILD_DIFF % 60))" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument > /dev/null
	exit 1
}
function check_build(){
	if [ -e "$KERN_IMG" ]; then
		cp "$KERN_IMG" "$ZIP_DIR"/zImage
		cp "$DTBO" "$ZIP_DIR"/
		cd "$ZIP_DIR"
		zip -r "$zip_name".zip ./*
		success
	else
		failed
	fi
}
function main(){
	sync
	build
	check_build
}

main
