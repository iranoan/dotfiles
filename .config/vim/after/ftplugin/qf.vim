vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

if !exists('UndoFTPluginQf')
	def g:UndoFTPluginQf(): void
		nunmap <buffer>q
		nunmap <buffer><C-O>
		nunmap <buffer><C-I>
	enddef
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal foldcolumn<
endif

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| call UndoFTPluginQf()'
else
	b:undo_ftplugin = 'call UndoFTPluginQf()'
endif
