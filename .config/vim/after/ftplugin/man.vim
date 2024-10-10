vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

if !exists('UndoFTPluginMan')
	def g:UndoFTPluginHTML(): void
		unlet! b:did_ftplugin_user_after b:did_ftplugin_user
		setlocal list< spell< foldmethod< foldenable< foldlevelstart< foldcolumn< keywordprg<
	enddef
endif

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| call UndoFTPluginMan()'
else
	b:undo_ftplugin = 'call UndoFTPluginMan()'
endif
