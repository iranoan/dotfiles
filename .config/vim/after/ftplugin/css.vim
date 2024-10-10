vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

if !exists('UndoFTPluginCSS')
	def g:UndoFTPluginCSS(): void
		unlet! b:did_ftplugin_user_after b:did_ftplugin_user
		setlocal equalprg< foldmethod< makeprg< omnifunc< spelloptions<
	enddef
endif

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| call UndoFTPluginCSS()'
else
	b:undo_ftplugin = 'call UndoFTPluginCSS()'
endif
