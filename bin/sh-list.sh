#!/bin/sh
# ~/bin/, ~/bin にある *.sh のシェルスクリプトの一覧を作成
# ファイル名とともに、そのファイルの先頭に有るコメントを表示
# たいていファイルの先頭部分に簡単な説明を書いているので
# ただし自分自身は除く
# 思いつくシェルのシバンとデバッグ目的で書いてそうな記述削除

find -L "$HOME/bin/" -maxdepth 1 -type f \( -name "*.sh" -a ! -name "${0##*/}" \) |
	sort |
	while read -r f ; do
	printf '\033[1;7m%s\033[0;m\n' "${f##*/}"
	awk '{
		if ( /^$/ )exit
		if ( /^#/ && !/^#!\/bin\/(ba|a|da|c|tc|z|k|fi)?sh/ && !/^\s*#?\s*set -[xe]/ ) {
			gsub("^#", "    ", $0 )
			print $0
		}
	}' "$f"
	done | less

exit 0
