#!/bin/sh
# nsxiv/sxiv の起動補助
# * 引数がディレクトリならその直下の画像をサムネイル
# * 引数が画像のときも、同じフォルダの画像ファイルをサムネイルとして準備しおく
# * 引数が無い時は次のサブ・ディレクトリも含めたサムネイル表示
# 	* シェルからはカレント・ディレクトリ
# 	* GUI のメニューからは PICTURES ディレクトリ
# * ターミナルの fzf からの起動で Embed nsxiv/sxiv window が残るが、呼び出し元のシェル関数で対処する

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

error_msg(){
	case "$( ps xo pid,comm | awk -F ' ' '/^\s*\<'$PPID'\>/{ print $2 }' )" in
		sh|ksh|ash|dash|bash|csh|tcsh|zsh|fish)
			if [ $# -eq 1 ]; then
				echo "$1" >&2
			fi
			echo $sxiv': no more files to display, aborting' >&2
			;;
		*)
			if command -v zenity > /dev/null ; then
				zenity --warning --title=$sxiv --text="${1#*: }\nno more files to display, aborting" 2> /dev/null
			fi
			;;
	esac
	exit 1
}

get_geometry(){
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
}

open_img(){
	geometry=$( get_geometry )
	if command -v fdfind > /dev/null ; then
		cmd0="fdfind --hidden --no-ignore --follow --base-directory "
		cmd1=" --absolute-path \
			-e avif -e bmp -e cgm -e cr2 -e dl -e emf -e eps -e gif -e ico -e j2c -e j2k -e jp2 -e jpeg -e jxl -e jpf -e jpg -e jpx -e mng -e nef -e pbm -e pcx -e pgm -e png -e ppm -e svg -e svgz -e tga -e tiff -e webp -e xbm -e xcf -e xpm -e xwd -e yuv -e cur"
	else
		cmd0="find -L "
		cmd1="-type d \( -name .thumbnails -o -name thumbnails -o -name .cache -o -name cache -o -name .log -o -name log -o -name _log -o -name .tmp -o -name tmp -o -name .Trash -o -name Trash \) -prune -o -type f \( \
			-iname '*.avif'  -iname '*.bmp ' -o -iname '*.cgm' -o -iname '*.cr2' -o -iname '*.dl' -o -iname '*.emf' -o -iname '*.eps' -o -iname '*.gif' -o -iname '*.ico' -o -iname '*.j2c' -o -iname '*.j2k' -o -iname '*.jp2' -o -iname '*.jpeg' -o -iname '*.jxl' -o -iname '*.jpf' -o -iname '*.jpg' -o -iname '*.jpx' -o -iname '*.mng' -o -iname '*.nef' -o -iname '*.pbm' -o -iname '*.pcx' -o -iname '*.pgm' -o -iname '*.png' -o -iname '*.ppm' -o -iname '*.svg' -o -iname '*.svgz' -o -iname '*.tga' -o -iname '*.tif' -o -iname '*.tiff' -o -iname '*.webp' -o -iname '*.xbm' -o -iname '*.xcf' -o -iname '*.xpm' -o -iname '*.xwd' -o -iname '*.yuv' -o -iname '*.cur' \
		\) -print 2> /dev/null"
	fi
	if [ -d "$1" ]; then # ディレクトリではサブディレクトリまで含めてサムネイル表示
		dir="$( echo "$1" | sed -e 's/ /\\ /g' -e 's/"/\\"/g' -e 's/(/\\(/g' -e 's/)/\\)/g' )"
		cmd0="${cmd0}$dir "
		opt='-t -n'
		count='1'
	else
		opt='-n'
		dir="$( echo "${1%/*}" | sed -e 's/ /\\ /g' -e 's/"/\\"/g' -e 's/(/\\(/g' -e 's/)/\\)/g' )"
		case "$cmd0" in
			fd*) cmd0="${cmd0} $dir --max-depth 1 " ;;
			*) cmd0="${cmd0}-maxdepth 1 $dir " ;;
		esac
	fi
	list=$( (
		eval "$cmd0$cmd1"
		if file --brief --mime-type "$1" |
			grep -Eq '^(image/|application/postscript\>)' ; then # 引数が画像ファイルなら無条件でリストに追加 (拡張子の検索で含まれない可能性が有る)
			echo "$1"
		fi
		) |
			sort --unique --ignore-case --version-sort )
	if [ -z "$list" ]; then
		error_msg
	fi
	if [ "$opt" = "-n" ] ; then
		count=$( grep --line-number --fixed-strings "$1" <<-_EOF_
		$list
		_EOF_
		)
		count=${count%%:*}
	fi
	if [ -n "$count" ]; then
		eval "$sxiv -g $geometry -b -s f -i $opt $count" -- <<-_EOF_ &
		$list
		_EOF_
	else
		$sxiv -g "$geometry" -b -s f -t -i -- <<-_EOF_ &
		$list
		_EOF_
		error_msg "$sxiv: $1: Error opening image"
	fi
}

if [ $# -eq 0 ]; then
	case "$( ps xo pid,comm | awk -F ' ' '/^\s*\<'$PPID'\>/{ print $2 }' )" in
		sh|ksh|ash|dash|bash|csh|tcsh|zsh|fish) open_img "$PWD" ;;
		*) open_img "$( xdg-user-dir PICTURES )" ;;
	esac
	exit
fi
for f in "$@"
do
	case "$f" in
		/*) open_img "$f" ;;
		"~"/*) open_img "$HOME/${f#"~"/}" ;;
		*) open_img "$PWD/$f" ;;
	esac
done
