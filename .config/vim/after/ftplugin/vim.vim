vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
b:did_ftplugin_user_after = 1

setlocal formatoptions-=c textwidth=0 iskeyword-=# iskeyword+=? # デフォルト設定から好みに変更
# ? は is?, isnot? の syntax highlight を効かせるため
# setlocal keywordprg=:VimHelp

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= ' | call undo_ftplugin#Reset("vim")'
else
	b:undo_ftplugin = 'call undo_ftplugin#Reset("vim")'
endif
