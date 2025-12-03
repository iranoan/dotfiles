vim9script
scriptencoding utf-8

# コマンドを使うなどの理由で $MYVIMDIR/pack/*/opt においているが、起動時に packadd しているために遅延にならない分 {{{1
# 2019-03-31 14:51 などの日付や時刻もうまい具合に Ctrl-a/x で加算減算する https://github.com/tpope/vim-speeddating {{{2
# 日時フォーマットを追加したいので、start に置かない
# 遅延読み込みにすると
# * 最初の使用時に {count}<C-a> の {cout} が効かない
# * ビジュアルモードの {count}<C-a> とした時、先頭しかカウントアップしない
# * 日時以外の普通の数字のカウント・アップ/ダウンができなくなる
g:speeddating_no_mappings = 1
packadd vim-speeddating
SpeedDatingFormat! %H:%M:%S
SpeedDatingFormat! %a %b %_d %H:%M:%S %Z %Y
SpeedDatingFormat! %a %h %-d %H:%M:%S %Y %z
SpeedDatingFormat! %B %o, %Y
SpeedDatingFormat! %d%[-/ ]%b%1%y
SpeedDatingFormat! %d%[-/ ]%b%1%Y
SpeedDatingFormat! %Y %b %d
SpeedDatingFormat! %b %d, %Y
SpeedDatingFormat! %-I%?[ ]%^P
SpeedDatingFormat %Y/%m/%d(%a)%?[ ]%H:%M:%S
SpeedDatingFormat %Y/%m/%d(%a)%?[ ]%H:%M
SpeedDatingFormat %Y/%m/%d%[ T_:]%H:%M:%S
SpeedDatingFormat %Y/%m/%d%[ T_:]%H:%M
SpeedDatingFormat %Y/%m/%d
SpeedDatingFormat %m/%d
SpeedDatingFormat %^P%?[ ]%I:%M
SpeedDatingFormat %H:%M:%S
SpeedDatingFormat %H:%M
# nnoremap d<C-X> <Plug>SpeedDatingNowLocal # ←上手く動作していない
nnoremap d<C-A> <Plug>SpeedDatingNowUTC
xnoremap <C-X>  <Plug>SpeedDatingDown
xnoremap <C-A>  <Plug>SpeedDatingUp
nnoremap <C-X>  <Plug>SpeedDatingDown
nnoremap <C-A>  <Plug>SpeedDatingUp

# テキストオブジェクト化の元となる https://github.com/kana/vim-textobj-user {{{2
# 遅延読み込みにすると、最初に gcaz 等、プラグイン+textobj-* の組み合わせた時うまく動作しない
# またこのファイルの処理自体に時間がかかるようになるので、遅延処理の美味みがない
# + 独自の定義を追加したい
# →読み込み明示
# ファイルタイプ別の設定は、基本 $MYVIMDIR/ftplugin/*.vim
packadd vim-textobj-user
# 以下のような日付や時間のテキストオブジェクト化 {{{3
# 2025/04/06 20:53:41
# 2025-04-06T20:53:41
# 2025/04/06
# 20:53:41
textobj#user#plugin('datetime', {
	datetime: {
		pattern: '\<\(\(\(\d\d\)\?\d\d[-/]\)\?\d\d\?[-/]\d\d\?\([ T]\d\d:\d\d\(:\d\d\)\?\)\?\|\d\d:\d\d\(:\d\d\)\?\)\>',
		scan: 'line',
		select: ['ad', 'id'],
	},
})
# パスや URL {{{3
textobj#user#plugin('uri', {
	uri: {
		pattern: '\%(\%(\%(https\=\|ftp\|gopher\)://\|\%(mailto\|file\|news\):\)[^][{}()'' \t<>"]\+\|\%(www\|web\|w3\)[a-z0-9_-]*\.[a-z0-9._-]\+\.[^][{}()'' \t<>"]\+\)[a-z0-9/]\|\%(\~\=/\)\=\%([-A-Za-z._0-9]\+/\)*[-A-Za-z._0-9]\+\%(\.\a\%([A-Za-z0-9]\{,3}\)\|/\)\?',
		scan: 'line',
		select: ['au', 'iu'],
	},
})
# CSV/TSV のセル内 {{{3
textobj#user#plugin('spreadsheet', {
	value-a: {
		pattern: '\(^[^\t]\+\ze\t\|\t\zs[^\t]\+\ze\(\t\|$\)\|\(^\|,\)"\zs\(""\|[^"]\)\+\ze"\(,\|$\)\|^[^,]\+\ze,\|,\zs[^,]\+\ze\(,\|$\)\)',
		scan: 'line',
		select: [],
	},
	value-i: {
		pattern: '\(^\s*\zs[^\t]\{-}\ze\s*\t\|\t\s*\zs[^\t]\{-}\%#[^\t]\{-}\ze\s*\(\t\|$\)\|\(^\|,\)"\s*\zs\(""\|[^"]\)\{-}\%#\(""\|[^"]\)\{-}\ze\s*"\(,\|$\)\|^\s*\zs[^,]\{-}\%#[^,]\{-}\ze\s*,\|,\s*\zs[^,]\{-}\%#[^,]\{-}\ze\s*\(,\|$\)\)',
		scan: 'line',
		select: [],
	},
	# value-i はセル内データの先頭に空白が有り、そこにカーソルが有るとそれ移行の空白も含まれてしまうのが欠点
})
augroup spreadsheet_textobj
	autocmd!
	autocmd FileType csv,tsv,notmuch-thread call textobj#user#map('spreadsheet', {
		\ 	value-a: {
		\ 		select: '<buffer> av',
		\ 	},
		\ 	value-i: {
		\ 		select: '<buffer> iv',
		\ 	},
		\ })
augroup END

# テキストオブジェクトで (), {} "", '' を区別せずにカーソル近くで判定して、全て b で扱えるようにする https://github.com/osyo-manga/vim-textobj-multiblock {{{2
# キーマップしないと ", ' の指定が働かない
# デフォルト・マップを削除したい→読み込み明示
packadd vim-textobj-multiblock
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
unmap isb
unmap asb

# Git の変更のあった signcolumn にマークをつける https://github.com/airblade/vim-gitgutter {{{2
# 遅延読み込みをすると vim-signature との連携機能が使えない←連携できないだけ
if executable('git') # git がないときに起動時にエラーになるため
	set_gitgutter#main()
endif

# autocmd 削除を纏められないにタイプ {{{1
# 括弧や引用符をペアで入力/削除 $MYVIMDIR/pack/my-plug/start/pair_bracket/ {{{2
# ドット・リピートは考慮していない
augroup SetPairBracket
	autocmd!
	autocmd InsertEnter,CmdlineEnter * set_pair_bracket#main()
		| autocmd_delete([{group: 'SetPairBracket'}])
augroup END

# 補完 https://github.com/prabirshrestha/asyncomplete.vim {{{2
augroup SetAsyncomplete # vim-lsp からも読み込まれるので、++once を使わない
	autocmd!
	autocmd InsertEnter * set_asyncomplete#main()
		| autocmd_delete([{group: 'SetAsyncomplete'}])
augroup END

# :Tabedit $MYVIMDIR/pack/my-plug/opt/tabedit/ {{{2
augroup TabEdit # tabedit, fern.vim, fzf.vim サイクリック依存
	autocmd!
	autocmd CmdUndefined TabEdit set_tabedit#main()
		| autocmd_delete([{group: 'TabEdit'}])
	autocmd FuncUndefined tabedit#* set_tabedit#main()
		| autocmd_delete([{group: 'TabEdit'}])
	autocmd CmdlineEnter : set_tabedit#main()
		| autocmd_delete([{group: 'TabEdit'}])
augroup END
# *.vim で再設定されてしまう分は $MYVIMDIR/after/ftplugin/vim.vim
nnoremap <silent>gf :TabEdit <C-R><C-P><CR>
# nnoremap <silent>gf :TabEdit <cfile><CR> " ← 存在しなくても開く <C-R><C-F> と同じ


# $MYVIMDIR/pack/*/{stat,opt}/* でプラグインを管理する上で、便利な関数 $MYVIMDIR/pack/my-plug/start/pack-manage {{{2
augroup loadPackManage
	autocmd!
	autocmd FuncUndefined pack_manage#* packadd pack-manage
		| autocmd_delete([{group: 'loadPackManage'}])
	autocmd CmdlineEnter : packadd pack-manage
		| autocmd_delete([{group: 'loadPackManage'}])
augroup END

# grep で幾つかのオプションをデフォルトで付けたり、補完を可能にする $MYVIMDIR/pack/my-plug/opt/gnu-grep/ {{{2
# statusline  w:quickfix_title 変更は $MYVIMDIR/ftplugin/qf.vim
augroup SetGnuGrep
	autocmd!
	autocmd CmdlineEnter : packadd gnu-grep
		| autocmd_delete([{group: 'SetGnuGrep'}])
	autocmd FuncUndefined gnu_grep#* packadd gnu-grep
		| autocmd_delete([{group: 'SetGnuGrep'}])
augroup END
g:gnu_grep = {'exclude-dir': '{.git,.cache,.thumbnail,cache,thumbnail,undo}'}

# 日本語ヘルプ https://github.com/vim-jp/vimdoc-ja {{{2
augroup VimDocJa
	autocmd!
	autocmd FileType vim packadd vimdoc-ja
		| autocmd_delete([{group: 'VimDocJa'}])
	autocmd CmdlineEnter : packadd vimdoc-ja
		| autocmd_delete([{group: 'VimDocJa'}])
augroup END

# ファイル・マネージャー https://github.com/lambdalisue/fern.vim {{{2
nnoremap <Leader>e <Cmd>call set_fern#FernSync()<CR>
augroup SetFernSync # tabedit, fern.vim, fzf.vim サイクリック依存
	# キーマップだけだと、ディレクトリ部分の gf で使えない
	autocmd CmdUndefined Fern set_fern#main()
		| autocmd_delete([{group: 'SetFernSync'}])
augroup END

# yank の履歴 https://github.com/Shougo/neoyank.vim {{{2
augroup SetNeoyank
	autocmd!
	autocmd TextYankPost * set_fzf#neoyank_sub()
		| autocmd_delete([{group: 'SetNeoyank'}])
augroup END

	# Man コマンドを使用可能にする $MYVIMDIR/pack/my-plug/opt/color-man {{{2
augroup ColorMan
	autocmd!
	autocmd CmdUndefined Man,ShellMan packadd color-man # *.sh の K (keywordprg) とシェルで vim +ShellMan 有効にするため
		| autocmd_delete([{group: 'ColorMan'}])
	autocmd CmdlineEnter : packadd color-man # 最初の使用時に補完を有効にするため
		| autocmd_delete([{group: 'ColorMan'}])
augroup END

# autocmd 削除を纏められる→++once が使えるタイプ {{{1
augroup SetPackOpt
	autocmd!

	# :terminal のカレントディレクトリをシェルのそれと動悸する https://github.com/tyru/sync-term-cwd.vim {{{2
	autocmd TerminalOpen * ++once packadd sync-term-cwd.vim

	# ディレクトリを再帰的に diff https://github.com/will133/vim-dirdiff {{{2
	autocmd CmdUndefined DirDiff ++once g:DirDiffForceLang = 'C LC_MESSAGES=C'
		| g:DirDiffExcludes = ".git,.*.swp"
		| packadd vim-dirdiff

	# 出力を quickfix に取り込む $MYVIMDIR/pack/my-plug/opt/output2qf {{{2
	# 小文字で始まるコマンドを定義可能に https://github.com/kana/vim-altercmd {{{2
	# カーソル位置の Syntax の情報を表示する $MYVIMDIR/pack/my-plug/opt/syntax_info/ {{{2 http://cohama.hateblo.jp/entry/2013/08/11/020849 を参考にした
	# Vim の環境を出力する $MYVIMDIR/pack/my-plug/opt/vim-system/ {{{2
	autocmd CmdlineEnter : ++once packadd output2qf
		| set_altercmd#main()
		| packadd syntax_info
		| packadd vim-system

	# dog と cat の入れ替えなどサイクリックに置換する関数などの定義 $MYVIMDIR/pack/my-plug/opt/replace-cyclic {{{2
	autocmd FuncUndefined replace#* ++once packadd replace-cyclic

	# *.docx をまとめて epub 用のファイルに変換 $MYVIMDIR/pack/my-plug/opt/docx2xhtml {{{2
	# カレント・ディレクトリに有る Google Document を使って OCR したファイルを前提とし、自作シェル・スクリプトや LibreOffice も呼び出しているごく個人的なスクリプト
	autocmd FuncUndefined docx2xhtml#main ++once packadd docx2xhtml

	# 印刷 $MYVIMDIR/pack/my-plug/opt/print/ {{{2
	autocmd CmdUndefined PrintBuffer ++once packadd print

	# notmuch-python-Vim $MYVIMDIR/pack/my-plug/opt/notmuch-py-vim/ {{{2
	autocmd CmdUndefined Notmuch ++once set_notmuchpy#main()
	nnoremap <silent><Leader>m <Cmd>Notmuch start<CR>

	# vim のヘルプ・ファイルから Readme.md を作成する https://github.com/LeafCage/vimhelpgenerator {{{2
	# 実際の読み込みは $MYVIMDIR/ftplugin/vim.vim

	# タグで挟む $MYVIMDIR/pack/my-plug/opt/surroundTag/ {{{2
	# vim-surround では複数のタグを一度につけたり、クラス指定まで含む場合タイプ量が多くなる
	# 実際のキーマップ等は $MYVIMDIR/ftplugin/html.vim

	# Markdown マッピング $MYVIMDIR/pack/my-plug/opt/map-markdown/ {{{2
	# 実際のキーマップ等は $MYVIMDIR/ftplugin/markdown.vim

	# 編集中の Markdown をブラウザでプレビューhttps://github.com/ribru17/markdown-preview.nvim  {{{2
	# do-setup: cd app && npx --yes yarn install
	# clone 直後では cd が失敗するが対処法が見つからず
	# help がないので上記 URL か $MYVIMDIR/pack/github/opt/markdown-preview.nvim/README.md
	# 実際のキーマップ等は $MYVIMDIR/ftplugin/markdown.vim
	# オリジナルの
	# https://github.com/iamcco/markdown-preview.nvim
	# は↓のエラーが発生する
	# Error detected while processing BufHidden Autocommands for "<buffer=1>"..function mkdp#rpc#preview_close[11]..mkdp#autocmd#clear_buf:
	# line    1:
	# E216: No such group or event: MKDP_REFRESH_INIT10
	# →https://github.com/iamcco/markdown-preview.nvim/pull/576#issuecomment-3160302264

	# conky シンタックス https://github.com/smancill/conky-syntax.vim {{{2 ←署名を見ると同じ開発元だが、標準パッケージに含まれているものだと上手く動作しない
	autocmd BufNewFile,BufRead conkyrc,conky.conf ++once packadd conky-syntax.vim

	# getmail syntax https://github.com/vim-scripts/getmail.vim {{{2
	# 	autocmd BufRead ~/.getmail/*,~/.config/getmail/* set_getmail_vim#main()
	# 		| autocmd! SetPackOpt BufRead ~/.getmail/*,~/.config/getmail/*

	# vim 折りたたみ fold $MYVIMDIR/pack/my-plug/opt/vim-ft-vim_fold/ {{{2 https://github.com/thinca/vim-ft-vim_fold を組み合わせ追加のために置き換え
	# 実際の読み込みは $MYVIMDIR/ftplugin/vim.vim

	# CSS シンタックス https://github.com/hail2u/vim-css3-syntax {{{2
	# 実際の読み込みは $MYVIMDIR/ftplugin/css.vim

	# LaTeX をテキストオプジェクト化 https://github.com/rbonvall/vim-textobj-latex {{{2
	# depends = ['vim-textobj-user']
	# できるのは次のテキストオプジェクト
	# a\ 	i\ 	Inline math surrounded by \( and \).
	# a$ 	i$ 	Inline math surrounded by dollar signs.
	# aq 	iq 	Single-quoted text `like this'.
	# aQ 	iQ 	Double-quoted text ``like this''.
	# ae 	ie 	Environment \begin{…} to \end{…}
	# LaTeX fold 折りたたみ https://github.com/matze/vim-tex-fold {{{2
	# 実際の読み込みは $MYVIMDIR/ftplugin/tex.vim

augroup END # }}}1

# Filetype をトリガーとする {{{1
# $MYVIMDIR/pack でプラグインを管理する上で、FileType で読み込んだプラグインを再設定するために、再度 setfiletype して、そのイベント・トリガーを削除 {{{2
augroup ResetFiletype
	autocmd!
	for [t, e] in items({
			awk: '*.awk',
			c: '*.c',
			cpp: '*.h,*.cpp',
			python: '*.py',
			vim: '*.vim,.vimrc,vimrc,_vimrc,.gvimrc,gvimrc,_gvimrc',
			ruby: '*.rb',
			lua: '*.lua',
			yaml: '*.yml',
			html: '*.htm,*.html',
			xhtml: '*.xhtml',
			css: '*.css',
			tex: '*.tex',
			sh: '*.sh',
			bash: '*.bash,.bash_history,.bashrc,~/dotfiles/.config/bash/*,~/.config/bash/*',
			json: '*.json,.textlintrc,.stylelintrc,.htmlhintrc',
			markdown: '*.md',
			go: '*.go',
			conkyrc: 'conkyrc,conky.conf'
		})
		execute 'autocmd BufWinEnter ' .. e .. ' ++once call execute("setfiletype " .. &filetype)'
						.. ' | autocmd! ResetFiletype BufWinEnter ' .. e
	endfor
augroup END

# 日本語入力に向いた設定にする (行の連結など) https://github.com/vim-jp/autofmt {{{2
augroup loadautofmt
	autocmd!
	autocmd FileType text,mail,notmuch-edit set_autofmt#main()
		| autocmd_delete([{group: 'loadautofmt'}])
augroup END

# 各種言語の構文チェック https://github.com/dense-analysis/ale {{{2
augroup loadALE
	autocmd!
	# autocmd FileType c,cpp,python,ruby,yaml,markdown,html,xhtml,css,tex,help
	autocmd FileType c,cpp,ruby,yaml,markdown,html,xhtml,css,tex,help set_ale#main()
		| autocmd_delete([{group: 'loadALE'}])
augroup END

# C/C++シンタックス https://github.com/vim-jp/vim-cpp {{{2
# #ifdef 〜 #endif をテキストオプジェクト化→a#, i# https://github.com/anyakichi/vim-textobj-ifdef {{{2
# depends = ['vim-textobj-user']
# 実際の読み込みは $MYVIMDIR/ftplugin/c.vim

# 判定にシンタックスを用いる https://github.com/haya14busa/vim-textobj-function-syntax {{{2
# depends = ['vim-textobj-user']
# 関数をテキストオプジェクト化 https://github.com/kana/vim-textobj-function {{{2
# af, if に割当
augroup loadTextObjFunc
	autocmd!
	autocmd FileType c,cpp,vim packadd vim-textobj-function
		| packadd vim-textobj-function-syntax
		| autocmd_delete([{group: 'loadTextObjFunc'}])
augroup END

# https://github.com/prabirshrestha/vim-lsp {{{2
augroup loadvimlsp
	autocmd!
	autocmd FileType awk,c,cpp,python,vim,lua,ruby,yaml,markdown,sh,bash,go,conf,json set_vimlsp#main()
		| autocmd_delete([{group: 'loadvimlsp'}])
augroup END

# カーソル位置に合わせて filetype を判定←各種プラグインが依存 https://github.com/Shougo/context_filetype.vim {{{2
augroup loadcontext_filetype
	autocmd!
	autocmd FileType sh,bash,vim,html,xhtml,markdown,lua set_context_filetype#main()
		| autocmd_delete([{group: 'loadcontext_filetype'}])
augroup END

# $MYVIMDIR/pack/my-plug/opt/ft-fold {{{2
augroup loadFileTypeFold
	autocmd!
	autocmd FileType python,help,awk packadd ft-fold
		| autocmd_delete([{group: 'loadFileTypeFold'}])
augroup END

# キーマップし読み込みもする分 {{{1
# カーソル位置の単語を Google で検索 $MYVIMDIR/pack/my-plug/opt/google-search/ {{{2 https://www.rasukarusan.com/entry/2019/03/09/011630 を参考にした
nnoremap <silent><Leader>s <Cmd>call set_google_search#main()<CR>
xnoremap <silent><Leader>s <Cmd>call set_google_search#main()<CR>

# ctags や LSP を使った list https://github.com/liuchengxu/vista.vim {{{2
# アウトライン https://github.com/vim-voom/VOoM {{{2
nnoremap <silent><Leader>o <Cmd>call set_vista_voom#Switch()<CR>

# ページ送りに $MYVIMDIR/pack/my-plug/opt/page-down {{{2
nnoremap <silent><space> <Cmd>call set_page_down#main()<CR>

# Undo をツリー表示で行き来する https://github.com/mbbill/undotree {{{2
nnoremap <silent><Leader>u <Cmd>call set_undotree#main()<CR>

# https://github.com/puremourning/vimspector {{{2
nnoremap <Leader>df       <Cmd>call set_vimspector#main('call vimspector#AddFunctionBreakpoint(''<cexpr>'')')<CR>
nnoremap <Leader>dc       <Cmd>call set_vimspector#main('call vimspector#Continue()')<CR>
nnoremap <Leader>dd       <Cmd>call set_vimspector#main('call vimspector#DownFrame()')<CR>
nnoremap <Leader>dp       <Cmd>call set_vimspector#main('call vimspector#Pause()')<CR>
nnoremap <Leader>dR       <Cmd>call set_vimspector#main('call vimspector#Restart()')<CR>
nnoremap <Leader>dr       <Cmd>call set_vimspector#main('call vimspector#RunToCursor()')<CR>
nnoremap <Leader>ds       <Cmd>call set_vimspector#main('call vimspector#StepInto()')<CR>
nnoremap <Leader>dS       <Cmd>call set_vimspector#main('call vimspector#StepOut()')<CR>
nnoremap <Leader>dn       <Cmd>call set_vimspector#main('call vimspector#StepOver()')<CR>
nnoremap <Leader>d<Space> <Cmd>call set_vimspector#main('call vimspector#Stop()')<CR>
nnoremap <Leader>db       <Cmd>call set_vimspector#main('call vimspector#ToggleBreakpoint()')<CR>
nnoremap <Leader>dx       <Cmd>call set_vimspector#main('call vimspector#Reset( { ''interactive'': v:false } )')<CR>
nnoremap <Leader>di       <Cmd>call set_vimspector#main('VimspectorBalloonEval')<CR>
xnoremap <Leader>di       <Cmd>call set_vimspector#main('VimspectorBalloonEval')<CR>

# カーソル行の URL やファイルを開く $MYVIMDIR/pack/my-plug/opt/open_uri/ {{{2
nnoremap <silent><Leader>x <Cmd>call set_open_uri#main()<CR>
nnoremap <2-LeftMouse>     <Cmd>call set_open_uri#main()<CR>

# 文字の変換 $MYVIMDIR/pack/my-plug/opt/transform/ {{{2
nnoremap <Leader>ha <Cmd>call set_transform#main('Zen2han')<CR>
xnoremap <Leader>ha <Cmd>call set_transform#main('Zen2han')<CR>
nnoremap <Leader>hh <Cmd>call set_transform#main('InsertSpace')<CR>
xnoremap <Leader>hh <Cmd>call set_transform#main('InsertSpace')<CR>
nnoremap <Leader>hz <Cmd>call set_transform#main('Han2zen')<CR>
xnoremap <Leader>hz <Cmd>call set_transform#main('Han2zen')<CR>
nnoremap <Leader>hk <Cmd>call set_transform#main('Hira2kata')<CR>
xnoremap <Leader>hk <Cmd>call set_transform#main('Hira2kata')<CR>
nnoremap <Leader>hH <Cmd>call set_transform#main('Kata2hira')<CR>
xnoremap <Leader>hH <Cmd>call set_transform#main('Kata2hira')<CR>
# nnoremap <Leader>hb :Base64<CR>

# https://github.com/junegunn/fzf.vim {{{2 # tabedit, fern.vim, fzf.vim サイクリック依存
nnoremap <silent><Leader>fr <Cmd>call set_fzf#vim('Files ~')<CR>
xnoremap <silent><Leader>fr <Cmd>call set_fzf#vim('Files ~')<CR>
nnoremap <silent><Leader>ff <Cmd>call set_fzf#vim('Files')<CR>
xnoremap <silent><Leader>ff <Cmd>call set_fzf#vim('Files')<CR>
nnoremap <silent><Leader>fu <Cmd>call set_fzf#vim('Files ..')<CR>
xnoremap <silent><Leader>fu <Cmd>call set_fzf#vim('Files ..')<CR>
nnoremap <silent><Leader>f. <Cmd>call set_fzf#vim('Files ~/dotfiles')<CR>
xnoremap <silent><Leader>f. <Cmd>call set_fzf#vim('Files ~/dotfiles')<CR>
nnoremap <silent><Leader>fv <Cmd>call set_fzf#vim('Files $MYVIMDIR')<CR>
xnoremap <silent><Leader>fv <Cmd>call set_fzf#vim('Files $MYVIMDIR')<CR>
nnoremap <silent><Leader>fs <Cmd>call set_fzf#vim('Files ~/src')<CR>
xnoremap <silent><Leader>fs <Cmd>call set_fzf#vim('Files ~/src')<CR>
nnoremap <silent><Leader>fx <Cmd>call set_fzf#vim('Files ~/bin')<CR>
xnoremap <silent><Leader>fx <Cmd>call set_fzf#vim('Files ~/bin')<CR>
nnoremap <silent><Leader>fe <Cmd>call set_fzf#vim('Files ~/book/epub')<CR>
xnoremap <silent><Leader>fe <Cmd>call set_fzf#vim('Files ~/book/epub')<CR>
nnoremap <silent><Leader>fd <Cmd>call set_fzf#vim('Files ~/downloads')<CR>
xnoremap <silent><Leader>fd <Cmd>call set_fzf#vim('Files ~/downloads')<CR>
nnoremap <silent><Leader>fD <Cmd>call set_fzf#vim('Files ~/Document')<CR>
xnoremap <silent><Leader>fD <Cmd>call set_fzf#vim('Files ~/Document')<CR>
nnoremap <silent><Leader>fp <Cmd>call set_fzf#vim('Files ~/public_html/iranoan')<CR>
xnoremap <silent><Leader>fp <Cmd>call set_fzf#vim('Files ~/public_html/iranoan')<CR>
nnoremap <silent><Leader>fi <Cmd>call set_fzf#vim('Files ~/Information/slide')<CR>
xnoremap <silent><Leader>fi <Cmd>call set_fzf#vim('Files ~/Information/slide')<CR>
# nnoremap <silent><Leader>fb <Cmd>call set_fzf#vim('Buffers')<CR>
# xnoremap <silent><Leader>fb <Cmd>call set_fzf#vim('Buffers')<CR>
nnoremap <silent><Leader>fc <Cmd>call set_fzf#vim('Commands')<CR>
xnoremap <silent><Leader>fc <Cmd>call set_fzf#vim('Commands')<CR>
nnoremap <silent><Leader>fg <Cmd>call set_fzf#vim('GFiles?')<CR>
xnoremap <silent><Leader>fg <Cmd>call set_fzf#vim('GFiles?')<CR>
nnoremap <silent><Leader>fh <Cmd>call set_fzf#vim('HISTORY')<CR>
xnoremap <silent><Leader>fh <Cmd>call set_fzf#vim('HISTORY')<CR>
nnoremap <silent><Leader>fl <Cmd>call set_fzf#vim('BLines')<CR>
xnoremap <silent><Leader>fl <Cmd>call set_fzf#vim('BLines')<CR>
nnoremap <silent><Leader>fm <Cmd>call set_fzf#vim('Marks')<CR>
xnoremap <silent><Leader>fm <Cmd>call set_fzf#vim('Marks')<CR>
nnoremap <silent>m/         <Cmd>call set_fzf#vim('Marks')<CR>
xnoremap <silent>m/         <Cmd>call set_fzf#vim('Marks')<CR>
# ↑ vim-signature のデフォルト・キーマップをこちらに再定義
# nnoremap <silent><Leader>ft <Cmd>call set_fzf#vim('Tags')<CR>
# xnoremap <silent><Leader>ft <Cmd>call set_fzf#vim('Tags')<CR>
# nnoremap <silent><Leader>fw <Cmd>call set_fzf#vim('Windows')<CR>
# xnoremap <silent><Leader>fw <Cmd>call set_fzf#vim('Windows')<CR>
nnoremap <silent><Leader>f: <Cmd>call set_fzf#vim('History :')<CR>
xnoremap <silent><Leader>f: <Cmd>call set_fzf#vim('History :')<CR>
nnoremap <silent><Leader>f/ <Cmd>call set_fzf#vim('History /')<CR>
xnoremap <silent><Leader>f/ <Cmd>call set_fzf#vim('History /')<CR>

# fzf.vim の Helptas の代わりに HelpTags を使う $MYVIMDIR/pack/my-plug/opt/fzf-help {{{2
nnoremap <silent><Leader>fH <Cmd>call set_fzf#help()<CR>
xnoremap <silent><Leader>fH <Cmd>call set_fzf#help()<CR>

# yank の履歴 https://github.com/justinhoward/fzf-neoyank {{{2
nnoremap <Leader>fy <Cmd>call set_fzf#neoyank('FZFNeoyank')<CR>
nnoremap <Leader>fY <Cmd>call set_fzf#neoyank('FZFNeoyank " P')<CR>
xnoremap <Leader>fy <Cmd>call set_fzf#neoyank('FZFNeoyankSelection')<CR>

# fzf を使ってタブ・ページの切り替え $MYVIMDIR/pack/my-plug/opt/fzf-tabs/ {{{2
nnoremap <Leader>ft <Cmd>call set_fzf#tabs()<CR>
vnoremap <Leader>ft <Cmd>call set_fzf#tabs()<CR>
nnoremap <Leader>fb <Cmd>call set_fzf#tabs()<CR>
nnoremap <Leader>fw <Cmd>call set_fzf#tabs()<CR>

# ソースの実行結果を別バッファに表示 https://github.com/thinca/vim-quickrun {{{2
nnoremap <silent><Leader>qr  <Cmd>call set_quickrun#main()<CR>
xnoremap <silent><Leader>qr  <Cmd>call set_quickrun#main()<CR>
inoremap <silent><C-\>qr     <Cmd>call set_quickrun#main()<CR>

# 整形 https://github.com/junegunn/vim-easy-align {{{2
# 下記の例の ip はテキスト・オブジェクトの「段落」を表す
# |command|how to remember|
# |---|---|
# |vipga=|visual-select inner paragragh ga =|
# |gaip=|ga inner paragragh =|
# に対して
# ヴィジュアルモードで選択し整形.(e.g. vip<Enter> or vip<Leader>ea)
# easy-align を呼んだ上で、移動したりテキストオブジェクトを指定して整形.(e.g. <Leader>eaip)
# * ←範囲 (列数) 指定
# | 基準となる記号
# のタイプで↓と整形
# | command | how to remember                    |
# | ---     | ---                                |
# | vipga=  | visual-select inner paragragh ga = |
# | gaip=   | ga inner paragragh =               |
xnoremap <Enter>    <Cmd>call set_easy_align#main()<CR>
xnoremap <Leader>ea <Cmd>call set_easy_align#main()<CR>
nnoremap <Leader>ea <Cmd>call set_easy_align#main()<CR>
# ↑全て対象を全体 * にしたいが、nmap の <Leader>eaip などテキストオブジェクトの場合の方法がわからない

# EPWING の辞書を呼び出す https://github.com/deton/eblook.vim {{{2
xnoremap <silent><Leader>eb <Cmd>call set_eblook#SearchVisual()<CR>
nnoremap <silent><Leader>eb <Cmd>call set_eblook#SearchWord()<CR>
xnoremap <silent>K          <Cmd>call set_eblook#SearchVisual()<CR>
nnoremap <silent>K          <Cmd>call set_eblook#SearchWord()<CR>

# 素早く移動する https://github.com/easymotion/vim-easymotion {{{2
for key in ['f', 'F', 't', 'T', 'w', 'W', 'b', 'B', 'e', 'E', 'ge', 'gE', 'j', 'k', 'n', 'N']
	execute 'nnoremap <Leader><Leader>' .. key .. '  <Cmd>call set_easymotion#main(''(easymotion-' .. key .. ')'')<CR>'
	execute 'xnoremap <Leader><Leader>' .. key .. '  <Cmd>call set_easymotion#main(''(easymotion-' .. key .. ')'')<CR>'
endfor
nnoremap <Leader><Leader>; <Cmd>call set_easymotion#main('(easymotion-next)')<CR>
nnoremap <Leader><Leader>, <Cmd>call set_easymotion#main('(easymotion-prev)')<CR>

# 各種言語のコメントの追加/削除 gc{motion} https://github.com/tpope/vim-commentary {{{2
# マッピングは gc{motion}
nnoremap gcu <Cmd>call set_commentary#main('Commentary Commentary')<CR>
nnoremap gcc <Cmd>call set_commentary#main('CommentaryLine')<CR>
onoremap gc  <Cmd>call set_commentary#main('Commentary')<CR>
nnoremap gc  <Cmd>call set_commentary#main('Commentary')<CR>
xnoremap gc  <Cmd>call set_commentary#main('Commentary')<CR>

# カッコだけでなくタグでも括る https://github.com/tpope/vim-surround {{{2
xnoremap s   <Cmd>call set_surround#main('VSurround')<CR>
xnoremap gS  <Cmd>call set_surround#main('VgSurround')<CR>
# ↑s と似ているが前後で改行 v_s は v_c と同じなのでキーマップを潰しても良いが、v_S は同じ意味のキーマップが無いので、gS に割り当てている
nnoremap ysS <Cmd>call set_surround#main('YSsurround')<CR>
# ↑行全体を挟む (前後に改行)
nnoremap yss <Cmd>call set_surround#main('Yssurround')<CR>
# ↑行全体を挟む
nnoremap yS  <Cmd>call set_surround#main('YSurround')<CR>
#↑↓に対して前後に改行
nnoremap ys  <Cmd>call set_surround#main('Ysurround')<CR>
nnoremap cS  <Cmd>call set_surround#main('CSurround')<CR>
nnoremap cs  <Cmd>call set_surround#main('Csurround')<CR>
nnoremap ds  <Cmd>call set_surround#main('Dsurround')<CR>
# <Shift> を押すのが面倒
var qq1: string
var qq2: string
for [n, q] in items({ 2: '"', 7: "'", 8: '(', 9: ')', '@': '`', ',': '<', '.': '>'})
	qq1 = q == "'" ? "''" : q
	execute 'nnoremap ds'  .. n .. ' <Cmd>call set_surround#main(''Dsurround'', ''' .. qq1 .. ''')<CR>'
	execute 'nnoremap ys4' .. n .. ' <Cmd>call set_surround#main(''Ysurround'', ''$' .. qq1 .. ''')<CR>'
	execute 'nnoremap ys4' .. q .. ' <Cmd>call set_surround#main(''Ysurround'', ''$' .. qq1 .. ''')<CR>'
	execute 'nnoremap ys$' .. n .. ' <Cmd>call set_surround#main(''Ysurround'', ''$' .. qq1 .. ''')<CR>'
endfor
for q in ['[', ']', '{', '}']
	execute 'nnoremap ys4' .. q .. ' <Cmd>call set_surround#main(''Ysurround'', ''$' .. q .. ''')<CR>'
endfor
for [n1, q1] in items({ 2: '"', 7: "'", 8: '(', 9: ')', '@': '`', ',': '<', '.': '>', '"': '"', "'": "'", '(': '(', ')': ')', '`': '`', '<': '<', '>': '>', '[': '[', ']': ']', '{': '{', '}': '}'})
	for [n2, q2] in items({ 2: '"', 7: "'", 8: '(', 9: ')', '@': '`', ',': '<', '.': '>', '"': '"', "'": "'", '(': '(', ')': ')', '`': '`', '<': '<', '>': '>', '[': '[', ']': ']', '{': '{', '}': '}'})
		qq1 = q1 == "'" ? "''" : q1
		qq2 = q2 == "'" ? "''" : q2
		execute 'nnoremap ysi' .. n1 .. n2 .. ' <Cmd>call set_surround#main(''Ysurround'', ''i' .. qq1 .. qq2 .. ''')<CR>'
		execute 'nnoremap ysa' .. n1 .. n2 .. ' <Cmd>call set_surround#main(''Ysurround'', ''a' .. qq1 .. qq2 .. ''')<CR>'
		if n1 !=# n2 && q1 !=# q2 && n1 !=# q2 && q1 !=# n2
			execute 'nnoremap cs' .. n1 .. n2 .. ' <Cmd>call set_surround#main(''Csurround'', ''' .. qq1 .. qq2 .. ''')<CR>'
		endif
	endfor
endfor
