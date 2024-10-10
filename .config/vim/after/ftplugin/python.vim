vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| setlocal equalprg< errorformat< foldexpr< formatprg< spelloptions< tabstop< tabstop< errorformat< foldexpr< iskeyword<'
else
	b:undo_ftplugin = 'setlocal equalprg< errorformat< foldexpr< formatprg< spelloptions< tabstop< tabstop< errorformat< foldexpr< iskeyword<'
endif
