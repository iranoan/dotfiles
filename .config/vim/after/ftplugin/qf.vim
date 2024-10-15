vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

setlocal statusline=%#StatusLineLeft#%t\ %*%<%{exists('w:quickfix_title')?w:quickfix_title:''}%=%#StatusLineRight#%3l/%L%4p%%
gnu_grep#SetQfTitle()

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= ' | call undo_ftplugin#Qf()'
else
	b:undo_ftplugin = 'call undo_ftplugin#Qf()'
endif
