#!/bin/bash
# fdfind で $HOME が対象の場合は、特殊なディレクトリを除外するために、そのための設定ファイルを指定する

cmd=(
	fdfind
	--hidden
	--follow
	--no-ignore
	--type symlink
	--type file
	--type directory
	--ignore-file "$HOME/.config/fd/ignore"
)

ignore=0

if (($# > 0)); then
	mapfile -t resolved_dirs < <(realpath -m -- "$@" 2>/dev/null)
	for d in "${resolved_dirs[@]}"; do
		cmd+=(--search-path "$d")
		[[ "$d" == "$HOME" ]] && ignore=1
	done
fi

if (( ignore )); then
	cmd+=(
		--base-directory "$HOME"
		--ignore-file "$HOME/.config/fd/home"
	)
fi

# シェルプロセスを fdfind に置換して実行
exec "${cmd[@]}"
