vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

if !exists('UndoFTPluginVim')
	def g:UndoFTPluginVim(): void
		unlet! b:did_ftplugin_user_after b:did_ftplugin_user
		setlocal spelloptions< formatoptions< textwidth< iskeyword<
	enddef
endif

setlocal formatoptions-=c textwidth=0 iskeyword-=# iskeyword+=? iskeyword+=: # デフォルト設定から好みに変更

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| call UndoFTPluginVim()'
else
	b:undo_ftplugin = 'call UndoFTPluginVim()'
endif
