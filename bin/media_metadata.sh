#!/bin/sh
# 動画・音声のメタデータ表示
# git diff で用いる

ffmpeg -hide_banner -i "$1" -f metadata - 2>&1 /dev/null | tail -n +2

exit 0
