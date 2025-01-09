vim9script
if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= ' | setl fdm< fde<'
else
	b:undo_ftplugin = 'setl fdm< fde<'
endif

setlocal foldmethod=expr foldexpr=vim#fold#Level()
