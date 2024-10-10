vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

if !exists('UndoFTPluginXHTML')
	def g:UndoFTPluginXHTML(): void
		iunmap <buffer><S-Enter>
		iunmap <buffer><S-C-Enter>
		iunmap <buffer><=
		iunmap <buffer>>=
		iunmap <buffer><C-Space>
		iunmap <buffer>&<space>
		iunmap <buffer>\\
		iunmap <buffer>+-
		iunmap <buffer>**
		iunmap <buffer>==
		unlet! b:did_ftplugin_user_after b:did_ftplugin_user
		setlocal breakindentopt< errorformat< foldmethod< formatlistpat< iskeyword< makeprg< omnifunc< spelloptions<
	enddef
endif

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '|call UndoFTPluginXHTML()'
else
	b:undo_ftplugin = 'call UndoFTPluginXHTML()'
endif
