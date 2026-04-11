#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q iris-emu | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook:wayland-is-broken.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/pixmaps/iris-emu.png
export DESKTOP=/usr/share/applications/iris-emu.desktop
export STARTUPWMCLASS=com.allkern.iris
export DEPLOY_VULKAN=1

# Deploy dependencies
quick-sharun /usr/bin/iris-emu

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
