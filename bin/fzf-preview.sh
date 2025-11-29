#!/bin/sh
# fzf のプレビュー用
# ・テキストは less で用いている source-highlight
# ・動画は画像に変換後、画像ビューワを用いる
# ・画像ビューワとしては
# 	* nsxiv/sxiv もしくは Sixel 対応アプリで img2sixel が有ればそれを使う
# 	* Windows ID の取得ができず、nsxiv/sxiv があれば別ウィンドウをモニター右上に表示
# 		- フォーカスが奪われるので使いにくい
# 	* Sixel を使う場合
# 		- tmux を使っている場合は前のプレビュー内容が残る
# 		- fzf-tmux は実際に tmux 上だと
# 			* -w, -h, -p オプションを使う
# 			* 一つのウィンドウで複数のペインを開いている
# 			と画像が表示されないので注意
# ・ディレクトリや圧縮ファイルは内部のファイル・リスト
# ・オフィスアプリは適当にテキスト変換
# ・これらに該当しないファイルはメタ情報

f=$( echo "$@"| sed -e "s>^~>$HOME>" -e "s/'/\\\'/g" -e 's/"/\\"/g' | xargs -I{} readlink -f "{}")
mime=$( mimetype --brief "$f" ) # file --dereference --brief --mime-type だと CSV の判定で間違えるケースが有る

use_sixel (){ # 表示サイズが大きいと上手くプレビューできないの表示サイズを計算して Sixel で表示する
	# フォント・サイズを取得し、それを基準としたいが、よく使う 14pt を基準としてする
	# +端数を扱えない+フォントのpt↔px 変換が有るので、計算に *72, *1000*96 が登場する
	width=$(( ( FZF_PREVIEW_COLUMNS ) * 14 * 72 ))
	height=$(( ( FZF_PREVIEW_LINES ) * 14 * 2 * 72 ))
	w_percent=$(( $1 * 1000 * 96 / width ))
	h_percent=$(( $2 * 1000 * 96 / height ))
	if [ $w_percent -gt $h_percent ]; then
		width=$(( width / 96 ))
		img2sixel -w "$width" "$3"
	else
		height=$(( height / 96 ))
		img2sixel -h "$height" "$3"
	fi
}

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
	i_width="$( identify "$3" | awk '{print $3}' )"
	i_height=$( echo "$i_width" | awk -F'x' '{print $2}' )
	i_width=$( echo "$i_width" | awk -F'x' '{print $1}' )
	win_id=$( wmctrl -lGp | grep -E "^0x[0-9a-f]+ +-?[0-9]+ +$1 " )
	if [ -n "$win_id" ]; then
		width=$(( $( echo "$win_id" | awk '{print $6}' ) / 2 ))
		d_height=$(( 14 * 2 * 2 * 72 * $4 / 96 )) # フォント・サイズ 14pt を基準としたオフセット
		height=$(($( echo "$win_id" | awk '{print $7}') - d_height))
		win_id=$( echo "$win_id" | awk '{print $1}' )
		if [ -n "$sxiv" ]; then
			w_percent=$(( i_width * 1000 / width ))
			h_percent=$(( i_height * 1000 / height ))
			if [ $w_percent -gt $h_percent ]; then # ↓の プログラム実行時に & をなくしてもプロセスが残る点は変わらない
				# ただし絞り込み入力側にフォーカスが戻らないことが増える印象
				height=$(( height * h_percent / w_percent ))
				$sxiv -e "$win_id" -g "${width}x${height}+${width}+$d_height" --no-bar --scale-mode f --private "$3" &
			else
				i_width=$(( width * w_percent / h_percent ))
				$sxiv -e "$win_id" -g "${i_width}x${height}+${width}+$d_height" --no-bar --scale-mode f --private "$3" &
			fi
		elif [ "$sixel" -eq 1 ]; then
			use_sixel "$i_width" "$i_height" "$3"
		fi
		return 1
	elif [ "$sixel" -eq 1 ]; then
		use_sixel "$i_width" "$i_height" "$3"
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
			tilda|wezterm|wezterm-gui)
				sxiv_sixel "$pid" "$app" "$1" 1
				return $?
				;;
			gvim|nvim-qt|mlterm|xterm|gnome-terminal*|guake|ptyxis-agent|ptyxis)
				sxiv_sixel "$pid" "$app" "$1" 2
				return $?
				;;
			vim|nvim)
				if ps --cols 1000 xo pid,comm,args | grep -E "^ *$pid +n?vim " | grep -qE ' -g\>' ; then # -g オプション付きで起動した Vim→GVim
					sxiv_sixel "$pid" "$app" "$1" 2
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

if [ "$mime" = "inode/directory" ]; then
	ls --color=always --group-directories-first -lhG "$f"
	exit 0
fi
printf '%s %s\n' \
	"$( find "${f%/*}" -name "${f##*/}" -printf "%p\n%TF %TR %s" | sed -E "s<^$HOME<~<" )" \
	"$( namei "$@" | grep -E '^ l ' | sed -E -e 's/^ l //' -e "s< -> $HOME< -> ~<")"
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
					application/json )             jq -C . "$f" ;;
					application/zip )              unzip -l "$f" ;;
					application/gzip )             gzip --list "$f" ;;
					application/x-compressed-tar ) gzip --list "$f" ;;
					application/x-xz|application/x-xz-compressed-tar ) xz --list "$f" ;;
					application/x-lha )            jlha l "$f" ;;
					application/pdf )              pdftotext "$f" - ;;
					application/vnd.sqlite3)       echo .dump|sqlite3 "$f" ;;
					application/epub+zip)
						gnome-epub-thumbnailer "$f" "$HOME/.cache/tmp-move-sixv.jpg"
						if preview_img "$HOME/.cache/tmp-move-sixv.jpg" ; then
							echo "$mime"
						fi
						;;
					application/x-mobipocket-ebook|application/vnd.amazon.mobi8-ebook)
						gnome-mobi-thumbnailer "$f" "$HOME/.cache/tmp-move-sixv.jpg"
						if preview_img "$HOME/.cache/tmp-move-sixv.jpg" ; then
							echo "$mime"
						fi
						;;
					audio/* )                      ffmpeg -hide_banner -i "$f" -f metadata - | tail -n +2 ;;
					text/csv)                      nkf -wd "$f" | ~/bin/csv2tsv.awk | ~/bin/tsv2table.awk ;;
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
					image/x-gqv|image/gqv )
						source-highlight --tab=2 --failsafe -f esc --lang-def=conf.lang --style-file=esc.style -i "$f" ;;
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
