vim9script
# scriptencoding utf-8

export def TabOpen(): void
	var sink_ls: list<string> = GetBufList()
	if len(sink_ls) == 1 && len(sink_ls[0]->split('\n')) == 1
		if has('popupwin')
			popup_create('Only One Tab/One Window', {
				line: 'cursor+1', col: 'cursor', # カーソル位置
				minwidth: 20,
				time: 3000,
				zindex: 300,
				drag: 1,
				highlight: 'WarningMsg',
				border: [1, 1, 1, 1],
				borderhighlight: ['CursorLine'],
				close: 'click',
				padding: [0, 1, 0, 1],
				})
		else
			echohl WarningMsg
			echo 'Only One Tab/One Window'
			echohl None
		endif
		return
	endif
	fzf#run({
				source: sink_ls,
				sink:    function('BufListSink'),
				options: ['--delimiter', '\t', '--no-multi', '--header-lines=1', '--prompt', " tab win_id buf  \tfilename > ", '--tabstop', 2] + g:fzf_tabs_options,
				window: get(g:, 'fzf_layout', {window: {width: 0.9, height: 0.6}})->get('window', {width: 0.9, height: 0.6})
	})
enddef

def GetBufList(): list<string>
	var tab_n: number
	var buf_n: number
	var c_win: number = win_getid()
	var c_buf: number = bufnr()
	var c_tab: number = tabpagenr()
	var marker: string
	var updated: string
	var ls: list<string> = [printf("%2d %s%5x %2d%s\t%s", c_tab, ' ', c_win, c_buf, ( getbufinfo(c_buf)[0]['changed'] ? '[+]' : '   '), bufname(c_buf)->substitute('^' .. $HOME .. '\ze[/\\]', '~', ''))]
	for tab in gettabinfo()->filter((idx, val) => val.tabnr != c_tab) # カレント・タブページ以外
		tab_n = tab['tabnr']
		for win in tab['windows']
			buf_n = winbufnr(win)
			if buf_n == c_buf # 同一バッファ
				marker = '*'
			else # それ以外
				marker = '|'
			endif
			if getbufinfo(buf_n)[0]['changed']
				updated = '[+]'
			else
				updated = '   '
			endif
			add(ls, printf("%2d %s%5x %2d%s\t%s", tab_n, marker, win, buf_n, updated, bufname(buf_n)->substitute('^' .. $HOME .. '\ze[/\\]', '~', '')))
		endfor
	endfor
	tab_n = gettabinfo(c_tab)[0]['tabnr']
	for win in gettabinfo(c_tab)[0]['windows']->filter((idx, val) => val != c_win) # カレントタブページのカレント・ウィンドウ以外
		buf_n = winbufnr(win)
		if buf_n == c_buf # カレント・タブページ内の同一バッファ別ウィンドウ
		marker = '<'
		else # カレント・タブページ
		marker = '>'
		endif
		if getbufinfo(buf_n)[0]['changed']
			updated = '[+]'
		else
			updated = '   '
		endif
		add(ls, printf("%2d %s%5x %2d%s\t%s", tab_n, marker, win, buf_n, updated, bufname(buf_n)->substitute('^' .. $HOME .. '\ze[/\\]', '~', '')))
	endfor
	for buf in getbufinfo()->filter((idx, val) => val.windows == [] && val.listed) # 隠れバッファ
		buf_n = buf.bufnr
		if buf_n == c_buf # 同一バッファ
			marker = '*'
		else # それ以外
			marker = '?'
		endif
		if getbufinfo(buf_n)[0]['changed']
			updated = '[+]'
		else
			updated = '   '
		endif
		add(ls, printf(" 0 %s    0 %2d%s\t%s", marker, buf_n, updated, bufname(buf_n)->substitute('^' .. $HOME .. '\ze[/\\]', '~', '')))
	endfor
	return ls
enddef

def BufListSink(line: string): void
	var win: number = str2nr(split(line, '\s\+')[2], 16)
	if win != 0
		win_gotoid(win)
	else
		execute printf('tab split | buffer %s', split(line, '[\[\]+* \t]\+')[3])
	endif
enddef
