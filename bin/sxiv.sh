#!/bin/sh
# nsxiv/sxiv  の起動補助
# ・引数が無い時はカレント・ディレクトリ、引数がディレクトリならその直下の画像をサムネイル
# ・引数が画像のときも、同じフォルダの画像ファイルをサムネイルとして準備しおく
# ・ターミナルの fzf からの起動で Embed nsxiv/sxiv window が残るが、呼び出し元のシェル関数で対処する

if command -v nsxiv > /dev/null ; then
	sxiv=nsxiv
elif command -v sxiv > /dev/null ; then
	sxiv=sxiv
else
	case "$( ps xo pid,comm | awk -F ' ' '/^\s*\<'$PPID'\>/{ print $2 }' )" in
		sh|ksh|ash|dash|bash|csh|tcsh|zsh|fish) echo 'require nsxiv or sxiv' ;;
		*)
			if command -v zenity > /dev/null ; then
				zenity --warning --title="$sxiv" --text="require nsxiv or sxiv" 2>/dev/null
			fi
			;;
	esac
	exit 1
fi

open_img () {
	geometry=$(
	xrandr --current |
		awk 'BEGIN{
			x=1000000
			y=1000000
		}
		{
			if ( /^Screen [0-9]:/ ){
				width = $8
			}
			else if( /\*\+/ ){
				split($1, size, "x")
				if ( size[1] < x ){
					x = size[1]
				}
				if ( size[2] < y ){
					y = size[2]
				}
			}
		}
		END{
			x = x /2
			printf("%dx%d+%d+0", x, y / 2, width - x)
		}'
	)
	if [ -d "$1" ]; then # ディレクトリではサブディレクトリまで含めてサムネイル表示
		$sxiv -g "$geometry" --no-bar --thumbnail --scale-mode f --recursive "$1" &
	else
		case "$( file --brief --mime-type "$1" )" in
			image/*|application/postscript) # 画像ファイルでは、それを表示しつつ、カレント・ディレクトリ内の画像ファイルをサムネイルとして用意
				if command -v fdfind > /dev/null ; then
					list=$( fdfind -L --max-depth 1 --ignore-file ~/.fdignore \
						-e bmp -e cgm -e cr2 -e dll -e ico -e j2c -e j2k -e jp2 -e jpeg -e jpx -e mng -e nef -e nef -e pbm -e pcx -e pgm -e png -e png -e ppm -e svg -e svgz -e tga -e tif -e tiff -e webp -e xbm -e xcf -e xpm -e xwd -e yuv \
						. "${1%/*}" | sort --ignore-case )
				else
					list=$( find -L "${1%/*}" -maxdepth 1 -type f \( \
						-iname '*.bmp' -o -iname '*.cgm' -o -iname '*.cr2' -o -iname '*.dll' -o -iname '*.emf' -o -iname '*.eps' -o -iname '*.gif' -o -iname '*.ico' -o -iname '*.j2c' -o -iname '*.j2k' -o -iname '*.jp2' -o -iname '*.jpeg' -o -iname '*.jpf' -o -iname '*.jpg' -o -iname '*.jpg' -o -iname '*.jpx' -o -iname '*.mng' -o -iname '*.nef' -o -iname '*.nef' -o -iname '*.pbm' -o -iname '*.pcx' -o -iname '*.pgm' -o -iname '*.png' -o -iname '*.png' -o -iname '*.ppm' -o -iname '*.svg' -o -iname '*.svgz' -o -iname '*.tga' -o -iname '*.tif' -o -iname '*.tiff' -o -iname '*.webp' -o -iname '*.xbm' -o -iname '*.xcf' -o -iname '*.xpm' -o -iname '*.xwd' -o -iname '*.yuv' \
						\) -print 2> /dev/null | sort --ignore-case )
				fi
				count=$( grep --line-number --fixed-strings "$1" <<-_EOF_
				$list
				_EOF_
				)
				if [ -n "$count" ]; then
					$sxiv -g "$geometry" --no-bar --scale-mode f --stdin --start-at "${count%%:*}" -- <<-_EOF_ &
					$list
					_EOF_
				else
					$sxiv -g "$geometry" --no-bar --scale-mode f -- "$@" & # fallback
				fi
			;;
			*) # 他はメッセージを表示して終了
				# echo 'Not Image!' >&2
				zenity --warning --title=nsxiv --text="Not Image!" 2>/dev/null
				exit 1
				;;
		esac
	fi
}

[ "$1" = '--' ] && shift
case "$1" in
	# "") echo "Usage: ${0##*/} PICTURES" >&2; exit 1 ;;
	"") open_img "$PWD" ;;
	/*) open_img "$1" ;;
	"~"/*) open_img "$HOME/${1#"~"/}" ;;
	*) open_img "$PWD/$1" ;;
esac
