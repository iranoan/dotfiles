vim9script
scriptencoding utf-8

# Undo {{{1
if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| call undo_ftplugin#Reset("notmuch-show")'
else
	b:undo_ftplugin =  'call undo_ftplugin#Reset("notmuch-show")'
endif
