scriptencoding utf-8

if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

setlocal commentstring=#%s

" Undo {{{1
if exists('b:undo_ftplugin')
	let b:undo_ftplugin ..= ' | call undo_ftplugin#Reset("msmtp")'
else
	let b:undo_ftplugin = 'call undo_ftplugin#Reset("msmtp")'
endif
