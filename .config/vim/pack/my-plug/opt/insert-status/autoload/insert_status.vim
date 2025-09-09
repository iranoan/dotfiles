vim9script
# 挿入モード時、ステータスラインの色を変更
scriptencoding utf-8

var s_slhlcmd: list<dict<any>> = hlget('StatusLine')
var s_mode = ''

augroup ChangeStatusLine
	autocmd!
	autocmd ColorScheme * s_slhlcmd = hlget('StatusLine')
augroup END

export def Main(insert: string): void
	if s_mode == insert
		return
	endif
	silent! s_mode = insert
	if insert ==? 'Enter'
		s_slhlcmd = hlget('StatusLine')
		hlset(g:hi_insert)
	else
		highlight clear StatusLine
		hlset(s_slhlcmd)
	endif
enddef
