#!/bin/bash


mkdir -p ${HOME}/Documents/Android/twrp

cd ${HOME}/Documents/Android/twrp

# Repo tool in order to sync sources
mkdir ~/bin
PATH=~/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

# Initialize twrp repo
repo init -u git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-10.0
