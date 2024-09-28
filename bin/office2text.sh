#!/bin/sh
# LibreOffice (soffice) 使って Office 系ファイル
# ・Word
# ・LibreOffice
# のファイルのテキストデータを標準出力に出力

soffice --convert-to "txt:Text (encoded):UTF8" --cat "$1"
# 図中の文字の出力
case "$1" in
	*.docx )
		unzip -cjq "$1" word/document.xml | # ドキュメント部分のみ解凍
			sed -E -e 's;(<w:txbxContent>);\n\1;g' -e 's;(</w:txbxContent>);\1\n;g' | # 図形タグ前後で改行
			grep "<w:txbxContent>" | # 図中の文字の行だけにする
			sed -E -e 's;<w:txbxContent>(.+)</w:txbxContent>;\1;g' | # 図中文字列の抽出
			sed -E -e 's;<w:(p\>[^>]*|br\>[^>]*/)>;\n;g' -e 's/<[^>]+>//g'  # タグ変換や削除
		;;
	*.odt )
		unzip -cjq "$1" content.xml |
			sed -E -e 's;(<text:span text:style-name="T[0-9]+">);\n\1;g' -e 's;(</text:span>);\1\n;g' |
			grep -E '<text:span text:style-name="T[0-9]+">' |
			sed -E 's/<[^>]+>//g'
		;;
	*)
		:
esac

exit 0

