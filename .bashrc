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
	export FZF_TMUX_OPTS="-p 95%,95% -y 23"
	if [[ -z "$TMUX" && -z $VSCODE_PID && -z "$VSCODE_GIT_ASKPASS_NODE" && -z "$MYVIMRC" ]]; then
		# VS code と Vim の terminal は除外
		detach_tmux="$( tmux ls | grep -v attached | tail --lines=1 | cut -d: -f1 )"
		if [ -z "$detach_tmux" ]; then
			exec tmux new-session
		else
			exec tmux attach -t "$detach_tmux"
		fi
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
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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
		*) color_prompt= ;;
	esac
else
	color_prompt=
fi

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\e]0;\w\a\]\[\e[1;31m\]\w\[\e[0;0m\]\$ '
	#                                                # ^ここまでが、ターミナル・アプリのタイトルバーになる
	# PS1='${debian_chroot:+($debian_chroot)}\[\e]0;\w\a\]\[\e[0;32m\]\u@\h\[\e[0;0m\]:\[\e[1;31m\]\w\[\e[0;0m\]\$ '
	# ↑ユーザー名+ホスト名表示
else
	PS1='${debian_chroot:+($debian_chroot)}\w\$ '
	# PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
	# ↑ユーザー名+ホスト名表示
fi
unset color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	if [ -r ~/.dircolors/solarized/256dark  ]; then
		eval "$(dircolors -b ~/.dircolors/solarized/256dark)"
	else
		eval "$(dircolors -b)"
	fi
	alias ls='ls --color=auto --hide={*.o,*.fls,*.synctex.gz,*.fdb_latexmk,*.toc,*.out,*.dvi,*.aux,*.nav,*.snm,*.swp} --time-style=long-iso'
	alias grep='grep --color=auto --directories=skip --binary-files=without-match --exclude-dir=.git --exclude={*.asf,*.aux,*.avi,*.bmc,*.bmp,*.cer,*.chm,*.chw,*.class,*.crt,*.cur,*.dll,*.doc,*.docx,*.dvi,*.emf,*.exe,*.fdb_latexmk,*.fls,*.flv,*.gpg,*.hlp,*.hmereg,*.icc,*.icm,*.ico,*.ics,*.jar,*.jp2,*.jpg,*.ltjruby,*.lzh,*.m4a,*.mkv,*.mov,*.mp3,*.mp4,*.mpg,*.nav,*.nvram,*.o,*.obj,*.odb,*.odg,*.odp,*.ods,*.odt,*.oll,*.opf,*.opp,*.out,*.pdf,*.pfa,*.pl3,*.png,*.ppm,*.ppt,*.pptx,*.pyc,*.reg,*.rm,*.rtf,*.snm,*.sqlite,*.swf,*.synctex.gz,*.tfm,*.toc,*.ttf,*.vbox,*.vbox-prev,*.vdi,*.vf,*.webm,*.wmf,*.wmv,*.xls,*.xlsm,*.xlsx,.*.sw?,.viminfo,viminfo,a.out}'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash/aliases ]; then
	. ~/.bash/aliases
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
if [ -f ~/.bash/completion ]; then # /usr/share/bash-completion/bash_completion 内で読み込まれるのは .bash_completion
	. ~/.bash/completion
fi
#履歴を複数端末で同期
share_history(){  # 以下の内容を関数として定義
	# if [ $? -ne 0 ]; then
	# 	# コマンド失敗時は履歴を残さず読み込み直すのみ
	# 	history -c  # 端末ローカルの履歴を一旦消去
	# 	history -r  # .bash_historyから履歴を読み込み直す
	# else
		# コマンド成功時は、重複履歴を削除
		history -a  # .bash_historyに前回コマンドを1行追記
		history -c  # 端末ローカルの履歴を一旦消去
		awk 'BEGIN {i=0}
			{
				sub("^[ \t]+", "") # 行頭空白削除
				sub("[ \t]+$", "") # 行末空白削除
				# sub("^(which|kill|killall|ls|less|cd|man|texdoc|help|info|ps|pgrep|whatis|echo)( [$.A-Za-z0-9_ -]+/?)?$", "") # 一部のコマンドを記録しない
				# sub("^[A-Za-z0-9_-]+ -(v|-version|h|-help)$", "") # バージョン、ヘルプ記録しない
				# sub("^(cd|cd (-|$_)|ls|history|pwd|exit)$", "") # 一部のコマンド記録しない
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
			}' ~/.bash_history > ~/.tmp/bash_history && mv ~/.tmp/bash_history ~/.bash_history
		history -r  # .bash_historyから履歴を読み込み直す
	# fi
}
PROMPT_COMMAND='share_history'  # 上記関数をプロンプト毎に自動実施
shopt -u histappend   # .bash_history追記モードは不要なのでOFFに
export HISTSIZE=9999  # 履歴のMAX保存数を指定
export HISTCONTROL=erasedups #重複歴を記録しない

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
# LESS のカラー表示
export LESS='--no-init --quit-if-one-screen --RAW-CONTROL-CHARS --IGNORE-CASE --LONG-PROMPT --jump-target=5 --ignore-case'
if [ -e /usr/share/source-highlight/src-hilite-lesspipe.sh ]; then
	export LESSOPEN='| /usr/share/source-highlight/src-hilite-lesspipe.sh %s'
fi
# man コマンドを使った less でカラー表示
# http://yanor.net/wiki/?UNIX%2Fless%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%81%A7ls%E3%82%84man%E3%82%92%E8%89%B2%E4%BB%98%E3%81%8D%E8%A1%A8%E7%A4%BA%E3%81%99%E3%82%8B
# http://www.mt.cs.keio.ac.jp/person/narita/lv/index_ja.html#color
man() {
	LESS_TERMCAP_md=$'\e[01;31m' \
	LESS_TERMCAP_me=$'\e[0m' \
	LESS_TERMCAP_se=$'\e[0m' \
	LESS_TERMCAP_so=$'\e[38;1;7m' \
	LESS_TERMCAP_ue=$'\e[0m' \
	LESS_TERMCAP_us=$'\e[04;34m' \
	command man "$@"
}

# man() { # man に vim の Man コマンドを使う
# 	vim +Man\ $@ +1bwipeout
# }

stty stop undef
# .inputrc で vi モードにしている
#元に戻すには
# set -o emacs
# 一時的なら
# set -o vi
umask 077

[ -f ~/.fzf/bashrc ] && source ~/.fzf/bashrc

ranger() { # ranger でファイルを less で開いた時にすぐ終わってしまう問題対処→http://malkalech.com/ranger_filer#org15afd1c
	if [ -n "$RANGER_LEVEL" ]; then
		exit
	else
		LESS="$LESS -+F -+X" command ranger "$@"
	fi
}
