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
# * https://github.com/rbonvall/vim-textobj-css
#		- CSS をテキストオプジェクト化 ← vim-textobj-fold で代用できるしカーソルの桁位置でも変わるので、使いづらい
# * netfw を Fern に入れ替え https://github.com/lambdalisue/fern-hijack.vim
#		- TabEdit でディレクトリなら、Fern を起動するように変更

# vim-surround などのプラグインでも . リピートを可能にする https://github.com/tpope/vim-repeat {{{1
# }}}1

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
	autocmd ColorScheme * if &background ==# 'light'
				| highlight SignatureMarkText term=bold cterm=bold gui=bold ctermbg=NONE guibg=NONE guifg=#111111 ctermfg=0 | else
				| highlight SignatureMarkText term=bold cterm=bold gui=bold ctermbg=NONE guibg=NONE guifg=#dddddd ctermfg=15 | endif
				| highlight GitGutterAdd      term=bold cterm=bold gui=bold ctermbg=NONE guibg=NONE
				| highlight GitGutterChange   term=bold cterm=bold gui=bold ctermbg=NONE guibg=NONE
				| highlight GitGutterDelete   term=bold cterm=bold gui=bold ctermbg=NONE guibg=NONE
augroup END

# https://github.com/t9md/vim-foldtext を書き換え $MYVIMDIR/pack/my-plug/start/vim-foldtext/ {{{1
# }}}1

# カラースキム {{{1
# https://github.com/lifepillar/vim-solarized8 {{{2
# }}}2
# background によって一部の highlight を変える関数 (Solarized を基本としている) {{{2
def ColorschemeHighlight(): void
	def ChangeVert(): void
		var hlget_dic: dict<any> = hlget('VertSplit', true)[0]
		if (has_key(hlget_dic, 'cterm') && get(hlget_dic.cterm, 'revere', false)) || (has_key(hlget_dic, 'term') && get(hlget_dic.term, 'revere', false))
			extend(hlget_dic, {ctermbg: hlget_dic.ctermfg})
		else
			extend(hlget_dic, has_key(hlget_dic, 'ctermbg') ? {ctermfg: hlget_dic.ctermbg} : {})
		endif
		if has_key(hlget_dic, 'gui') && get(hlget_dic.gui, 'revere', false)
			extend(hlget_dic, {guibg: hlget_dic.guifg})
		else
			extend(hlget_dic, has_key(hlget_dic, 'guibg') ? {guifg: hlget_dic.guibg} : {})
		endif
		hlset([hlget_dic])
		return
	enddef
	var nbg: string = get(hlget('Normal')[0], 'guibg', (&background ==# 'light' ? '#fdf6e3' : '#002b36'))
	if &background ==# 'light'
		# Solarized の base01 を文字色に
		# ↓黒背景端末を使っているので背景色を明示する←端末も背景に NONE を使わない
		execute   'highlight Normal ctermfg=8 ctermbg=15 guifg=#073642 guibg=' .. nbg
		# execute 'highlight NormalDefault ctermfg=8 ctermbg=15 guifg=#073642 guibg=' .. nbg # 背景色 NONE にしない Normal
		           highlight CursorLineNr cterm=bold gui=bold ctermfg=3 ctermbg=15 guifg=#b58900 guibg=NONE
		if g:colors_name ==# 'solarized8'
			         highlight CursorColumn term=reverse ctermbg=254 guibg=#F5F2DC
			execute 'highlight PmenuSel ctermfg=8 ctermbg=15 guifg=#073642 guibg=' .. nbg
			# light/dark で同設定
			         highlight Comment term=NONE cterm=NONE gui=NONE ctermfg=14 guifg=#93a1a1
			         highlight link PmenuMatch Type
			         highlight link PmenuMatchSel Type
		endif
	else
		# Solarized の base1 を文字色に
		execute    'highlight Normal ctermfg=15 ctermbg=NONE guifg=#eee8d5 guibg=' .. (!has('gui_running') && g:colors_name ==# 'solarized8' ? 'NONE' : nbg)
		# execute   'highlight NormalDefault ctermfg=15 ctermbg=8 guifg=#eee8d5 guibg=' .. nbg # 背景色 NONE にしない Normal
			         highlight CursorLineNr cterm=bold gui=bold ctermfg=3 ctermbg=8 guifg=#b58900 guibg=NONE
		if g:colors_name ==# 'solarized8'
			         highlight CursorColumn term=reverse ctermbg=236 guibg=#0E414E
			execute 'highlight PmenuSel ctermfg=15 ctermbg=8 guifg=#eee8d5 guibg=' .. nbg
			# light/dark で同設定
			         highlight Comment term=NONE cterm=NONE gui=NONE ctermfg=14 guifg=#93a1a1
			         highlight link PmenuMatch Type
			         highlight link PmenuMatchSel Type
		endif
	endif
	# light/dark で同設定
	highlight SpellBad   term=underline cterm=underline ctermfg=NONE ctermul=9 guifg=NONE guisp=#cb4b16
	highlight SpellCap   term=underline cterm=underline ctermfg=NONE ctermul=13 guifg=NONE guisp=#6c71c4
	highlight SpellLocal term=underline cterm=underline ctermfg=NONE ctermul=3 guifg=NONE guisp=#b58900
	highlight SpellRare  term=underline cterm=underline ctermfg=NONE ctermul=6 guifg=NONE guisp=#2aa198
	highlight MatchParen term=bold,reverse cterm=bold,reverse gui=bold,reverse ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE
	highlight link QuickFixLine CursorLine
	highlight link CurSearch IncSearch
	ChangeVert()
enddef

def ColorschemeBefore(color: string): void # t_Co, termguicolors 等 colorscheme 切り替え前に必要な設定をする
	if color ==# 'solarized8'
		g:solarized_old_cursor_style = 1
		# g:solarized_italics = 0
		if !has('gui_running')
			set t_Co=256 # ←~/.tmux_conf set-option -g default-terminal "tmux-256color"
			set termguicolors
			# ↓端末側の色設定あれば不要? 変化が不明
			# &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
			# &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
		endif
	elseif !has('gui_running')
		set t_Co=256 # ←~/.tmux_conf set-option -g default-terminal "tmux-256color"
		set notermguicolors
	endif
enddef
# }}}2
set background=dark
augroup ChangeColorScheme
	autocmd!
	autocmd ColorScheme * ColorschemeHighlight()
	autocmd ColorSchemePre * ColorschemeBefore(expand('<amatch>'))
augroup END
for s in ['solarized8', 'habamax', 'desert', 'default']
	try # (glob() や getcompletion() を使う存在確認は遅い)
		execute 'colorscheme ' .. s
		break
	catch /^Vim\%((\a\+)\)\:E185:\C/
		continue
	endtry
endfor

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
