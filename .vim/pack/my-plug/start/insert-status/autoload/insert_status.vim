vim9script
# 挿入モード時、ステータスラインの色を変更
scriptencoding utf-8

var s_slhlcmd = 'highlight ' .. substitute(substitute(execute('highlight StatusLine'), '[\r\n]', '', 'g'), 'xxx', '', '')
var s_mode = ''

augroup ChangeStatusLine
	autocmd!
	autocmd ColorScheme * s_slhlcmd = 'highlight ' .. substitute(substitute(execute('highlight StatusLine'), '[\r\n]', '', 'g'), 'xxx', '', '')
augroup END

export def Main(insert: string): void
	if s_mode == insert
		return
	endif
	var i_color: list<string> = [GetColor('cterm', g:hi_insert), GetColor('gui', g:hi_insert)]
	var n_color: list<string> = [GetColor('cterm', s_slhlcmd), GetColor('gui', s_slhlcmd)]
	silent! s_mode = insert
	if insert ==? 'Enter'
		SetColor(n_color, i_color)
		s_slhlcmd = 'highlight ' .. substitute(substitute(execute('highlight StatusLine'), '[\r\n]', '', 'g'), 'xxx', '', '')
		execute g:hi_insert
	else
		SetColor(i_color, n_color)
		highlight clear StatusLine
		execute s_slhlcmd
	endif
enddef

def GetColor(ui: string, hi: string): string
	var attr: string = matchstr(hi, '\<' .. ui .. '=\zs[^ ]\+\c')
	if attr ==# '' || match(attr, '\<\(reverse\|inverse\)\>\c') == -1
		return matchstr(hi, '\<' .. ui .. 'bg=\zs[^ ]\+\c')
	else
		return matchstr(hi, '\<' .. ui .. 'fg=\zs[^ ]\+\c')
	endif
enddef

def SetColor(n_set: list<string>, c_set: list<string>): void
	def Sub(hi_set: string, ui: string): string
			return substitute(hi_set, ui .. 'fg=' .. n_set[ui ==# 'cterm' ? 0 : 1] .. '\>\c', ui .. 'fg=' .. c_set[ui ==# 'cterm' ? 0 : 1], '')
							->substitute(ui .. 'bg=' .. n_set[ui ==# 'cterm' ? 0 : 1] .. '\>\c', ui .. 'bg=' .. c_set[ui ==# 'cterm' ? 0 : 1], '')
	enddef
	for k_hi in execute('highlight')
			->split('\n')
			->filter('v:val =~? "^StatusLine"')
			->map('substitute(v:val, " .\\+", "", "")')
			->filter('v:val !~? ''^StatusLine\(NC\|Term\|TermNC\)\?$\c''')
		execute 'highligh ' .. Sub(execute('highligh ' .. k_hi)->substitute('[\n\r]', '', 'g')->substitute(' \+xxx \+', ' ', ''), 'cterm')->Sub('gui')
	endfor
enddef
