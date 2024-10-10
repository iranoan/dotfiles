vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

if !exists('UndoFTPluginGnuplot')
	def g:UndoFTPluginHTML(): void
		unlet! b:did_ftplugin_user_after b:did_ftplugin_user
		setlocal commentstring< makeprg< errorformat<
	enddef
endif

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| call UndoFTPluginGnuplot()'
else
	b:undo_ftplugin = 'call UndoFTPluginGnuplot()'
endif
