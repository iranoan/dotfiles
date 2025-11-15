vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
b:did_ftplugin_user_after = 1

if &buftype ==# 'help'
	setlocal conceallevel=2
else
	setlocal conceallevel=0
endif

# Undo {{{1
if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= ' | call undo_ftplugin#Reset("help")'
else
	b:undo_ftplugin = 'call undo_ftplugin#Reset("help")'
endif
