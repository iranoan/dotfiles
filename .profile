# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

if [ -f "$HOME/.xprofile" ]; then
	. "$HOME/.xprofile"
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
	# include .bashrc if it exists
	if [ -f "$HOME/.bashrc" ]; then
		. "$HOME/.bashrc"
	fi
fi

#環境変数
export EDITOR=vim
# TeX の log で強制改行される位置の指定。デフォルトだと 79 桁←環境変数じゃないと効かない
export max_print_line=1000
# man コマンドに Vim を使いたいが、Man コマンドとの両使いでは使いづらい
# export MANPAGER="vim -M +MANPAGER +'setlocal nolist nospell foldmethod=indent foldenable | %foldopen! ' -"

if [ -f "$HOME/.config/bash/history" ]; then # bash の一部の履歴を削除
	tac "$HOME/.config/bash/history" |
		sed -E -e 's/\s+$//g' -e '/^$/d' \
		-e '/^(which|kill|killall|ls|less|cd|man|texdoc|help|info|ps|pgrep|whatis)( [\.A-Za-z0-9_ -]+\/?)?$/d' \
		-e "/ -(v|-version|h|-help) ?$/d" \
		-e "/^(cd|cd (-|\$_)|ls|history|pwd|exit) ?$/d" |
		awk '!a[$0]++' |
		tac > "$HOME/.config/bash/history.tmp" && mv "$HOME/.config/bash/history.tmp" "$HOME/.config/bash/history"
fi
# 仮想コンソールで使い分け
case "$TERM" in
	linux)
		export LANG="C"
		export LANGUAGE="C"
		export LC_ADDRESS="C"
		export LC_COLLATE="C"
		export LC_CTYPE="C"
		export LC_IDENTIFICATION="C"
		export LC_MEASUREMENT="C"
		export LC_MESSAGES="C"
		export LC_MONETARY="C"
		export LC_NAME="C"
		export LC_NUMERIC="C"
		export LC_PAPER="C"
		export LC_TELEPHONE="C"
		export LC_TIME="C";;
	*)
		export LANG="ja_JP.UTF-8"
		export LANGUAGE="ja:en"
		export LC_ADDRESS="ja_JP.UTF-8"
		export LC_COLLATE="ja_JP.UTF-8"
		export LC_CTYPE="ja_JP.UTF-8"
		export LC_IDENTIFICATION="ja_JP.UTF-8"
		export LC_MEASUREMENT="ja_JP.UTF-8"
		export LC_MESSAGES="ja_JP.UTF-8"
		export LC_MONETARY="ja_JP.UTF-8"
		export LC_NAME="ja_JP.UTF-8"
		export LC_NUMERIC="ja_JP.UTF-8"
		export LC_PAPER="ja_JP.UTF-8"
		export LC_TELEPHONE="ja_JP.UTF-8"
		export LC_TIME="ja_JP.UTF-8";;
esac
