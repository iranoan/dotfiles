#!/bin/sh
# fzf のプレビュー用
# ・テキストは less で用いている source-highlight
# ・動画は画像に変換後、画像ビューワを用いる
# ・画像ビューワとしては
# 	* nsxiv もしくは Sixel 対応アプリで img2sixel がありそれを使う
# 	* Windows ID の取得ができず、nsxiv があれば別ウィンドウをモニター右上に表示
# 	* Sixel を使う場合は、展開が遅いのでプレビューが上手くできないことも多い
# 		- fzf-tmux は Sixel 未対応なので注意
# 		- tmux を使っている場合は前のプレビュー内容が残ることも多い
# ・ディレクトリや圧縮ファイルは内部のファイル・リスト
# ・オフィスアプリは適当にテキスト変換
# ・これらに該当しないファイルはメタ情報

f=$( echo "$@"| sed -e "s>^~>$HOME>" -e "s/'/\\\'/g" -e 's/"/\\"/g' | xargs -I{} readlink -f "{}")
mime=$( mimetype --brief "$f" ) # file --dereference --brief --mime-type だと CSV の判定で間違えるケースが有る

sxiv_sixel(){ # 環境によって sxiv と Sixel を使い分ける
	# if [ "$2" = "wezterm" ] || [ "$2" = "wezterm-gui" ] ; then # fzf が 未対応のようで imgcat が使えない
	# 	if ! ps --cols 1000 xo pid,comm | grep -E "^ *$( pgrep -P "$1" ) " | grep -q 'tmux: client' ; then
	# 		wezterm imgcat "$3"
	# 		return 1
	# 	fi
	# fi
	if command -v nsxiv > /dev/null ; then
		sxiv=nsxiv
	elif command -v sxiv > /dev/null ; then
		sxiv=sxiv
	fi
	if command -v img2sixel > /dev/null ; then
		case "$2" in
			xterm|mlterm|wezterm|wezterm-gui) sixel=1 ;; # Sixel 対応ターミナル
			*)                                sixel=0 ;;
		esac
	fi
	win_id=$( wmctrl -lGp | grep -E "^0x[0-9a-f]+ +-?[0-9]+ +$1 " )
	if [ -n "$win_id" ]; then
		width=$(( $( echo "$win_id" | awk '{print $6}' ) / 2 ))
		d_height=$(( 14 * 2 * 2 * 72 / 96 )) # フォント・サイズ 14pt を基準としたオフセット
		height=$(($( echo "$win_id" | awk '{print $7}') - d_height))
		win_id=$( echo "$win_id" | awk '{print $1}' )
		if [ -n "$sxiv" ]; then
			$sxiv -e "$win_id" -g "${width}x${height}+${width}+$d_height" --no-bar --scale-mode f --private "$3" & # & をなくしてもプロセスが残る点は変わらない+絞り込み入力側にフォーカスが戻らないことが増える印象
			return 1
		elif [ "$sixel" -eq 1 ]; then
			img2sixel -w "$width" "$3"
			return 1
		fi
	elif [ "$sixel" -eq 1 ]; then
		img2sixel -w "$(( $FZF_PREVIEW_COLUMNS * 14 * 72 * 8 / 960 ))" "$3" # フォント・サイズ 14pt を基準としたいが、大きいと上手くプレビューできないので *0.8 している
		return 1
	elif [ -n "$sxiv" ]; then
		$sxiv -g -0+0 --no-bar --scale-mode f --private "$3" &
		return 1
	fi
	return 0
}

preview_img(){ # 呼び出し元アプリ名の取得し画像プレビューを呼び出す
	ppid=$PPID
	ps_xo=$( ps --cols 1000 xo pid,ppid,comm | tail -n +2 )
	while true ; do # 呼び出し元の PID, WINID などを取得する
		pid=$( echo "$ps_xo" | grep -E "^ *$ppid " )
		app=$( echo "$pid" | awk '{print $3$4}')
		ppid=$( echo "$pid" | awk '{print $2}')
		pid=$( echo "$pid" | awk '{print $1}')
		case "$app" in # 呼び出し元として使っているアプリを並べる
			gvim|nvim-qt|mlterm|xterm|tilda|wezterm|wezterm-gui|gnome-terminal-|guake)
				sxiv_sixel "$pid" "$app" "$1"
				return $?
				;;
			vim|nvim)
				if ps --cols 1000 xo pid,comm,args | grep -E "^ *$pid +n?vim " | grep -qE ' -g\>' ; then # -g オプション付きで起動した Vim→GVim
					sxiv_sixel "$pid" "$app" "$1"
					return $?
				else
					continue
				fi
				;;
			tmux:server)
				ppid=$( tmux list-clients -F '#{session_activity}:#{client_pid}' | sort | tail -n 1 | cut -d: -f2 )
				continue
				;;
			flatpak-session)
				ppid=$( ps --cols 1000 xo ppid,args | grep -E '^ *[0-9]+ +flatpak-spawn .+ --env=TERM_PROGRAM=' | awk '{print $1}')
				continue
				;;
			*) continue ;;
		esac
		break
	done
}

echo "$f"
case "${f##*/}" in # ファイル名による分岐
	vimrc|gvimrc )
		source-highlight --tab=2 --failsafe -f esc --lang-def=vim.lang --style-file=esc.style -i "$f" ;;
	.bashrc|.bash_history|.cshrc|.profile|.xprofile|.kshrc )
		source-highlight --tab=2 --failsafe -f esc --lang-def=sh.lang --style-file=esc.style -i "$f" ;;
	.zshrc )
		source-highlight --tab=2 --failsafe -f esc --lang-def=zsh.lang --style-file=esc.style -i "$f" ;;
	.*rc|.gitconfig|.gitattributes|.gitignore )
		source-highlight --tab=2 --failsafe -f esc --lang-def=conf.lang --style-file=esc.style -i "$f" ;;
	*ChangeLog|*changelog)
		source-highlight --failsafe -f esc --lang-def=changelog.lang --style-file=esc.style -i "$f" ;;
	*Makefile|*makefile)
		source-highlight --failsafe -f esc --lang-def=makefile.lang --style-file=esc.style -i "$f" ;;
	*)
		case "${f%/*}" in # ディレクトリ名による分岐
			*/.bash|*/.csh|*/.ksh|*/.config/bash|*/.config/csh|*/.config/ksh|*/.config/fzf )
				source-highlight --tab=2 --failsafe -f esc --lang-def=sh.lang --style-file=esc.style -i "$f" ;;
			*/.zsh|*/.config/zsh )
				source-highlight --tab=2 --failsafe -f esc --lang-def=zsh.lang --style-file=esc.style -i "$f" ;;
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
						source-highlight --tab=2 --failsafe --infer-lang -f esc --style-file=esc.style -i "$f" ;;
					application/msword|application/vnd.openxmlformats-officedocument.wordprocessingml.document|application/vnd.oasis.opendocument.text )
						soffice --convert-to "txt:Text (encoded):UTF8" --cat "$f" 2> /dev/null ;;
					application/vnd.openxmlformats-officedocument.presentationml.presentation )
						~/bin/pptx2text.sh "$f" ;;
					application/vnd.oasis.opendocument.presentation )
						~/bin/odp2text.sh "$f" ;;
					application/vnd.ms-excel|application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|application/vnd.oasis.opendocument.spreadsheet )
						xlsx2table.sh "$f" ;;
					image/* )
						if preview_img "$f"; then
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
						ffmpeg -ss $time -i "$f" -frames:v 1 -y "$HOME/.cache/tmp-move-sixv.jpg" 2> /dev/null
						if preview_img "$HOME/.cache/tmp-move-sixv.jpg" ; then
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
