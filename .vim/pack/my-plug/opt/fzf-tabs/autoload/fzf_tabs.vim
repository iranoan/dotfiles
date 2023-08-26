vim9script
# scriptencoding utf-8

export def TabOpen(): void
	var sink_ls: list<string> = GetTabList()
	if len(sink_ls) == 1 && len(sink_ls[0]->split('\n')) == 1
		echohl WarningMsg
		echo 'Only One Tab/One Window'
		echohl None
		return
	endif
	fzf#run({
				source: sink_ls,
				sink:    function('TabListSink'),
				# options: ['--preview', '~/bin/fzf-preview.sh {}', '--margin=0%', '--padding=0%', '--prompt', 'tab win_id(hex) filename > '],
				options: ['--no-multi', '--prompt', 'tab win_id filename > '],
				window: { width: 0.9, height: 0.6, xoffset: 0.4 }
				# down:    '10%'
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
			else # それ以外はタブページ番号
				marker = printf('%d', tab_n)
			endif
			add(ls, printf('%s %6x %s', marker, win, bufname(buf_n)->substitute('^' .. $HOME .. '\ze[/\\]', '~', ''))
			)
		endfor
	endfor
	return ls
enddef

def TabListSink(line: string): void
	win_gotoid(str2nr(split(line, '\s\+')[1], 16))
enddef
