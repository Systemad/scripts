#!/bin/bash


mkdir -p ${HOME}/Documents/Android

cd ${HOME}/Documents/Android

# get environment variables
source env_vars.sh

git clone https://github.com/idkwhoiam322/AnyKernel3.git -b op7 --depth=1 anykernel3
git clone https://github.com/idkwhoiam322/weeb_kernel_oneplus_sm8150

if [[ ${COMPILER} == "GCC" ]]; then
	git clone https://github.com/arter97/arm64-gcc.git -b master --depth=1 gcc
	git clone https://github.com/arter97/arm32-gcc.git -b master --depth=1 gcc32
else
#	Proton Clang by @kdrag0n
	git clone https://github.com/kdrag0n/proton-clang.git --depth=1 clang
	cd ${PROJECT_DIR}/clang
	cd ${PROJECT_DIR}
fi
