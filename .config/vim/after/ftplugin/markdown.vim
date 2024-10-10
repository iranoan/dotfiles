vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=0 # softtabstop=0 で tabstop を使う

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| setlocal expandtab< tabstop< shiftwidth< softtabstop<'
else
	b:undo_ftplugin = 'setlocal expandtab< tabstop< shiftwidth< softtabstop<'
endif

