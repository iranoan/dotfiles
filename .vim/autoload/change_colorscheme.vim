vim9script
scriptencoding utf-8

# background によって一部の highlight を変える (Solarized を基本としている) {{{
export def Highlight(): void
	def GetCursorLine(r0: number, g0: number, b0: number, r1: number, g1: number, b1: number): string # CursorLine の guibg を取得
		# 無ければ Solarized を基本に Normal 背景色より少し明るい/暗い色を計算
		var bg: string = execute('highlight CursorLine')
		if bg =~# '\<guibg='
			return matchstr(bg, '.\+ guibg=\zs\S\+\ze')
		endif
		bg = execute('highlight Normal')
		if bg !~# '\<guibg=#'
			return &background ==? 'light' ? '#fdf6e3' : '#002b36'
		endif
		bg = matchstr(bg, '.\+ guibg=#\zs[0-9A-Fa-f]\+\>\ze')
		return printf('#%02x%02x%02x',      # ↓ Normal - ColorLine の色を引きたいので、-+ 逆転
			str2nr(strpart(bg, 0, 2), 16) - r0 + r1, # Red
			str2nr(strpart(bg, 2, 2), 16) - g0 + g1, # Green
			str2nr(strpart(bg, 4, 2), 16) - b0 + b1  # Blue
		)
	enddef
	var nbg: string = matchstr(execute('highlight Normal'), '\<guibg=\zs\S\+')
	var bg: string
	if &background ==? 'light'
		if nbg ==# ''
			nbg = '#fdf6e3'
		endif
		bg = GetCursorLine(0xfd, 0xf6, 0xe3, 0xee, 0xe8, 0xd5)
		         # 黒背景端末を使っているので背景色を明示する←端末も背景に NONE を使わない
		execute 'highlight Normal        ctermfg=8 ctermbg=15 guifg=#073642 guibg=' .. nbg
		execute 'highlight NormalDefault ctermfg=8 ctermbg=15 guifg=#073642 guibg=' .. nbg
		         highlight CursorLineNr cterm=bold gui=bold ctermfg=3 ctermbg=15 guifg=#b58900 guibg=NONE
		# execute 'highlight TabLineSel   term=bold,underline cterm=bold,underline gui=bold,underline ctermfg=0 ctermbg=7 guifg=#111111 guibg=' .. bg
		#          highlight TabLine      term=underline cterm=underline gui=underline ctermfg=8 ctermbg=NONE guifg=#839496 guibg=NONE
		#          highlight TabLineFill  term=underline cterm=underline gui=underline ctermfg=8 ctermbg=NONE guifg=#839496 guibg=NONE
	else
		if nbg ==# ''
			nbg = '#002b36'
		endif
		bg = GetCursorLine(0x00, 0x2b, 0x36, 0x07, 0x36, 0x42)
		execute 'highlight Normal        ctermfg=15 ctermbg=NONE guifg=#eee8d5 guibg=' .. (!has('gui_running') && g:colors_name ==# 'solarized8' ? 'NONE' : nbg)
		execute 'highlight NormalDefault ctermfg=15 ctermbg=8 guifg=#eee8d5 guibg=' .. nbg
		         highlight CursorLineNr cterm=bold gui=bold ctermfg=3 ctermbg=8 guifg=#b58900 guibg=NONE
		# execute 'highlight TabLineSel   term=bold,underline cterm=bold,underline gui=bold,underline ctermfg=15 ctermbg=0 guifg=#dddddd guibg=' .. bg
		#          highlight TabLine      term=underline cterm=underline gui=underline ctermfg=14 ctermbg=NONE guifg=#93a1a1 guibg=NONE
		#          highlight TabLineFill  term=underline cterm=underline gui=underline ctermfg=14 ctermbg=NONE guifg=#93a1a1 guibg=NONE
	endif
	# light/dark で同設定
	highlight Comment    cterm=NONE gui=NONE guifg=#859900 ctermfg=2
	highlight SpellBad   term=underline cterm=underline ctermfg=NONE ctermul=9 guifg=NONE guisp=#cb4b16
	highlight SpellCap   term=underline cterm=underline ctermfg=NONE ctermul=13 guifg=NONE guisp=#6c71c4
	highlight SpellLocal term=underline cterm=underline ctermfg=NONE ctermul=3 guifg=NONE guisp=#b58900
	highlight SpellRare  term=underline cterm=underline ctermfg=NONE ctermul=6 guifg=NONE guisp=#2aa198
	highlight MatchParen term=bold,reverse cterm=bold,reverse gui=bold,reverse ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE
	execute 'highlight QuickFixLine term=NONE cterm=NONE gui=NONE ctermfg=NONE ctermbg=0 guifg=NONE guibg=' .. bg
	execute 'highlight PmenuSel term=NONE cterm=NONE gui=NONE ctermfg=NONE ctermbg=0 guifg=NONE guibg=' .. bg
	bg = execute('highlight Terminal', 'silent!')->substitute('[\r\n]', '', 'g')
	if bg ==# '' || match(bg, '\<cleared\>') != -1 # Terminal 未定義は Normal
		highlight link Terminal Normal
	endif
	execute 'highlight VertSplit' ..
		execute('highlight VertSplit')
			->substitute('[\n\r]\+', '', 'g')
			->substitute('^VertSplit \+xxx', '', '')
			->substitute('ctermfg=\S\+ ctermbg=\(\S\+\) guifg=\S\+ guibg=\(\S\+\)', 'ctermfg=\1 ctermbg=\1 guifg=\2 guibg=\2', '')
enddef

export def Before(color: string): void # t_Co, termguicolors 等 colorscheme 切り替え前に必要な設定をする
	if color ==# 'solarized'
		# g:solarized_italic = 0
		if has('gui_running')
			g:solarized_menu = 0
		else
			set notermguicolors
			set t_Co=16 # ターミナルが 256 色だと一部の色が変わる
		endif
	elseif color ==# 'solarized8'
		g:solarized_old_cursor_style = 1
		# g:solarized_italics = 0
		if !has('gui_running')
			set t_Co=256 # ←~/.tmux_conf set-option -g default-terminal "tmux-256color"
			set termguicolors
			# ↓端末やの色設定あれば不要? 変化が不明
			# &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
			# &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
		endif
	elseif!has('gui_running')
		set t_Co=256 # ←~/.tmux_conf set-option -g default-terminal "tmux-256color"
		set notermguicolors
	endif
enddef
