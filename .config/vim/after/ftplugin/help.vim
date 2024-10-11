vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= ' | call undo_ftplugin#Help()'
else
	b:undo_ftplugin = 'call undo_ftplugin#Help()'
endif
