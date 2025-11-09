#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

if [[ $( tty ) =~ /dev/tty.* ]]; then # 仮想コンソールでは、そのままでは日本語が使えないので fbterm 起動
	if command -v fbterm > /dev/null 2>&1 ; then
		FBTERM=1 fbterm -- "$HOME/bin/fbterm.sh"
	fi
elif command -v tmux > /dev/null 2>&1 ; then # シェル開始時に tmux 起動 (デタッチされたセッションがあればそちらに繋げる)
	[[ $- != *i* ]] && return
	export FZF_TMUX=1
	export FZF_TMUX_OPTS="-p 95%,95%"
	if [[ -z "$TMUX" && -z $VSCODE_PID && -z "$VSCODE_GIT_ASKPASS_NODE" && -z "$MYVIMRC" ]]; then
		# VS code と Vim の terminal は除外
		detach_tmux="$( tmux ls | grep -v attached | tail --lines=1 | cut -d: -f1 )"
		if [ -z "$detach_tmux" ]; then
			exec tmux new-session
		else
			exec tmux attach -t "$detach_tmux"
		fi
		unset detach_tmux
	fi
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
#shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
#HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar # ** でサブ・ディレクトリまで展開

# shopt -s nullglob # 該当するファイルが無いパス名展開を「0個の文字列」として展開しない←ls *.hoge が存在しないと、ls のみと同じ扱いになる
# shopt -s failglob # 該当するファイルが無いパス名展開をエラーにしない←--hideオプションや補完と対立する

# make less more friendly for non-text input files, see lesspipe(1)
# [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	case "$TERM" in
		linux) [ "$FBTERM" ] && export TERM=fbterm && color_prompt=yes;;
		fbterm) color_prompt=yes;;
		xterm-color|*-256color) color_prompt=yes;;
		*)
			if [ "$VIM_TERMINAL" ]; then
				color_prompt=yes
			else
				color_prompt=
			fi
			;;
	esac
else
	color_prompt=
fi

if [ "$color_prompt" = yes ]; then
	if [ "$TERM_PROGRAM" = 'tmux' ]; then
		PS1='\[\e[1;32m\]\$\[\e[0;0m\] '
	else
		PS1='\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h\a\]\[\e[1;31m\]\w\[\e[0;0m\]\[\e[1;32m\]\$\[\e[0;0m\] '
		#                                                   # ^ここまでが、ターミナル・アプリのタイトルバーになる
		# PS1='\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h\a\]\[\e[1;33m\]\u@\h\[\e[0;0m\]:\[\e[1;31m\]\w\[\e[0;0m\]\[\e[1;32m\]\$\[\e[0;0m\] '
		# ↑ユーザー名+ホスト名表示
	fi
else
	if [ "$TERM_PROGRAM" = 'tmux' ]; then
		PS1='$ '
	else
		PS1='\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h\a\]\w\$ '
		# PS1='\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h\a\]\u@\h:\w\$ '
		# ↑ユーザー名+ホスト名表示
	fi
fi
if [ "$VIM_TERMINAL" ] ; then # Vim の :terminal で Vim カレント・ディレクトリをシェルのそれを同期するための準備
	_synctermcwd_ps1() {
		printf '\e]51;["call","Tapi_SyncTermCwd","%s"]\x07' "$PWD"
	}
	PS1="\$(_synctermcwd_ps1)\[\e[1;32m\]\$\[\e[0;0m\] "
fi
unset color_prompt debian_chroot

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	# https://github.com/seebi/dircolors-solarized
	if [ -r "$HOME/.config/dircolors-solarized/dircolors.256dark" ]; then
		eval "$(dircolors -b "$HOME/.config/dircolors-solarized/dircolors.256dark")"
	else
		eval "$(dircolors -b)"
	fi
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f "$HOME/.config/bash/aliases" ]; then
	source "$HOME/.config/bash/aliases"
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi
if [ -f "$HOME/.config/bash/completion" ]; then # /usr/share/bash-completion/bash_completion 内で読み込まれるのは .bash_completion
	source "$HOME/.config/bash/completion"
fi
#履歴を複数端末で同期
share_history(){ # 以下の内容を関数として定義
	# if [ $? -ne 0 ]; then
	# 	# コマンド失敗時は履歴を残さず読み込み直すのみ
	# 	history -c # 端末ローカルの履歴を一旦消去
	# 	history -r # .bash_historyから履歴を読み込み直す
	# else
		# コマンド成功時は、重複履歴を削除
		history -a # .bash_historyに前回コマンドを1行追記
		history -c # 端末ローカルの履歴を一旦消去
		awk 'BEGIN {i=0}
			{
				sub("^[ \t]+", "") # 行頭空白削除
				sub("[ \t]+$", "") # 行末空白削除
				sub("^.vscode/.+", "") # 一部のコマンド記録しない
				sub("^(cd|cd (-|$_)|ls|history|pwd|exit)$", "") # 一部のコマンド記録しない
				# sub("^(which|kill|killall|ls|less|cd|man|texdoc|help|info|ps|pgrep|whatis|echo)( [$.A-Za-z0-9_ -]+/?)?$", "") # 一部のコマンドを記録しない
				# sub("^[A-Za-z0-9_-]+ -(v|-version|h|-help)$", "") # バージョン、ヘルプ記録しない
				if ( $0 ~ /[^\s]/ ){ # 空白以外が存在する
					a[i] = $0
					i++
				}
			}
			END{
				for (j = 0; i > 0; ){ # 逆順格納
					b[j++] = a[--i]
				}
				k = 0
				for ( i = 0; i < j; i++ ){ # 重複削除
					if( !c[b[i]]++ )a[k++] = b[i] # 重複でない
				}
				while( k > 0 )print a[--k] # 逆順出力
			}' "$HISTFILE" > "$HOME/.config/bash/history.tmp" && mv "$HOME/.config/bash/history.tmp" "$HISTFILE"
		history -r # $HISTFILE から履歴を読み込み直す
	# fi
}
PROMPT_COMMAND='share_history' # 上記関数をプロンプト毎に自動実施
shopt -u histappend  # .bash_history追記モードは不要なのでOFFに
export HISTSIZE=9999 # 履歴のMAX保存数を指定
export HISTCONTROL=erasedups #重複歴を記録しない
export HISTFILE="$HOME/.config/bash/history"

if command -v vim > /dev/null ; then
	if [[ $( tty ) =~ /dev/tty.* ]] || ps x | awk '{print $5}' | grep -qE '\<[f]bterm\>' ; then # 仮想コンソール→非 GUI
		export TEXEDIT='vim -p --remote-tab-silent +%d "%s"'
	else
		if command -v gvim > /dev/null ; then
			export TEXEDIT='gvim -p --remote-tab-silent +%d "%s"'
		else
			export TEXEDIT='vim -p --remote-tab-silent +%d "%s"'
		fi
	fi
else
	export TEXEDIT='vi +%d "%s"'
fi
#export HISTIGNORE=cd:history:ls:which:pwd:exit:*\ -v:*\ --version:*\ -h:*\ --help:cd\ -:kill\ *:killall\ *:man\ * #一部のコマンドは履歴を残さない

# man コマンドを使った less でカラー表示
# http://yanor.net/wiki/?UNIX%2Fless%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%81%A7ls%E3%82%84man%E3%82%92%E8%89%B2%E4%BB%98%E3%81%8D%E8%A1%A8%E7%A4%BA%E3%81%99%E3%82%8B
# http://www.mt.cs.keio.ac.jp/person/narita/lv/index_ja.html#color
man() {
	GROFF_NO_SGR=1 \
	LESS_TERMCAP_mb=$'\e[01;33m' \
	LESS_TERMCAP_md=$'\e[01;31m' \
	LESS_TERMCAP_me=$'\e[0m' \
	LESS_TERMCAP_se=$'\e[0m' \
	LESS_TERMCAP_so=$'\e[38;1;7m' \
	LESS_TERMCAP_ue=$'\e[0m' \
	LESS_TERMCAP_us=$'\e[04;34m' \
	LESS_TERMCAP_mr=$(tput rev) \
	LESS_TERMCAP_mh=$(tput dim) \
	LESS_TERMCAP_ZN=$(tput ssubm) \
	LESS_TERMCAP_ZV=$(tput rsubm) \
	LESS_TERMCAP_ZO=$(tput ssupm) \
	LESS_TERMCAP_ZW=$(tput rsupm) \
	command man "$@"
}

stty stop undef
# .inputrc で vi モードにしている
#元に戻すには
# set -o emacs
# 一時的なら
# set -o vi
umask 077

[ -f "$HOME/.config/fzf/bashrc" ] && source "$HOME/.config/fzf/bashrc"

ranger() { # ranger でファイルを less で開いた時にすぐ終わってしまう問題対処→http://malkalech.com/ranger_filer#org15afd1c
	if [ -n "$RANGER_LEVEL" ]; then
		exit
	else
		LESS="$LESS -+F -+X" command ranger "$@"
	fi
}

find_function(){ # 下記の which() 関数から呼ばれ ~/.bashrc などから関数の記述位置を探す
	# $1: function name
	# $2: path
	# 多重定義の対応は不完全で、読み込み順序とは関係なく定義箇所を羅列するだけ
	# source で指定されている読み込みファイルはシェル変数未対応
	if [ ! -f "$2" ]; then
		return
	fi
	grep -E -nH "^\s*(function)?$1\s*\(\s*\)" "$2"
	grep -E -h '(^\s*(source|\.)|(;|&&|\|\|)\s*(source|\.))\s' "$2" |
		sed -E 's/(^\s*(source|\.)|.+(;|&&|\|\|)\s*(source|\.))\s+([^ ]+).*/\5/g' |
		while read -r s; do
			s=$( eval "echo $s" ) # " に挟まれていたり、環境変数を展開
			case "$s" in "$HOME/.bash_login"|"$HOME/.bash_profile"|"$HOME/.bashrc"|"$HOME/.profile"|"$HOME/.xprofle")
					# 無限ループを防ぐために ~/.bash_login, ~/.bash_profile, ~/.bashrc, ~/.profile, ~/.xprofile は再起処理から除外
					continue ;;
				*)
					find_function "$1" "$s"
					;;
			esac
		done
}

which(){ # 素の which /usr/bin/which ではリンクを辿らず、関数、alias の違いが不明
	for f in "$@"; do
		case "$( type -t "$f" )" in
			alias)
				cmd=$( export LANGUAGE=C ; type "$f" | sed -E 's/^[^ ]+ is aliased to ['\''`"]?([^ ]*)( .+)?'\''/\1/g' )
				if [ "$cmd" == 'command' ]; then
					cmd=$( export LANGUAGE=C ; type "$f" | sed -E 's/^[^ ]+ is aliased to ['\''`"]?[^ ]+ ([^ ]+)( .+)?'\''/\1/g' )
				fi
				cmd=$( echo "$cmd" | sed -e "s>^~/>$HOME/>g" -e "s> ~> $HOME/>g" )
				echo 'alias '"$( command which "$cmd" | xargs readlink -f )"
				type "$f" | sed -E "s/^[^\`]+\`(.+)'.*/\1/g"
				;;
			keyword)
				echo "keyword $f"
				;;
			function)
				echo 'function'
				for b in ~/.bash_profile ~/.bash_login ~/.profile
				do
					if [ -f "$b" ]; then
						find_function "$f" "$b"
						break
					fi
				done
				for b in ~/.bashrc ~/.xprofile
				do
					find_function "$f" "$b"
				done
				;;
			builtin)
				echo "builtin $f"
				;;
			file)
				case "$( command which "$f" )" in
					/snap/bin/*) command which "$f" ;;
					*) readlink -f "$( command which "$f" )" ;;
				esac
				;;
			*)
				command which "$f"
				;;
		esac
	done
}
