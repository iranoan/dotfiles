vim9script
# scriptencoding utf-8

export def TabOpen(): void
	var sink_ls: list<string> = GetTabList()
	if len(sink_ls) == 1
		echohl WarningMsg
		echo 'Only One Tab'
		echohl None
		return
	endif
	fzf#run({
				source: sink_ls,
				sink:    function('TabListSink'),
				# options: ['--preview', '~/bin/fzf-preview.sh {}', '--margin=0%', '--padding=0%', '--prompt', 'tab win_id(hex) filename > '],
				options: ['--no-multi', '--prompt', 'tab win_id(hex) filename > '],
				window: { width: 0.9, height: 0.6, xoffset: 0.4 }
				# down:    '10%'
	})
enddef

def GetTabList(): list<string>
	var tab_n: number
	var ls: list<string>
	var win_n: number = win_getid()
	for tab in gettabinfo()
		tab_n = tab['tabnr']
		for win in tab['windows']
			add(ls, printf('%s%d %x %s',
				win == win_n ? '>' : ' ',
				tab_n,
				win,
				bufname(winbufnr(win))->substitute('^' .. $HOME .. '\ze[/\\]', '~', ''))
			)
		endfor
	endfor
	return ls
enddef

def TabListSink(line: string): void
	var parts = split(line, '\s')
	win_gotoid(str2nr(split(line, '\s')[1], 16))
enddef
