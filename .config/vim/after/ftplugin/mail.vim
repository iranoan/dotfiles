vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

if !exists('UndoFTPluginMail')
	def g:UndoFTPluginHTML(): void
		unlet! b:did_ftplugin_user_after b:did_ftplugin_user
		setlocal textwidth< expandtab<
	enddef
endif

setlocal textwidth=0 expandtab # デフォルト設定から好みに変更

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| call UndoFTPluginMail()'
else
	b:undo_ftplugin = 'call UndoFTPluginMail()'
endif
