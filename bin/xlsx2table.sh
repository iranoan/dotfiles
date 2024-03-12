#!/bin/sh
# スプレッドシートを | で列の揃った形式で出力
#
# ssconvert.sh を呼び出し、その出力を処理すると、シートごとに列幅が異なると見にくくなる

csv=$HOME/.tmp/$(basename $1).csv
ssconvert --export-file-per-sheet "$1" "$csv" 1>/dev/null 2>&1

for f in "$csv".*
do
	"$HOME/bin/csv2tsv.awk" "$f" | "$HOME/bin/tsv2table.awk"
	echo ''
	rm "$f"
done
