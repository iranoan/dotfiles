vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

if !exists('UndoFTPluginC')
	def g:UndoFTPluginC(): void
		nunmap <buffer><Leader>gcc
		unlet! b:did_ftplugin_user_after b:did_ftplugin_user
		setlocal equalprg< errorformat< foldmethod< makeprg< makeprg< makeprg< matchpairs< path<
	enddef
endif

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= ' | call UnPackC()'
else
	b:undo_ftplugin = 'call UnPackC()'
endif
