vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

setlocal formatoptions-=c textwidth=0 iskeyword-=# # デフォルト設定から好みに変更

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| setlocal spelloptions<'
else
	b:undo_ftplugin = 'setlocal formatoptions< textwidth< iskeyword< keywordprg< spelloptions<'
endif
