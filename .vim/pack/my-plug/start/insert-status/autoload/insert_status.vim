vim9script
# 挿入モード時、ステータスラインの色を変更
scriptencoding utf-8

var s_slhlcmd = 'highlight ' .. substitute(substitute(execute('highlight StatusLine'), '[\r\n]', '', 'g'), 'xxx', '', '')
var s_mode = ''

def insert_status#main(insert: string): void
	if s_mode == insert
		return
	endif
	silent! s_mode = insert
	if insert ==? 'Enter'
		s_slhlcmd = 'highlight ' .. substitute(substitute(execute('highlight StatusLine'), '[\r\n]', '', 'g'), 'xxx', '', '')
		execute g:hi_insert
	else
		highlight clear StatusLine
		execute s_slhlcmd
	endif
enddef
