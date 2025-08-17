vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
b:did_ftplugin_user_after = 1

setlocal equalprg=stylelint\ --fix\ --stdin\ --no-color\|prettier\ --write\ --parser\ css
