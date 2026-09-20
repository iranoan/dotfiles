vim9script
# scriptencoding utf-8

export def TabOpen(): void
	var normal_fg: string
	var normal_bg: string

	def GetDefaultOpts(): dict<string>
		var color: dict<string>
		var name_v: list<string>

		for c in matchstr($FZF_DEFAULT_OPTS, '--color=\zs[^ ]\+')->split(',')
			name_v = split(c, ':')
			if len(name_v) == 1
				color[name_v[0]] = ''
			else
				color[get({'current-fg': 'fg+', 'current-bg': 'bg+', 'current-hl': 'hl+', 'header-fg': 'header'}, name_v[0], name_v[0])] = name_v[1]
			endif
		endfor
		return color
	enddef

	def GetNormal(is_base16: bool): list<string>
		var hl: dict<any> = hlget('Normal', true)[0]
		if is_base16
			return [get(hl, 'ctermfg', &background ==# 'dark' ? '7' : '0'),
			        get(hl, 'ctermbg', &background ==# 'dark' ? '0' : '7')]
		endif
		return [get(hl, 'guifg', get(hl, 'ctermfg', &background ==# 'dark' ? '7' : '0')),
			      get(hl, 'guibg', get(hl, 'ctermbg', &background ==# 'dark' ? '0' : '7'))]
	enddef

	def GetColor(name: string, group_names: list<string>, is_base16: bool): string
		var groups: list<string> = get(g:, 'fzf_colors', {name: group_names[0] ==# 'fg' ? ['fg', normal_fg] : ['bg', normal_bg]})
			                        	->get(name, group_names[0] ==# 'fg' ? ['fg', normal_fg] : ['bg', normal_bg])
		var fb: string = groups[0]
		var hl: list<dict<any>>

		for g in groups[1 : ]
			hl = hlget(g, true)
			if hl == []
				continue
			endif
			if is_base16
				return get(hl[0], 'cterm' .. fb, ((&background ==# 'dark') == (fb ==# 'bg')) ? '0' : '7')
			endif
			return get(hl[0], 'gui' .. fb, get(hl[0], 'cterm' .. fb, ((&background ==# 'dark') == (fb ==# 'bg')) ? '0' : '7'))
		endfor
		return ''
	enddef

	var colors: dict<string> = GetDefaultOpts()
	var is_base16: bool = !has('gui_running') || has_key(colors, 'base16') || has_key(colors, '16')
	var color_str: string
	var sink_ls: list<string> = GetBufList()

	[normal_fg, normal_bg] = GetNormal(is_base16)
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
	for [k, v] in items(get(g:, 'fzf_colors', {}))
		colors[k] = GetColor(k, v, is_base16)
	endfor
	if colors == {}
		color_str = '--color=' .. &background .. ','
	else
		color_str = '--color='
		for s in ['dark', 'light', 'base16', '16, ''bw']
			if has_key(colors, s)
				color_str ..= s .. ','
				remove(colors, s)
			endif
		endfor
	endif
	for [k, v] in items(colors)
		color_str ..= k .. ':' .. v .. ','
	endfor
	color_str = color_str[ : -2 ]
	fzf#run({
				source: sink_ls,
				sink:    function(BufListSink),
				options: ['--delimiter', '\t', '--no-multi', '--prompt', " tab win_id buf  \tfilename > ", '--tabstop', 2] + g:fzf_tabs_options + [color_str],
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
		execute printf('tab split | buffer %s', split(line, '\(\[+\]\)\?\s\+')[3])
	endif
enddef
