#!/bin/sh
# スプレッドシートを | で列の揃った形式で出力

ssconvert.sh "$1" |
	"$HOME/bin/csv2tsv.awk" |
	"$HOME/bin/tsv2table.awk"
