#!/bin/fish

echo Downloading latest patches...

set -x DOWNLOAD_URL (curl -s https://api.github.com/repos/MorpheApp/morphe-patches/releases/latest | jq -r '.assets[0].browser_download_url')
set -x PATCH_VERSION (curl -s https://api.github.com/repos/MorpheApp/morphe-patches/releases/latest | jq -r '.assets[0].name' | string replace -r '^patches-(.*)\.mpp$' '$1')

wget $DOWNLOAD_URL -O patches.mpp

echo Patching Reddit...
java -jar morphe-cli.jar patch --patches=./patches.mpp -e 'Disable Play Store updates' ./original/reddit_2026.04.0-all.apkm -o ./patched/reddit_morphe-patches-$PATCH_VERSION.apk

echo Patching YouTube...
java -jar morphe-cli.jar patch --patches=./patches.mpp -e 'Disable Play Store updates' ./original/youtube_20.45.36-all.apk -o ./patched/youtube_morphe-patches-$PATCH_VERSION.apk

echo Patching YouTube Music...
java -jar morphe-cli.jar patch --patches=./patches.mpp -e 'Disable Play Store updates' ./original/youtube.music_8.44.54-arm64-v8a.apk -o ./patched/youtube_music_morphe-patches-$PATCH_VERSION.apk

echo Cleaning up temp files...
rm -r patched/*-temporary-files

echo Press 'Y/y' to release update
read -x CONFIRM

if string lower $CONFIRM | string match -q y
	gh release create v$PATCH_VERSION --latest=true ./patched/*.apk
end
