#!/bin/bash

# get environment variables
source env_vars.sh

cd ${KERNEL_DIR} || exit

#
# compilation
#
# First we need number of jobs
COUNT="$(grep -c '^processor' /proc/cpuinfo)"
export JOBS="8"

export ARCH=arm64
export SUBARCH=arm64

START=$(date +"%s")
make O=out ${DEFCONFIG}
if [[ ${COMPILER} == "GCC" ]]; then
	make -j${JOBS} O=out
else
	export KBUILD_COMPILER_STRING="$(${CLANG_PATH}/bin/clang --version | head -n 1 | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')";

	PATH="${CLANG_PATH}/bin:${PATH}" \
	make O=out -j${JOBS} \
	CC="clang" \
	CLANG_TRIPLE="aarch64-linux-gnu-" \
	CROSS_COMPILE="aarch64-linux-gnu-" \
	CROSS_COMPILE_ARM32="arm-linux-gnueabi-" \
	LD=ld.lld \
	AR=llvm-ar \
	NM=llvm-nm \
	OBJCOPY=llvm-objcopy \
	OBJDUMP=llvm-objdump \
	STRIP=llvm-strip
fi

END=$(date +"%s")
DIFF=$((END - START))

export OUT_IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image.gz"

# Move kernel image and dtb to anykernel3 folder
cp ${OUT_IMAGE} ${ANYKERNEL_DIR}
find out/arch/arm64/boot/dts -name '*.dtb' -exec cat {} + > ${ANYKERNEL_DIR}/dtb

# POST ZIP OR REPORT FAILURE
cd ${ANYKERNEL_DIR}
zip -r9 "${ZIPNAME}" -- *
# Weeb/Hentai patch for custom boot.img
mkbootimg=${PROJECT_DIR}/bin/mkbootimg
chmod 777 $mkbootimg

magiskboot=${PROJECT_DIR}/bin/magiskboot
chmod 777 $magiskboot
# Undo Magisk want_initramfs hack ('want_initramfs' -> 'skip_initramfs')
$magiskboot --decompress ${ANYKERNEL_DIR}/Image.gz ${ANYKERNEL_DIR}/Image;
# original: $bin/magiskboot --hexpatch $decompressed_image 736B69705F696E697472616D667300 77616E745F696E697472616D667300;
$magiskboot --hexpatch ${ANYKERNEL_DIR}/Image 77616E745F696E697472616D667300 736B69705F696E697472616D667300;
$magiskboot --compress=gzip ${ANYKERNEL_DIR}/Image ${ANYKERNEL_DIR}/Image.gz;

#mkdir -p ${script_dir}/out

export OS="10.0.0"
export SPL="2020-12"

$mkbootimg \
    --kernel ${ANYKERNEL_DIR}/Image.gz \
    --ramdisk ${PROJECT_DIR}/ramdisk.gz \
    --cmdline 'androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 swiotlb=2048 firmware_class.path=/vendor/firmware_mnt/image loop.max_part=7 androidboot.usbcontroller=a600000.dwc3 androidboot.vbmeta.avb_version=1.0 buildvariant=user' \
    --base           0x00000000 \
    --pagesize       4096 \
    --kernel_offset  0x00008000 \
    --ramdisk_offset 0x02000000 \
    --second_offset  0x00f00000 \
    --tags_offset    0x00000100 \
    --dtb            ${ANYKERNEL_DIR}/dtb \
    --dtb_offset     0x01f00000 \
    --os_version     $OS \
    --os_patch_level $SPL \
    --header_version 2 \
    -o ${script_dir}/out/${NEW_BOOT_IMG_NAME}
