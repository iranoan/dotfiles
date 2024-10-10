vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

if !exists('UndoFTPluginMarkdown')
	def g:UndoFTPluginHTML(): void
		unlet! b:did_ftplugin_user_after b:did_ftplugin_user
		setlocal expandtab< tabstop< shiftwidth< softtabstop<
	enddef
endif

setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=0 # softtabstop=0 で tabstop を使う

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| call UndoFTPluginMarkdown()'
else
	b:undo_ftplugin = 'call UndoFTPluginMarkdown()'
endif

