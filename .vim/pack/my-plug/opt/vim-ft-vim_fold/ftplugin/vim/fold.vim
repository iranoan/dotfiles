vim9script
if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= ' | '
else
	b:undo_ftplugin = ''
endif
b:undo_ftplugin ..= 'setl fdm< fde< fdt<'

setlocal foldmethod=expr foldexpr=vim#fold#Level()
# setlocal foldtext=vim#fold#Text()
