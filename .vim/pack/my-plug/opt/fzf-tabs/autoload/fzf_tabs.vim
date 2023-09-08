vim9script
# scriptencoding utf-8

export def TabOpen(): void
	var sink_ls: list<string> = GetTabList()
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
				sink:    function('TabListSink'),
				options: ['--delimiter', '\t', '--no-multi', '--prompt', " tab win_id\tfilename > ", '--tabstop', 2] + g:fzf_tabs_options,
				window: get(g:, 'fzf_layout', {window: {width: 0.9, height: 0.6}})->get('window', {width: 0.9, height: 0.6})
	})
enddef

def GetTabList(): list<string>
	var tab_n: number
	var buf_n: number
	var ls: list<string>
	var c_win: number = win_getid()
	var c_buf: number = bufnr()
	var c_tab: number = tabpagenr()
	var marker: string
	var updated: string
	for tab in gettabinfo()
		tab_n = tab['tabnr']
		for win in tab['windows']
			buf_n = winbufnr(win)
			if win == c_win # カレント・ウィンドウ
				marker = '>'
			elseif tab_n == c_tab
				if buf_n == c_buf # カレント・タブページ内の同一バッファ別ウィンドウ
				marker = '<'
				else # カレント・タブページ
				marker = '?'
				endif
			elseif buf_n == c_buf # 同一バッファ
				marker = '*'
			else # それ以外
				marker = '|'
			endif
			if getbufinfo(buf_n)[0]['changed']
				updated = '[+]'
			else
				updated = ''
			endif
			add(ls, printf("%2d %s%5x\t%s\t%s", tab_n, marker, win, bufname(buf_n)->substitute('^' .. $HOME .. '\ze[/\\]', '~', ''), updated))
		endfor
	endfor
	return ls
enddef

def TabListSink(line: string): void
	win_gotoid(str2nr(split(line, '\s\+')[2], 16))
enddef
