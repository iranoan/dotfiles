vim9script
scriptencoding utf-8
# $MYVIMDIR/pack/*/{start,opt} 管理用スクリプト
# パッケージの入手は
# git clone https://github.com/<author>/<package> <package>

# 採用を検討したが、何かを理由にして導入を止めたプラグイン {{{1
# * Markdown のシンタックス https://github.com/preservim/vim-markdown
# 	- vim-precious と相性が悪く、一度コード例内にカーソル移動すると、コード内シンタックスが働かなくなる
# * goobook (Google Contacts) を使ったメールアドレス補完 https://github.com/afwlehmann/vim-goobook
# 	- → $MYVIMDIR/pack/my-plug/opt/asyncomplete-mail/ に置き換え
# * https://github.com/cohama/lexima.vim は、対応括弧を追加設定して使うと CmdlineLeave が働いてしまう+他は全角未対応
# 	- → $MYVIMDIR/pack/my-plug/start/pair_bracket/ に置き換え
# * 選択範囲をテキストオブジェクトで広げたり、狭めたり https://github.com/terryma/vim-expand-region
#		- 反応が遅く、なれると直接テキスト・オブジェクトを使うように変わった
#		- xmap v <Cmd>call set_expand_region#main('(expand_region_expand)') <bar> delfunction set_expand_region#main<CR>
# 	- xmap V <Cmd>call set_expand_region#main('(expand_region_shrink)') <bar> delfunction set_expand_region#main<CR>
# * https://github.com/rbonvall/vim-textobj-css
#		- CSS をテキストオプジェクト化 ← vim-textobj-fold で代用できるしカーソルの桁位置でも変わるので、使いづらい
# * netfw を Fern に入れ替え https://github.com/lambdalisue/fern-hijack.vim
#		- TabEdit でディレクトリなら、Fern を起動するように変更


# プラグイン管理 {{{1
# $MYVIMDIR/pack でプラグインを管理する上で、FileType で読み込んだプラグインを再設定するために、再度 setfiletype して、そのイベント・トリガーを削除 {{{2
for g:packe_setting_s in ['c', 'cpp', 'python', 'vim', 'ruby', 'yaml', 'html', 'xhtml', 'css', 'tex', 'sh', 'bash', 'markdown', 'go', 'help']
	if g:packe_setting_s ==# 'python'
		g:packe_setting_ext = '*.py'
	elseif g:packe_setting_s ==# 'ruby'
		g:packe_setting_ext = '*.rb'
	elseif g:packe_setting_s ==# 'yaml'
		g:packe_setting_ext = '*.yml'
	elseif g:packe_setting_s ==# 'html'
		g:packe_setting_ext = '*.htm,*.html'
	# '_': {'type': ['markdown'], 'cmap': 0}, # * は箇条書きで使う
	# '~': {'type': ['markdown'], 'cmap': 0}, # 下付き添字
	# '^': {'type': ['markdown'], 'cmap': 0}, # 上付き添字
	elseif g:packe_setting_s ==# 'vim'
		g:packe_setting_ext = '*.vim,.vimrc,vimrc,_vimrc,.gvimrc,gvimrc,_gvimrc'
	elseif g:packe_setting_s ==# 'markdown'
		g:packe_setting_ext = '*.md'
	elseif g:packe_setting_s ==# 'cpp'
		g:packe_setting_ext = '*.h'
	else
		g:packe_setting_ext = '*.' .. g:packe_setting_s
	endif
	execute 'augroup ResetFiletype__' .. g:packe_setting_s
					.. '| autocmd!'
					.. '| autocmd BufWinEnter ' .. g:packe_setting_ext .. ' setfiletype ' .. g:packe_setting_s
					.. '| autocmd! ResetFiletype__' .. g:packe_setting_s
					.. '| augroup! ResetFiletype__' .. g:packe_setting_s
					.. '| augroup END'
endfor
unlet g:packe_setting_ext g:packe_setting_s

# vim-surround などのプラグインでも . リピートを可能にする https://github.com/tpope/vim-repeat {{{1
# 1}}}

# マークを可視化 visial mark https://github.com/kshenoy/vim-signature {{{1
# 遅延読み込みだと、開いた時に以前開いた時に付いていたマークが可視化されない
g:SignatureMap = { # こちらで設定しないとデフォルト指定されてしまう
	'Leader':            'm',
	'PlaceNextMark':     'm,',
	'ToggleMarkAtLine':  'm.',
	'PurgeMarksAtLine':  'm-',
	'DeleteMark':        '',
	'PurgeMarks':        'm<Space>',
	'PurgeMarkers':      '',
	'GotoNextLineAlpha': '',
	'GotoPrevLineAlpha': '',
	'GotoNextSpotAlpha': '',
	'GotoPrevSpotAlpha': '',
	'GotoNextLineByPos': '',
	'GotoPrevLineByPos': '',
	'GotoNextSpotByPos': ']`',
	'GotoPrevSpotByPos': '[`',
	'GotoNextMarker':    '',
	'GotoPrevMarker':    '',
	'GotoNextMarkerAny': '',
	'GotoPrevMarkerAny': '',
	'ListBufferMarks':   '',
	'ListBufferMarkers': ''
}
# vim-gitgutter との連携 {{{2
g:SignatureMarkTextHLDynamic = 1
g:SignatureMarkerTextHLDynamic = 1
# バッファを開いた直後や編集で頻繁に vim-gitgutter に上書きされ更新の必要があるが対策不明
nnoremap <silent>mm <Cmd>SignatureRefresh<CR>
augroup VimSignature # SignColumn デフォルトの色が使われるので他の設定に合わせて変更
	autocmd!
	autocmd ColorScheme * if &background ==# 'light' |
				\ highlight SignatureMarkText term=bold cterm=bold gui=bold ctermbg=NONE guibg=NONE guifg=#111111 ctermfg=0 | else |
				\ highlight SignatureMarkText term=bold cterm=bold gui=bold ctermbg=NONE guibg=NONE guifg=#dddddd ctermfg=15 | endif |
				\ highlight GitGutterAdd      term=bold cterm=bold gui=bold ctermbg=NONE guibg=NONE |
				\ highlight GitGutterChange   term=bold cterm=bold gui=bold ctermbg=NONE guibg=NONE |
				\ highlight GitGutterDelete   term=bold cterm=bold gui=bold ctermbg=NONE guibg=NONE
augroup END

# :Tabedit $MYVIMDIR/pack/my-plug/start/tabedit/ {{{1
# ↑opt/ に入れて呼び出すようにすると、最初の使用時に補完が働かない
nnoremap <silent>gf :TabEdit <C-R><C-P><CR>
# nnoremap <silent>gf :TabEdit <cfile><CR> " ← 存在しなくても開く <C-R><C-F> と同じ

# $MYVIMDIR/pack/my-plug/start/vim-foldtext/ {{{1 https://github.com/t9md/vim-foldtext を書き換え

# shell program を用いてバッファにフィルタを掛ける $MYVIMDIR/pack/my-plug/start/shell-filter/ {{{1

# カラースキム {{{1
# background によって一部の highlight を変える関数 (Solarized を基本としている) {{{2
def ColorschemeHighlight(): void
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
	def ChangeVert(): void
		c: string = execute('highlight VertSplit')
			->substitute('[\n\r]\+', '', 'g')
			->substitute('^VertSplit \+xxx', '', '')
		execute c =~# '\<links\s\+to\>'
					\ ? 'highlight link VertSplit ' .. substitute(c, '.\+\<links\s\+to\s\+\(\S\+\)', '\1', '')
					\ : 'highlight VertSplit' .. substitute(c, 'ctermfg=\S\+ ctermbg=\(\S\+\) guifg=\S\+ guibg=\(\S\+\)', 'ctermfg=\1 ctermbg=\1 guifg=\2 guibg=\2', '')
		return
	enddef
	var nbg: string = matchstr(execute('highlight Normal'), '\<guibg=\zs\S\+')
	var bg: string
	if &background ==# 'light'
		if nbg ==# ''
			nbg = '#fdf6e3'
		endif
		if g:colors_name =~# '^solarized'
			       highlight Comment      cterm=NONE gui=NONE ctermfg=10 guifg=#586e75
		endif
		if g:colors_name ==# 'solarized8'
			highlight CursorColumn term=reverse ctermbg=254 guibg=#F5F2DC
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
		if g:colors_name =~# '^solarized'
			       highlight Comment      cterm=NONE gui=NONE ctermfg=14 guifg=#93a1a1
		endif
		if g:colors_name ==# 'solarized8'
			highlight CursorColumn term=reverse ctermbg=236 guibg=#0E414E
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
	ChangeVert()
enddef

def ColorschemeBefore(color: string): void # t_Co, termguicolors 等 colorscheme 切り替え前に必要な設定をする
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
# 2}}}
set background=dark
# https://github.com/lifepillar/vim-solarized8 {{{2
# 2}}}
# https://github.com/altercation/vim-colors-solarized {{{2
# 2}}}
augroup ChangeColorScheme
	autocmd!
	autocmd ColorScheme * ColorschemeHighlight()
	autocmd ColorSchemePre * ColorschemeBefore(expand('<amatch>'))
	# Solarized で GUI が CUI と異なる色になっている
	autocmd ColorScheme solarized highlight Pmenu term=reverse ctermfg=0 ctermbg=13 gui=reverse guifg=#073642 guibg=#839496
				| highlight SignColumn ctermfg=11 ctermbg=8 guifg=#839496 guibg=NONE
				| highlight link vimSet vimCommand
augroup END
for s in ['solarized8', 'solarized', 'habamax', 'desert', 'default']
	try # (glob() を使う存在確認は遅い)
		execute 'colorscheme ' .. s
		break
	catch /^Vim\%((\a\+)\)\:E185:\C/
		continue
	endtry
endfor

# 日本語ヘルプ https://github.com/vim-jp/vimdoc-ja {{{1
# 1}}}

# 挿入モード時、ステータスラインの色を変更 $MYVIMDIR/pack/my-plug/start/insert-status {{{1
g:hi_insert = 'highlight StatusLine term=reverse cterm=bold,reverse gui=bold,reverse ctermbg=White ctermfg=1 guibg=#dddddd guifg=#dc322f'
# ↑インサート・モード時の highlight 指定

# テキストオブジェクト化の元となる https://github.com/kana/vim-textobj-user {{{1
# 遅延読み込みにすると、最初に gcaz 等、プラグイン+textobj-* の組み合わせた時うまく動作しない
# またこのファイルの処理自体に時間がかかるようになるので、遅延処理の美味みがない

# 同じインデントをテキストオプジェクト化 https://github.com/kana/vim-textobj-indent {{{1
# キーマップ ii, ai

# シンタックスをテキストオプジェクト化 https://github.com/kana/vim-textobj-syntax {{{1
# キーマップ iy, ay
# コメントのテキスト・オブジェクト化 https://github.com/thinca/vim-textobj-comment はコメントより優先されるシンタックスは多くないので syntax on なら vim-textobj-syntax が有れば良い
# ↓キーマップ ic, ac
onoremap ac <Plug>(textobj-syntax-a)
onoremap ic <Plug>(textobj-syntax-i)
xnoremap ic <Plug>(textobj-syntax-i)
xnoremap ac <Plug>(textobj-syntax-a)

# 折りたたみをテキストオプジェクト化 https://github.com/kana/vim-textobj-fold {{{1
# キーマップ iz, az

# テキストオブジェクトで (), {} "", '' を区別せずにカーソル近くで判定して、全て b で扱えるようにする https://github.com/osyo-manga/vim-textobj-multiblock {{{1
# キーマップしないと ", ' の指定が働かない
onoremap ab <Plug>(textobj-multiblock-a)
onoremap ib <Plug>(textobj-multiblock-i)
xnoremap ab <Plug>(textobj-multiblock-a)
xnoremap ib <Plug>(textobj-multiblock-i)
g:textobj_multiblock_blocks = [
			[ '"', '"', 1 ],
			[ "'", "'", 1 ],
			[ '(', ')' ],
			[ '{', '}' ],
			[ '<', '>' ],
			[ '[', ']' ],
			]

# 括弧や引用符をペアで入力/削除 $MYVIMDIR/pack/my-plug/start/pair_bracket/ {{{1
# ドット・リピートは考慮していない
g:pairbracket = {
	'(': {'pair': ')', 'space': 1, 'escape': {'tex': 2, 'vim': 1},
		'search': {'v\': 0, '\': 2, 'v': 1, '_': 0}},
	'[': {'pair': ']', 'space': 1, 'escape': {'tex': 2, 'vim': 1},
		'search': {'v\': 0, '\': 0, 'v': 1, '_': 1}},
	'{': {'pair': '}', 'space': 1, 'escape': {'tex': 2, 'vim': 1},
		'search': {'v\': 0, '\': 1, 'v': 1, '_': 0}},
	'<': {'pair': '>', 'space': 1, 'type': ['tex'], 'cmap': 0},
	'/*': {'pair': '*/', 'space': 1, 'type': ['c', 'cpp', 'css'], 'cmap': 0},
	'「': {'pair': '」'},
	'『': {'pair': '』'},
	'【': {'pair': '】'},
	}
g:pairquote = {
	'"': {},
	'''': {},
	'`': {},
	'$': {'type': ['tex']},
	'*': {'type': ['help', 'markdown'], 'cmap': 0}, # tag と強調
	'|': {'type': ['help'], 'cmap': 0},     # link
	'_': {'type': ['markdown'], 'cmap': 0}, # 強調
	'~': {'type': ['markdown'], 'cmap': 0}, # 下付き添字
	'^': {'type': ['markdown'], 'cmap': 0}, # 上付き添字
	# ↓ ', " 自体の反応が遅くなる
	# "'''": {},
	# '"""': {},
	}

# $MYVIMDIR/pack/*/{stat,opt}/* でプラグインを管理する上で、便利な関数 $MYVIMDIR/pack/my-plug/start/pack-manage {{{1
# 遅延読み込みにすると、補完が使えない
# augroup loadPackManage
# 	autocmd!
# 	autocmd FuncUndefined pack_manage#* packadd pack-manage
# 		| autocmd! loadPackManage
# 		| augroup! loadPackManage
# 	autocmd CmdUndefined ReinstallPack packadd pack-manage
# 		| autocmd! loadPackManage
# 		| augroup! loadPackManage
# augroup END

# grep で幾つかのオプションをデフォルトで付けたり、補完を可能にする $MYVIMDIR/pack/my-plug/start/gnu-grep/ {{{1
g:gnu_grep = {'exclude-dir': '{.git,.cache,.thumbnail,cache,thumbnail,undo}'}

# 出力を quickfix に取り込む $MYVIMDIR/pack/my-plug/start/output2qf {{{1
# シェルの取り込みでは補完を使いたいので、opt にしない
