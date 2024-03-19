#!/bin/sh
# パワーポイント (*.pptx) をテキスト・データに変換
# テキスト・データを取り出すだけで、書式は考慮していない

unzip -l "$1" |
	grep -E " ppt/slides/slide[0-9]+\.xml$" |
	awk -F' ' '{print $4}' |
	sort --key="4.6" --numeric-sort | while read -r f; do
		unzip -cjq "$1" "$f" |
		grep '<a:t>' |
		sed -E -e 's%</(p:sp|a:(p|br))>%\n%g' \
			-e 's/<[^<>]+>//g' \
			-e 's/&lt;/</g' \
			-e 's/&gt;/>/g' \
			-e 's/&amp;/&/g'
	done
