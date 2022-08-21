# /etc/csh.cshrc: system-wide .cshrc file for csh(1) and tcsh(1)
# コメントアウト

set path=(/opt/local/bin /usr/X11R6/bin /usr/local/cuda-8.0/bin $path .)
set LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64
set C_INCLUDE_PATH=/usr/lib/gcc/arm-none-eabi/4.9.3/include/include
##setenv C_INCLUDE_PATH /usr/lib/gcc/arm-none-eabi/4.9.3/include/include
setenv LANG ja_JP.utf8

set prompt = "[`hostname -s`] "

set correct=all
set fignore=".o .out .log"
set watch="5 any any"
set autologout=0
set filec
set rmstar
set savehist=1000
set history=99
set notify
set color

alias pu pushd
alias po popd
alias du "du -k"
alias df "df -k"
alias l "ls -al"
alias rm "rm -i"
alias emacs "emacs -nw"

unalias lpr
alias lpr "nkf -e \!* | e2ps -a4 -p | /usr/bin/lpr"
# 仮想コンソールで使い分け
switch( "$TERM" )
	case "linux":
		setenv LANG "C"
		setenv LANGUAGE "C"
		setenv LANGUAGE "ja:en"
		setenv LC_ADDRESS "C"
		setenv LC_COLLATE "C"
		setenv LC_CTYPE "C"
		setenv LC_IDENTIFICATION "C"
		setenv LC_MEASUREMENT "C"
		setenv LC_MESSAGES "C"
		setenv LC_MONETARY "C"
		setenv LC_NAME "C"
		setenv LC_NUMERIC "C"
		setenv LC_PAPER "C"
		setenv LC_TELEPHONE "C"
		setenv LC_TIME "C"
		breaksw
	default:
		setenv LANG "ja_JP.UTF-8"
		setenv LANGUAGE "ja:en"
		setenv LC_ADDRESS "ja_JP.UTF-8"
		setenv LC_COLLATE "ja_JP.UTF-8"
		setenv LC_CTYPE "ja_JP.UTF-8"
		setenv LC_IDENTIFICATION "ja_JP.UTF-8"
		setenv LC_MEASUREMENT "ja_JP.UTF-8"
		setenv LC_MESSAGES "ja_JP.UTF-8"
		setenv LC_MONETARY "ja_JP.UTF-8"
		setenv LC_NAME "ja_JP.UTF-8"
		setenv LC_NUMERIC "ja_JP.UTF-8"
		setenv LC_PAPER "ja_JP.UTF-8"
		setenv LC_TELEPHONE "ja_JP.UTF-8"
		setenv LC_TIME "ja_JP.UTF-8"
		breaksw
endsw
exec /bin/bash
