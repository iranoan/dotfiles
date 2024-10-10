vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

if !exists('UndoFTPluginTeX')
	def g:UndoFTPluginTeX(): void
		nunmap <buffer><Leader>v
		iunmap <buffer><S-Enter>
		iunmap <buffer><S-C-Enter>
		iunmap <buffer><C-Enter>
		nunmap <buffer><leader>bb
		unlet! b:did_ftplugin_user_after b:did_ftplugin_user
		setlocal breakindentopt< errorformat< formatlistpat< iskeyword< iskeyword< iskeyword< makeprg< suffixesadd<
	enddef
endif

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| call UndoFTPluginTeX()'
else
	b:undo_ftplugin = 'call UndoFTPluginTeX()'
endif
