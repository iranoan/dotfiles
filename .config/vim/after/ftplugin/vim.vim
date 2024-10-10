scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
let b:did_ftplugin_user_after = 1

setlocal formatoptions-=c textwidth=0 iskeyword-=# " デフォルト設定から好みに変更
