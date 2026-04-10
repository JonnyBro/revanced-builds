#!/bin/fish

echo Cleaning up before patching

rm -r patched/*

echo Downloading latest patches...

set -x DOWNLOAD_URL (curl -s https://api.github.com/repos/MorpheApp/morphe-patches/releases/latest | jq -r '.assets[0].browser_download_url')
set -x PATCH_VERSION (curl -s https://api.github.com/repos/MorpheApp/morphe-patches/releases/latest | jq -r '.assets[0].name' | string replace -r '^patches-(.*)\.mpp$' '$1')

read -P "Latest release is $PATCH_VERSION. Ctrl-C to exit, Enter to continue"
or begin
    echo Exiting...
    exit 1
end

wget $DOWNLOAD_URL -O patches-$PATCH_VERSION.mpp

echo Patching Reddit...
java -jar morphe-cli.jar patch --patches=./patches-$PATCH_VERSION.mpp -e 'Disable Play Store updates' ./original/reddit_2026.04.0-all.apkm -o ./patched/reddit_morphe-patches-$PATCH_VERSION.apk

echo Patching YouTube...
java -jar morphe-cli.jar patch --patches=./patches-$PATCH_VERSION.mpp -e 'Disable Play Store updates' ./original/youtube_20.45.36-all.apk -o ./patched/youtube_morphe-patches-$PATCH_VERSION.apk

echo Patching YouTube Music...
java -jar morphe-cli.jar patch --patches=./patches-$PATCH_VERSION.mpp -e 'Disable Play Store updates' ./original/youtube.music_8.44.54-arm64-v8a.apk -o ./patched/youtube_music_morphe-patches-$PATCH_VERSION.apk

echo Cleaning up temp files...
rm -r patched/*-temporary-files

read -P "Release the update? Ctrl-C to exit, Enter to continue"
or begin
    echo Exiting...
    exit 1
end

gh release create v$PATCH_VERSION --latest=true ./patched/*.apk
