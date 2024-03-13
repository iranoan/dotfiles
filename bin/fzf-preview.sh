#!/bin/sh
# fzf のプレビュー用
# ・テキストは less で用いている src-hilite-lesspipe.sh
# ・動画は画像に変換後、画像は nsxiv
# ・ディレクトリや圧縮ファイルは内部のファイル・リスト
# ・オフィスアプリは適当にテキスト変換
# ・これらに該当しないファイルはメタ情報

f=$( echo "$@"| sed -e "s>^~>$HOME>" -e "s/'/\\\'/g" -e 's/"/\\"/g' | xargs -I{} readlink -f "{}")
mime=$( mimetype --brief "$f" ) # file --dereference --brief --mime-type だと CSV の判定で間違えるケースが有る

sxiv_preview(){
	if command -v nsxiv > /dev/null ; then
		sxiv=nsxiv
	elif command -v sxiv > /dev/null ; then
		sxiv=sxiv
	else
		case "$( ps xo pid,comm | awk -F ' ' '/^\s*\<'$PPID'\>/{ print $2 }' )" in
			sh|ksh|ash|dash|bash|csh|tcsh|zsh|fish) echo 'require nsxiv or sxiv for preview' ;;
			*)
				if command -v zenity > /dev/null ; then
					zenity --warning --title="$sxiv" --text="require nsxiv or sxiv for preview" 2>/dev/null
				fi
				;;
		esac
		return 1
	fi
	ppid=$PPID
	ps_xo=$( ps xo pid,ppid,comm )
	wmctrl_lGp=$( wmctrl -lGp |
		grep -E '^0x[0-9a-f]+' |
		sed -E 's/(0x[0-9a-f]+) +-?[0-9]+ ([0-9]+) +-?[0-9]+ +-?[0-9]+ +([0-9]+) +([0-9]+) .+/\1\t\2\t\3\t\4/' )
	while true ; do # 呼び出し元の PID, WINID などを取得する
		win_id=$( echo "$wmctrl_lGp" | grep -Ei "^0x[0-9a-f]+[[:space:]]$ppid([[:space:]][0-9]+){2}$" )
		if [ -n "$win_id" ]; then
			width=$(( $( echo "$win_id" | cut -f3 ) / 2 ))
			height=$( echo "$win_id" | cut -f4 )
			win_id=$( echo "$win_id" | cut -f1 )
			break
		fi
		if ! echo "$ps_xo" | grep -Eq "^ *$ppid" ; then
			return 0
		fi
		ppid=$( echo "$ps_xo" | grep -E "^ *$ppid" )
		if echo "$ppid" | grep -Eq ' tmux: server$' ; then
			ppid=$( tmux list-clients -F '#{session_activity}:#{client_pid}' | sort | tail -n 1 | cut -d: -f2 )
		else
			ppid=$( echo "$ppid" | sed -E 's/ *[0-9]+ +([0-9]+) +.+/\1/' )
		fi
	done

	echo '' # 前に表示していたプレヴューをクリア
	$sxiv -e "$win_id" -g "${width}x${height}+${width}+0" --no-bar --scale-mode f --private "$1" & # & をなくしてもプロセスが残る点は変わらない+絞り込み入力側にフォーカスが戻らないことが増える印象
	wmctrl -ia "$win_id"
	return 1
}

echo "$f"
case "${f##*/}" in # ファイル名による分岐
	vimrc|gvimrc )
		source-highlight --failsafe -f esc --lang-def=vim.lang --style-file=esc.style -i "$f" ;;
	.bashrc|.bash_history|bashrc|.cshrc|.profile|.xprofile|.zshrc|.kshrc )
		source-highlight --failsafe -f esc --lang-def=sh.lang --style-file=esc.style -i "$f" ;;
	.*rc|.gitconfig|.gitattributes|.gitignore )
		source-highlight --failsafe -f esc --lang-def=conf.lang --style-file=esc.style -i "$f" ;;
	*)
		case "${f%/*}" in # ディレクトリ名による分岐
			*/.bash|*/.csh|*/.ksh|*/.zsh )
				source-highlight --failsafe -f esc --lang-def=sh.lang --style-file=esc.style -i "$f" ;;
			*)
				case "$mime" in # mimetype による分岐
					inode/directory )              tree -L 1 -C "$f" ;;
					application/json )             jq -C . "$f" ;;
					application/zip )              unzip -l "$f" ;;
					application/gzip )             gzip --list "$f" ;;
					application/x-compressed-tar ) gzip --list "$f" ;;
					application/x-xz|application/x-xz-compressed-tar ) xz --list "$f" ;;
					application/x-lha )            jlha l "$f" ;;
					application/pdf )              pdftotext "$f" - ;;
					application/vnd.sqlite3)       echo .dump|sqlite3 "$f" ;;
					audio/* )                      ffmpeg -hide_banner -i "$f" -f metadata - | tail -n +2 ;;
					text/csv)                      nkf -wd "$f" | ~/bin/csv2tsv.awk | tsv2table.awk ;;
					text/tab-separated-values|text/tsv) nkf -wd "$f" | ~/bin/tsv2table.awk ;;
					text/*|application/xhtml+xml|application/javascript|application/rdf+xml|application/toml|application/x-awk|application/x-desktop|application/x-gnuplot|application/x-perl|application/x-php|application/x-ruby|application/x-shellscript|application/x-troff-man|application/x-yaml|application/xml )
						/usr/share/source-highlight/src-hilite-lesspipe.sh "$f" ;;
					application/vnd.openxmlformats-officedocument.wordprocessingml.document|application/vnd.oasis.opendocument.text )
						soffice --convert-to "txt:Text (encoded):UTF8" --cat "$f" ;;
					application/vnd.ms-excel|application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|application/vnd.oasis.opendocument.spreadsheet )
						~/bin/xlsx2table.sh "$f" ;;
					image/* )
						if sxiv_preview "$f"; then
							exiftool "$f"
						fi
						;;
					video/* )
						time=$( ffmpeg -hide_banner -i "$f" 2>&1 |
							awk '/^\s*Duration:/{
								split($2, t, /[:,]/)
								printf("%d", ( t[1] * 3600 + t[2] * 60 + t[3] ) / 2)
							}'
						)
						time=$(( time / 2 ))
						ffmpeg -ss $time -i "$f" -frames:v 1 -y "$HOME/.tmp/tmp-move-sixv.jpg" 2> /dev/null
						if sxiv_preview "$HOME/.tmp/tmp-move-sixv.jpg" ; then
							ffmpeg -hide_banner -i "$f" -f metadata - | tail -n +2
						fi
						;;
					*)                             echo "$mime" ;;
				esac
				;;
		esac
		;;
esac

exit 0
