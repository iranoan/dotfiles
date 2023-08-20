vim9script
scriptencoding utf-8
# ~/.vim/pack/*/{start,opt} 管理用スクリプト
# パッケージの入手は
# git clone https://github.com/<author>/<package> <package>

# 採用を検討したが、何かを理由にして導入を止めたプラグイン {{{1
# * Markdown のシンタックス https://github.com/preservim/vim-markdown
# 	- vim-precious と相性が悪く、一度コード例内にカーソル移動すると、コード内シンタックスが働かなくなる
# * goobook (Google Contacts) を使ったメールアドレス補完 https://github.com/afwlehmann/vim-goobook
# 	- → ~/.vim/pack/my-plug/opt/asyncomplete-mail/ に置き換え
# * https://github.com/cohama/lexima.vim は、対応括弧を追加設定して使うと CmdlineLeave が働いてしまう+他は全角未対応
# 	- → ~/.vim/pack/my-plug/start/pair_bracket/ に置き換え
# * 選択範囲をテキストオブジェクトで広げたり、狭めたり https://github.com/terryma/vim-expand-region
#		- 反応が遅く、なれると直接テキスト・オブジェクトを使うように変わった
#		- xmap v <Cmd>call set_expand_region#main('(expand_region_expand)') <bar> delfunction set_expand_region#main<CR>
# 	- xmap V <Cmd>call set_expand_region#main('(expand_region_shrink)') <bar> delfunction set_expand_region#main<CR>
# * https://github.com/rbonvall/vim-textobj-css
#		- CSS をテキストオプジェクト化 ← vim-textobj-fold で代用できるしカーソルの桁位置でも変わるので、使いづらい


# プラグイン管理 {{{1
# ~/.vim/pack でプラグインを管理する上で、FileType で読み込んだプラグインを再設定するために、再度 setfiletype して、そのイベント・トリガーを削除 {{{2
for g:packe_setting_s in ['c', 'cpp', 'python', 'vim', 'ruby', 'yaml', 'html', 'xhtml', 'css', 'tex', 'sh', 'bash', 'markdown', 'go', 'help']
	if g:packe_setting_s ==# 'python'
		g:packe_setting_ext = '*.py'
	elseif g:packe_setting_s ==# 'ruby'
		g:packe_setting_ext = '*.rb'
	elseif g:packe_setting_s ==# 'yaml'
		g:packe_setting_ext = '*.yml'
	elseif g:packe_setting_s ==# 'html'
		g:packe_setting_ext = '*.htm,*.html'
	elseif g:packe_setting_s ==# 'vim'
		g:packe_setting_ext = '*.vim,.vimrc,vimrc,_vimrc,.gvimrc,gvimrc,_gvimrc'
	elseif g:packe_setting_s ==# 'markdown'
		g:packe_setting_ext = '*.md'
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

# Git の変更のあった signcolumn にマークをつける https://github.com/airblade/vim-gitgutter {{{1
# 遅延読み込みをすると vim-signature との連携機能が使えない←連携できないだけ
# augroup loadGitgutter
# 	autocmd!
# 	autocmd FileType c,cpp,python,vim,ruby,yaml,markdown,html,xhtml,css,tex,sh,bash set_gitgutter#main()
# 				| autocmd! loadGitgutter
# 				| augroup! loadGitgutter
# 				| delfunction set_gitgutter#main
# augroup END
# packadd vim-gitgutter
g:gitgutter_preview_win_floating = 1 # GitGutterPreviewHunk 表示はポップアップ
g:gitgutter_map_keys = 0             # デフォルト・マッピング OFF
g:gitgutter_close_preview_on_escape = 1 # <ESC> で閉じる
# g:gitgutter_sign_added              = '+'
g:gitgutter_sign_modified           = '/'
g:gitgutter_sign_removed            = '-'
# g:gitgutter_sign_removed_first_line = '-<'
# g:gitgutter_sign_removed_above_and_below = '->'
# g:gitgutter_sign_modified_removed   = '/-'
nmap <leader>gp <Plug>(GitGutterPreviewHunk)
nmap <leader>gs <Plug>(GitGutterStageHunk)
nmap <leader>gu <Plug>(GitGutterUndoHunk)
nmap [g <Plug>(GitGutterPrevHunk)
nmap ]g <Plug>(GitGutterNextHunk)
# GitGutter* コマンドが定義され、vim-fugitive の Git コマンドが未定義ではなく、曖昧扱いになるので、コマンドのみ定義しておく
command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#Complete Git exe fugitive#Command(<line1>, <count>, +<range>, <bang>0, "<mods>", <q-args>)

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
	autocmd ColorScheme * if &background ==? 'light' |
				\ highlight SignatureMarkText cterm=bold gui=bold ctermbg=NONE guibg=NONE guifg=#111111 ctermfg=0 | else |
				\ highlight SignatureMarkText cterm=bold gui=bold ctermbg=NONE guibg=NONE guifg=#dddddd ctermfg=15 | endif |
				\ highlight GitGutterAdd      cterm=bold gui=bold ctermbg=NONE guibg=NONE |
				\ highlight GitGutterChange   cterm=bold gui=bold ctermbg=NONE guibg=NONE |
				\ highlight GitGutterDelete   cterm=bold gui=bold ctermbg=NONE guibg=NONE
augroup END

#: Tabedit ~/.vim/pack/my-plug/start/tabedit/ {{{1
# ↑opt/ に入れて呼び出すようにすると、最初の使用時に補完が働かない
nnoremap <silent>gf :TabEdit <C-R><C-P><CR>
# nnoremap <silent>gf :TabEdit <cfile><CR> " ← 存在しなくても開く <C-R><C-F> と同じ

# https://github.com/t9md/vim-foldtext を ~/.vim/pack/my-plug/start/vim-foldtext/ で書き換え {{{1

# shell program を用いてバッファにフィルタを掛ける ~/.vim/pack/my-plug/start/shell-filter/ {{{1

# カーソル行の URL やファイルを開く ~/.vim/pack/my-plug/start/open_uri/ {{{1

# カラースキム {{{1
try
	set background=dark
	# https://github.com/altercation/vim-colors-solarized {{{1https://github.com/altercation/vim-colors-solarized {{{2
	# g:solarized_menu = 0
	# if !has('gui_running') # ターミナルが 256 色一部の色が変わる
	# 	set t_Co=16
	# endif
	# colorscheme solarized
	# 2}}}
	# https://github.com/lifepillar/vim-solarized8 {{{2
	if !has('gui_running')
		set termguicolors  # ターミナルで GUI の色設定を使う→solarized の読み込みが早い
	endif
	# ↓端末やの色設定ぞ見で不要? 変化が不明
	# &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
	# &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
	colorscheme solarized8
	# 2}}}
catch /^Vim\%((\a\+)\)\=:E185:/
	colorscheme habamax
endtry
# background によって一部の syntax を変える (Solarized を基本としている) {{{
def Color_light_dark(): void
	highlight clear Pmenu # 一部の絵文字が標準設定では見にくいので一旦クリアして light/dark で異なる設定にする
	if &background ==? 'light'
		highlight Normal       ctermfg=0 ctermbg=NONE guifg=#111111 guibg=#fdf6e3
		highlight CursorLineNr cterm=bold gui=bold ctermfg=3 ctermbg=15 guifg=#b58900 guibg=NONE
		highlight CursorLine   term=underline ctermbg=7 guibg=#eee8d5
		highlight CursorColumn term=underline ctermbg=7 guibg=#eee8d5
		highlight SignColumn   term=standout ctermfg=66 guifg=#657b83
		highlight LineNr       cterm=NONE ctermfg=10 ctermbg=7 guifg=#000000 guibg=#eee8d5
		highlight Comment      cterm=NONE gui=NONE ctermfg=2 guifg=#008800
		highlight StatusLine   term=bold ctermfg=0 ctermbg=15
		highlight TabLineSel   cterm=bold,underline ctermfg=0 ctermbg=7
		# highlight TabLine      cterm=underline ctermfg=0 ctermbg=7
		highlight TabLineFill  cterm=underline ctermfg=0 ctermbg=7
		highlight Pmenu        cterm=NONE ctermfg=8 ctermbg=7 guifg=#000000 guibg=#eeeeee
		highlight SpecialKey   term=bold cterm=bold gui=bold ctermfg=12 ctermbg=NONE guibg=NONE
		highlight FoldColumn   term=standout ctermfg=3 ctermbg=7 guibg=#eee8d5
	else
		# Solarized に合わせて Normal 背景色より少し明るい色を計算する {{{
		var bg: string = matchstr(substitute(execute('highlight Normal'), '[\n\r \t]\+', ' ', 'g'), '.\+guibg=#\zs[0-9A-Za-z]\+\>\ze')
		bg = printf('#%02x%02x%02x',      # ↓ Normal - ColorLine の色を引きたいので、-+ 逆転
			str2nr(strpart(bg, 0, 2), 16) - 0x00 + 0x07, # Red
			str2nr(strpart(bg, 2, 2), 16) - 0x2B + 0x36, # Green
			str2nr(strpart(bg, 4, 2), 16) - 0x36 + 0x42  # Blue
		) # }}}
		         highlight Normal       ctermfg=15 ctermbg=NONE guifg=#dddddd
		         highlight CursorLineNr cterm=bold gui=bold ctermfg=3 ctermbg=8 guifg=#b58900 guibg=NONE
		execute 'highlight CursorLine   term=underline ctermbg=0 guibg=' .. bg
		execute 'highlight CursorColumn term=underline ctermbg=0 guibg=' .. bg
		execute 'highlight LineNr       ctermfg=14 ctermbg=0 guifg=#93a1a1 guibg=' .. bg
		         highlight Comment      cterm=NONE gui=NONE guifg=#dddddd guifg=#00a800 ctermfg=2
		         highlight StatusLine   term=bold ctermfg=15 ctermbg=0
		         highlight TabLineSel   term=bold,underline ctermfg=0 ctermbg=15
		         highlight TabLine      term=underline ctermfg=0 ctermbg=15
		         highlight TabLineFill  term=underline ctermfg=0 ctermbg=15
		execute 'highlight Pmenu        ctermfg=7 ctermbg=0 guibg=' .. bg
		         highlight SpecialKey   term=bold cterm=bold gui=bold ctermfg=11 ctermbg=NONE guibg=NONE
		execute 'highlight FoldColumn   term=standout ctermbg=0 guibg=' .. bg
	endif
	# light/dark で同設定
	highlight SpellBad   term=underline cterm=underline ctermfg=NONE ctermul=9 guifg=NONE guisp=#cb4b16
	highlight SignColumn ctermbg=NONE guibg=NONE
	highlight Cursor     guibg=#657b83
	highlight MatchParen term=bold,reverse cterm=bold,reverse gui=bold,reverse ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE
	# Terminal の色は Normal に揃える←Solarized で未定義
	# highlight clear Terminal
	# execute 'highlight Terminal ' .. substitute(substitute(execute('highlight Normal'), '[\n\r \t]\+', ' ', 'g'), ' *Normal\s\+xxx *', '', '')
enddef
augroup ChangeHighlight
	autocmd!
	autocmd ColorScheme * Color_light_dark()
augroup END
Color_light_dark()

# 日本語ヘルプ https://github.com/vim-jp/vimdoc-ja {{{1

# 挿入モード時、ステータスラインの色を変更 ~/.vim/pack/my-plug/start/insert-status {{{1
g:hi_insert = 'highlight StatusLine gui=bold guifg=White guibg=darkred cterm=bold ctermfg=White ctermbg=darkred'
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
omap ac <Plug>(textobj-syntax-a)
omap ic <Plug>(textobj-syntax-i)
xmap ic <Plug>(textobj-syntax-i)
xmap ac <Plug>(textobj-syntax-a)

# 折りたたみをテキストオプジェクト化 https://github.com/kana/vim-textobj-fold {{{1
# キーマップ iz, az

# テキストオブジェクトで (), {} "", '' を区別せずにカーソル近くで判定して、全て b で扱えるようにする https://github.com/osyo-manga/vim-textobj-multiblock {{{1
# キーマップしないと ", ' の指定が働かない
omap ab <Plug>(textobj-multiblock-a)
omap ib <Plug>(textobj-multiblock-i)
xmap ab <Plug>(textobj-multiblock-a)
xmap ib <Plug>(textobj-multiblock-i)
g:textobj_multiblock_blocks = [
			[ '"', '"', 1 ],
			[ "'", "'", 1 ],
			[ '(', ')' ],
			[ '{', '}' ],
			[ '<', '>' ],
			[ '[', ']' ],
			]

# 補完 https://github.com/prabirshrestha/asyncomplete.vim {{{1
# asyncomplete.vim 自体は ~/.vim/pack/*/start に置かないと↓の最初の InsertEnter イベントが起きたバッファで補完が働かない
augroup loadasyncomplete
	autocmd!
	autocmd InsertEnter *
				\ set_asyncomplete#main()
				| autocmd! loadasyncomplete
				| augroup! loadasyncomplete
				| delfunction set_asyncomplete#main
augroup END

# 括弧や引用符をペアで入力/削除 ~/.vim/pack/my-plug/start/pair_bracket/ {{{1
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
	'*': {'type': ['help'], 'cmap': 0},     # tag
	'|': {'type': ['help'], 'cmap': 0},     # link
	'_': {'type': ['markdown'], 'cmap': 0}, # * は箇条書きで使う
	'~': {'type': ['markdown'], 'cmap': 0}, # 下付き添字
	'^': {'type': ['markdown'], 'cmap': 0}, # 上付き添字
	# ↓ ', " 自体の反応が遅くなる
	# "'''": {},
	# '"""': {},
	}

# ~/.vim/pack/*/{stat,opt}/* でプラグインを管理する上で、便利な関数 ~/.vim/pack/my-plug/start/manage-pack {{{1
# 遅延読み込みにすると、補完が使えない
# augroup loadManagePack
# 	autocmd!
# 	autocmd FuncUndefined manage_pack#* packadd manage-pack
# 		| autocmd! loadManagePack
# 		| augroup! loadManagePack
# 	autocmd CmdUndefined ReinstallPack packadd manage-pack
# 		| autocmd! loadManagePack
# 		| augroup! loadManagePack
# augroup END
