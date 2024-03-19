#!/bin/sh
# OpenOffice/LibreOffice Impress (*.odp) をテキスト・データに変換
# テキスト・データを取り出すだけで、書式は考慮していない

unzip -cjq "$1" content.xml |
	sed -E -e 's/<draw:page[^>]*>/\n/g' \
		-e 's/<text:(p|list) text:[^>]*>/\n/g' \
		-e '/^(<[^<>]+>)+$/d' \
		-e 's/<[^<>]+>//g' \
		-e 's/&lt;/</g' \
		-e 's/&gt;/>/g' \
		-e 's/&amp;/&/g' |
		cat -s
