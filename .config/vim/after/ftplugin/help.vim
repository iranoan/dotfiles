vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

if !exists('UndoFTPluginHelp')
	def g:UndoFTPluginHelp(): void
		nunmap <buffer>q
		nunmap <buffer>o
		nunmap <buffer>i
		nunmap <buffer>p
		nunmap <buffer><tab>
		nunmap <buffer><S-tab>
		nunmap <buffer><CR>
		unlet! b:did_ftplugin_user_after b:did_ftplugin_user
		setlocal commentstring< errorformat< foldmethod< keywordprg< makeprg<
	enddef
endif

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| call UndoFTPluginHelp()'
else
	b:undo_ftplugin = 'call UndoFTPluginHelp()'
endif
