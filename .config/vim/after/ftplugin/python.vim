vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

if !exists('UndoFTPluginPython')
	def g:UndoFTPluginHTML(): void
		nunmap p
		unlet! b:did_ftplugin_user_after b:did_ftplugin_user
		setlocal equalprg< errorformat< foldexpr< formatprg< spelloptions< tabstop< tabstop< errorformat< foldexpr< iskeyword<
	enddef
endif

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= ' | call UndoFTPluginPython()'
else
	b:undo_ftplugin = 'call UndoFTPluginPython()'
endif
