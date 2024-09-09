#!/bin/sh
# スプレッドシートを CSV に変換

csv=$HOME/.local/state/tmp/$(basename $1).csv
ssconvert --export-file-per-sheet "$1" "$csv" 1>/dev/null 2>&1

for f in "$csv".*
do
	cat "$f"
	echo ''
	rm "$f"
done
