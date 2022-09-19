scriptversion 4
scriptencoding utf-8

" プラグイン管理 {{{1
" パッケージの入手は、~/.vim/pack/*/{start,opt} のいずれかで
" git clone https://github.com/<author>/<package> <package>
" 導入しただけで、設定の無い分はコメントで簡単な説明と入手先

" ~/.vim/pack でプラグインを管理する上で、FileType で読み込んだプラグインを再設定するために、再度 setfiletype して、そのイベント・トリガーを削除 {{{2
for s in ['c', 'cpp', 'python', 'vim', 'ruby', 'yaml', 'html', 'xhtml', 'css', 'tex', 'sh', 'markdown', 'go', 'help']
	if s ==# 'python'
		let ext = '*.py'
	elseif s ==# 'ruby'
		let ext = '*.rb'
	elseif s ==# 'yaml'
		let ext = '*.yml'
	elseif s ==# 'html'
		let ext = '*.htm,*.html'
	elseif s ==# 'vim'
		let ext = '*.vim,.vimrc,vimrc,_vimrc,.gvimrc,gvimrc,_gvimrc'
	elseif s ==# 'markdown'
		let ext = '*.md'
	else
		let ext = '*.' .. s
	endif
	execute 'augroup ResetFiletype__' .. s
					 autocmd!
	execute	'    autocmd BufWinEnter ' .. ext .. ' setfiletype ' .. s .. '| autocmd! ResetFiletype__' .. s
					augroup END
endfor
unlet ext s
" 2}}}
" まず ~/.vim/pack/*/start 配下で遅延読込しない分 {{{1
" vim-surround などのプラグインでも . リピートを可能にする https://github.com/tpope/vim-repeat {{{2

" マークを可視化 visial mark https://github.com/kshenoy/vim-signature {{{2
" デフォルト・キー・マップ
" help SignatureMappings

": Tabedit ~/.vim/pack/my-plug/start/tabedit/ {{{2
nnoremap <silent>gf :TabEdit <C-r><C-p><CR>
" nnoremap <silent>gf :TabEdit <cfile><CR> " ← 存在しなくても開く <C-r><C-f> と同じ
" ↑opt/ に入れて呼び出すようにすると、最初の使用時に補完が働かない

" https://github.com/t9md/vim-foldtext を ~/.vim/pack/my-plug/start/vim-foldtext/ で書き換え {{{2

" ~/.vim/pack/ で管理している分のヘルプのタグを作成 ~/.vim/pack/my-plug/start/pack-helptags/ {{{2

" shell program を用いてバッファにフィルタを掛ける ~/.vim/pack/my-plug/start/shell-filter/ {{{2

" カーソル行の URL やファイルを開く ~/.vim/pack/my-plug/start/open_uri/ {{{2

" カラースキム https://github.com/altercation/vim-colors-solarized {{{2
set background=dark
if glob('~/.vim/pack/*/*/vim-colors-solarized/colors/*', 1, 1) != []
	set t_Co=16 " ターミナルが 256 色だと、highlight Terminal の色を Normal と同じにできない
	let g:solarized_menu = 0
	colorscheme solarized
else
	colorscheme desert
endif
" background によって一部の syntax を変える (Solaraized を基本としている) {{{
def s:color_light_dark(): void
	highlight clear Pmenu # 一部の絵文字が標準設定では見にくいので一旦クリアして ligh/dark で異なる設定にする
	if &background ==? 'light'
		highlight Normal guifg=#111111 guibg=#FDF6E3 ctermfg=black ctermbg=white
		highlight CursorLineNr gui=bold cterm=bold ctermfg=3 guifg=Brown
		highlight LineNr guifg=#000000 guibg=#EEEEEE cterm=NONE ctermfg=Blue
		highlight Comment gui=NONE guifg=#008800 ctermfg=DarkGreen
		highlight StatusLine term=bold ctermfg=black ctermbg=white
		highlight TabLineSel cterm=bold,underline ctermfg=black ctermbg=white
		# highlight TabLine cterm=underline ctermfg=black ctermbg=white
		highlight TabLineFill cterm=underline ctermfg=black ctermbg=white
		highlight Pmenu guifg=#000000 guibg=#EEEEEE cterm=NONE ctermfg=Blue
	else
		highlight Normal guifg=#DDDDDD ctermfg=15 ctermbg=8
		highlight CursorLineNr gui=bold cterm=bold ctermfg=3 guifg=Yellow
		highlight LineNr guibg=#00282D ctermfg=15
		highlight Comment gui=NONE guifg=#00A800 ctermfg=DarkGreen
		highlight StatusLine term=bold ctermfg=white ctermbg=black
		highlight TabLineSel cterm=bold,underline ctermfg=white ctermbg=black
		# highlight TabLine cterm=underline ctermfg=white ctermbg=black
		highlight TabLineFill cterm=underline ctermfg=white ctermbg=black
		highlight Pmenu guibg=#00282D ctermfg=15
	endif
	# light/dark で同設定
	highlight SpellBad   term=underline cterm=underline
	highlight SignColumn ctermbg=NONE guibg=NONE
	highlight SpecialKey term=bold ctermfg=DarkGray guifg=DarkGray
	# Terminal の色は Normal に揃える
	# これはバグで 8.2.3996 ～ 8.2.5172 のどこかで修正ずみ→https://github.com/vim-jp/issues/issues/1388
	highlight clear Terminal
	execute 'highlight Terminal ' .. substitute(substitute(execute('highlight Normal'), '[\n\r\s]\+', ' ', 'g'), ' *Normal\s\+xxx *', '', '')
enddef
augroup ChangeHighlight
	autocmd!
	autocmd ColorScheme * call s:color_light_dark()
augroup END
call s:color_light_dark()

" 日本語ヘルプ {{{2
" packadd vimdoc-ja " https://github.com/vim-jp/vimdoc-ja

"挿入モード時、ステータスラインの色を変更 ~/.vim/pack/my-plug/start/insert-status {{{2
let g:hi_insert = 'highlight StatusLine gui=bold guifg=white guibg=darkred cterm=bold ctermfg=white ctermbg=darkred'
" ↑インサート・モード時の hilight 指定

" テキストオブジェクト化の元となる https://github.com/kana/vim-textobj-user {{{2
" 遅延読み込みにすると、最初に gcaz 等、プラグイン+textobj-* の組み合わせた時うまく動作しない
" またこのファイルの処理自他に時間がかかるようになるので、遅延処理の美味みがない

" 同じインデントをテキストオプジェクト化 https://github.com/kana/vim-textobj-indent {{{2
" キーマップ ii, ai

" シンタックスをテキストオプジェクト化 https://github.com/kana/vim-textobj-syntax {{{2
" キーマップ iy, ay
" コメントのテキスト・オブジェクト化 https://github.com/thinca/vim-textobj-comment {{{3
" キーマップ ic, ac →コメントより優先されるシンタックスは多くないので syntax on なら vim-textobj-syntax が有れば良い
omap ac <Plug>(textobj-syntax-a)
omap ic <Plug>(textobj-syntax-i)
xmap ic <Plug>(textobj-syntax-i)
xmap ac <Plug>(textobj-syntax-a)

" 折りたたみをテキストオプジェクト化 https://github.com/kana/vim-textobj-fold {{{2
" キーマップ iz, az

" テキストオブジェクトで (), {} "", '' を区別せずにカーソル近くで判定して、全て b で扱えるようにする https://github.com/osyo-manga/vim-textobj-multiblock {{{2
" キーマップしなと ", ' の指定が働かない
	omap ab <Plug>(textobj-multiblock-a)
	omap ib <Plug>(textobj-multiblock-i)
	xmap ab <Plug>(textobj-multiblock-a)
	xmap ib <Plug>(textobj-multiblock-i)
let g:textobj_multiblock_blocks = [
			\ [ '"', '"', 1 ],
			\ [ "'", "'", 1 ],
			\ [ '(', ')' ],
			\ [ '{', '}' ],
			\ [ '<', '>' ],
			\ [ '[', ']' ],
			\ ]

" 補完 https://github.com/prabirshrestha/asyncomplete.vim {{{2
" asyncomplete.vim 自体は ~/.vim/pack/*/start に置かないと↓の最初の InsertEnter イベントが起きたバッファで補完が働かない
augroup loadasyncomplete
	autocmd!
	autocmd InsertEnter *
				\ call set_asyncomplete#main()
				\ | autocmd! loadasyncomplete
				" \ | delfunction set_asyncomplete#main ←実際には Insert 時だけでなく vim-lsp 読み込み時にも設定される
augroup END

" ここから ~/.vim/pack/*/opt 配下 {{{1
" 小文字で始まるコマンドを定義可能に https://github.com/kana/vim-altercmd {{{2
" ↓実質 /start/と同じになるが、単純に /start/ に置くと、このスクリプト読み込み時点では AlterCommand が使えず、エラーになるので読み込み明示形式にする
packadd vim-altercmd
AlterCommand e[dit] TabEdit
AlterCommand u[tf8] edit\ ++enc=utf8
AlterCommand sj[is] edit\ ++enc=cp932
AlterCommand c[p932] edit\ ++enc=cp932
AlterCommand eu[c] edit\ ++enc=euc-jp
AlterCommand j[is] edit\ ++enc=iso-2022-jp-3
AlterCommand gr[ep] silent\ grep
AlterCommand mak[e] silent\ make
AlterCommand ter[minal] topleft\ terminal
AlterCommand man Man
AlterCommand p[rint] call\ print#main()
" ↑:print は使わないので、印刷関数 (~/.vim/autoload/print.vim) に置き換え
if len(glob(expand('~/.vim/pack/*/*/vim-fugitive/plugin/fugitive.vim'), 1, 1))
	AlterCommand git Git
	AlterCommand gs[tatus] Git
	AlterCommand gl[og] Gllog
	AlterCommand gd[iff] Gdiffsplit
endif

" 2019-03-31 14:51 などの日付や時刻もうまい具合に Ctrl-a/x で加算減算する https://github.com/tpope/vim-speeddating {{{2
nmap d<C-X> <Cmd>call set_speeddating#main('SpeedDatingNowLocal') <bar> delfunction set_speeddating#main<CR>
nmap d<C-A> <Cmd>call set_speeddating#main('SpeedDatingNowUTC') <bar> delfunction set_speeddating#main<CR>
xmap <C-X>  <Cmd>call set_speeddating#main('SpeedDatingDown') <bar> delfunction set_speeddating#main<CR>
xmap <C-A>  <Cmd>call set_speeddating#main('SpeedDatingUp') <bar> delfunction set_speeddating#main<CR>
nmap <C-X>  <Cmd>call set_speeddating#main('SpeedDatingDown') <bar> delfunction set_speeddating#main<CR>
nmap <C-A>  <Cmd>call set_speeddating#main('SpeedDatingUp') <bar> delfunction set_speeddating#main<CR>

" https://github.com/junegunn/fzf.vim {{{2
nnoremap <silent><Leader>fc :Commands<CR>
nnoremap <silent><Leader>fr :Files ~<CR>
nnoremap <silent><Leader>ff :Files<CR>
nnoremap <silent><Leader>f. :Files ..<CR>
nnoremap <silent><Leader>fb :Buffers<CR>
nnoremap <silent><Leader>ft :Tags<CR>
nnoremap <silent><Leader>fm :Marks<CR>
nnoremap <silent>m/      :Marks<CR>
" ↑ vim-signature のデフォルト・キーマップをこちらに再定義
nnoremap <silent><Leader>fh :HISTORY<CR>
nnoremap <silent><Leader>fg :GFiles?<CR>
nnoremap <silent><Leader>fw :Windows<CR>
nnoremap <silent><Leader>fs :BLines<CR>
nnoremap <silent><Leader>fl :BLines<CR>
nnoremap <silent><Leader>f: :History:<CR>
nnoremap <silent><Leader>f/ :History/<CR>
augroup loadFZF_Vim
	autocmd!
	autocmd CmdUndefined Files,Buffers,Tags,Marks,History,HISTORY,GFiles,Windows,Helptags,Commands,BLines
				\ call set_fzf_vim#main()
				\ | autocmd! loadFZF_Vim
augroup END

" 日本語入力に向いた設定にする (行の連結など) https://github.com/vim-jp/autofmt {{{2
augroup loadautofmt
	autocmd!
	autocmd FileType text,mail,notmuch-edit call set_autofmt#main()
				\ | autocmd! loadautofmt
				\ | delfunction set_autofmt#main
augroup END

" vim 折りたたみ fold https://github.com/thinca/vim-ft-vim_fold を組み合わせ追加のため ~/.vim/pack/my-plug/opt/vim-ft-vim_fold/ に置き換え {{{2
augroup loadvim_ft_vim_fold
	autocmd!
	autocmd FileType vim packadd vim-ft-vim_fold | autocmd! loadvim_ft_vim_fold
augroup END

" ディレクトリを再帰的に diff https://github.com/will133/vim-dirdiff {{{2
augroup loadDirDiff
	autocmd!
	autocmd CmdUndefined DirDiff packadd vim-dirdiff | autocmd! loadDirDiff
augroup END

" notmuch-python-Vim ~/.vim/pack/my-plug/opt/notmuch-py-vim/ {{{2
nnoremap <silent><Leader>m :Notmuch start<CR>
augroup loadNotmuchPy
	autocmd!
	autocmd CmdUndefined Notmuch
				\ call set_notmuchpy#main()
				\ | autocmd! loadNotmuchPy
				\ | delfunction set_notmuchpy#main
augroup END

" yank の履歴 https://github.com/justinhoward/fzf-neoyank {{{2
nnoremap <leader>fy :FZFNeoyank<CR>
nnoremap <leader>fY :FZFNeoyank " P<CR>
vnoremap <leader>fy :FZFNeoyankSelection<CR>
" nnoremap <leader>dy :FZFNeoyank<CR>
" nnoremap <leader>dY :FZFNeoyank " P<CR>
" vnoremap <leader>dy :FZFNeoyankSelection<CR>
augroup loadfzf_neoyank
	autocmd!
	autocmd CmdUndefined FZFNeoyank,FZFNeoyankSelection
				\ call set_fzf_neoyank#main()
				\ | autocmd! loadfzf_neoyank
				\ | delfunction set_fzf_neoyank#main
augroup END

" 閉じ括弧補完←遅延読み込みでも ) が二重に成らないのはこれぐらいだった https://github.com/cohama/lexima.vim {{{2
augroup loadlexima
	autocmd!
	autocmd InsertEnter *
				\ call set_lexima#main()
				\ | autocmd! loadlexima
				\ | delfunction set_lexima#main
augroup END

" 各種言語の構文チェック https://github.com/dense-analysis/ale {{{2
augroup loadALE
	autocmd!
	autocmd FileType c,cpp,ruby,yaml,markdown,html,xhtml,css,tex,sh,help,json
				\ call set_ale#main()
				\ | autocmd! loadALE
				\ | delfunction set_ale#main
augroup END

" CSS シンタックス https://github.com/hail2u/vim-css3-syntax {{{2
augroup loadSyntaxCSS
	autocmd!
	autocmd FileType css packadd vim-css3-syntax | autocmd! loadSyntaxCSS
augroup END

" conky シンタックス https://github.com/smancill/conky-syntax.vim {{{2 ←署名を見ると同じ開発元だが、標準パッケージに含まれているものだと上手く動作しない
augroup loadSyntaxConky
	autocmd!
	autocmd FileType conkyrc packadd conky-syntax.vim | autocmd! loadSyntaxConky
augroup END

" C/C++シンタックス https://github.com/vim-jp/vim-cpp {{{2
augroup loadSyntaxC
	autocmd!
	autocmd FileType c,cpp packadd vim-cpp | autocmd! loadSyntaxC
augroup END

" #ifdef 〜 #endif をテキストオプジェクト化→a#, i# https://github.com/anyakichi/vim-textobj-ifdef {{{2
" depends = ['vim-textobj-user']
augroup loadVimTextObjIfdef
	autocmd!
	autocmd FileType c,cpp packadd vim-textobj-ifdef | autocmd! loadVimTextObjIfdef
augroup END
" a#, i# に割当

" 関数をテキストオプジェクト化 https://github.com/kana/vim-textobj-function {{{2
" 判定にシンタックスを用いる https://github.com/haya14busa/vim-textobj-function-syntax {{{3 }}}
" depends = ['vim-textobj-user']
" af, if に割当
augroup loadTextObjFunc
	autocmd!
	autocmd FileType c,cpp,python,vim,ruby,yaml,markdown,html,xhtml,css,tex,sh packadd vim-textobj-function | packadd vim-textobj-function-syntax | autocmd! loadTextObjFunc
augroup END

" LaTeXをテキストオプジェクト化 https://github.com/rbonvall/vim-textobj-latex {{{2
" depends = ['vim-textobj-user']
augroup loadTextObjLaTeX
	autocmd!
	autocmd FileType tex packadd vim-textobj-latex | autocmd! loadTextObjLaTeX
augroup END
" できるのは次のテキストオプジェクト
" a\ 	i\ 	Inline math surrounded by \( and \).
" a$ 	i$ 	Inline math surrounded by dollar signs.
" aq 	iq 	Single-quoted text `like this'.
" aQ 	iQ 	Double-quoted text ``like this''.
" ae 	ie 	Environment \begin{…} to \end{…}

" CSS をテキストオプジェクト化 https://github.com/rbonvall/vim-textobj-css {{{2 ← vim-textobj-fold で代用できるしカーソルの桁位置でも変わるので、使いづらい

" 整形 https://github.com/junegunn/vim-easy-align {{{2
" 下記の例の ip はテキスト・オブジェクトの「段落」を表す
" |command|how to remember|
" |---|---|
" |vipga=|visual-select inner paragragh ga =|
" |gaip=|ga inner paragragh =|
" に対して
" ヴィジュアルモードで選択し整形.(e.g. vip<Enter> or vip<leader>ea)
" easy-align を呼んだ上で、移動したりテキストオブジェクトを指定して整形.(e.g. <leader>eaip)
" * ←範囲 (列数) 指定
" | 基準となる記号
" のタイプで↓と整形
" | command | how to remember                    |
" | ---     | ---                                |
" | vipga=  | visual-select inner paragragh ga = |
" | gaip=   | ga inner paragragh =               |
vmap <Enter>    <Cmd>call set_easy_align#main()<CR>*
vmap <leader>ea <Cmd>call set_easy_align#main()<CR>*
nmap <leader>ea <Cmd>call set_easy_align#main()<CR>
" ↑全て対象を全体 * にしたいが、nmap の <leader>eaip などテキストオブジェクトの場合の方法がわからない

" ctags や LSP を使ったlist https://github.com/liuchengxu/vista.vim {{{2
augroup loadVista
	autocmd!
	autocmd CmdUndefined Vista
				\ call set_vista#main()
				\ | autocmd! loadVista
				\ | delfunction set_vista#main
augroup END
" 次の Voom に未対応は Vista を使う様に分岐関数とキーマップ
nnoremap <silent><leader>o :call switch_voom_vista#main()<CR>

" アウトライン https://github.com/vim-voom/VOoM {{{2
augroup loadVOoM
	autocmd!
	autocmd CmdUndefined Voom
				\ call set_voom#main()
				\ | autocmd! loadVOoM
				\ | delfunction set_voom#main
augroup END

" LaTeX fold 折りたたみ https://github.com/matze/vim-tex-fold {{{2
augroup loadvimTeXfold
	autocmd!
	autocmd FileType tex
				\ call set_vim_tex_fold#main()
				\ | autocmd! loadvimTeXfold
				\ | delfunction set_vim_tex_fold#main
augroup END

" ソースの実行結果を別バッファに表示 https://github.com/thinca/vim-quickrun {{{2
nnoremap <silent><Leader>qr       :QuickRun<CR>
vnoremap <silent><Leader>qr       :QuickRun<CR>
inoremap <silent><C-\>qr     <ESC>:QuickRun<CR>a
augroup QuickRnnKeymap
	autocmd!
	autocmd FileType quickrun nnoremap <buffer><silent>q :bwipeout!<CR>
	autocmd FileType quickrun setlocal signcolumn=auto foldcolumn=0
	" autocmd FileType tex nnoremap <silent><buffer><Leader>qr       :cclose \| QuickRun<CR>
augroup END
augroup loadQuickRun
	autocmd!
	autocmd CmdUndefined QuickRun
				\ call set_quickrun#main()
				\ | autocmd! loadQuickRun
				\ | delfunction set_quickrun#main
augroup END

" " goobook (Google Contacts) を使ったメールアドレス補完 https://github.com/afwlehmann/vim-goobook {{{2
" → ~/.vim/pack/my-plug/opt/asyncomplete-mail/ に置き換え
" augroup loadGoobook
" 	autocmd!
" 	autocmd FileType mail,notmuch-draft packadd vim-goobook | autocmd! loadGoobook
" augroup END

" Git 連携 https://github.com/tpope/vim-fugitive {{{2
augroup loadFugitive
	autocmd!
	autocmd CmdUndefined Git,Ggrep,Glgrep,Gclog,Gllog,Gedit,Gread,Gwrite,Gdiffsplit,GRename,GBrowser
				\ call set_fugitve#main()
				\ | autocmd! loadFugitive
				\ | delfunction set_fugitve#main
augroup END

" カーソル位置の Syntax の情報を表示する ~/.vim/pack/my-plug/opt/syntax_info/ http://cohama.hateblo.jp/entry/2013/08/11/020849 から {{{2
augroup loadSyntaxInfo
	autocmd!
	autocmd CmdUndefined SyntaxInfo packadd syntax_info | autocmd! loadSyntaxInfo
augroup END

" Linux では wmctrl を使ってフル・スクリーンをトグル ~/.vim/pack/my-plug/opt/full-screen {{{2
noremap <silent><F11> :Fullscreen<CR>
augroup loadFullScreen
	autocmd!
	autocmd CmdUndefined Fullscreen packadd full-screen | autocmd! loadFullScreen
augroup END

" Man コマンドを使用可能にする ~/.vim/pack/my-plug/opt/man {{{2
augroup ManCommand
	autocmd!
	autocmd CmdUndefined Man packadd man | autocmd! ManCommand
augroup END

" カレント・タブ・ページ内では同じターミナルを閉じる ~/.vim/pack/my-plug/opt/kill-terminal {{{2
augroup KillTerminal
	autocmd!
	autocmd TerminalOpen * call kill_terminal#main()
augroup END
augroup loadKillTerminal
	autocmd!
	autocmd FuncUndefined kill_terminal#main packadd kill-terminal | autocmd! loadKillTerminal
augroup END

" ページ送りに ~/.vim/pack/my-plug/opt/page-down {{{2
nnoremap <silent><space> :call page_down#main()<CR>
augroup loadPageDown
	autocmd!
	autocmd FuncUndefined page_down#main packadd page-down | autocmd! loadPageDown
augroup END

" カーソル位置の単語を Google で検索 ~/.vim/pack/my-plug/opt/google-search/ https://www.rasukarusan.com/entry/2019/03/09/011630 を参考にした {{{2
nnoremap <silent><leader>g :SearchByGoogle<CR>
vnoremap <silent><leader>g :SearchByGoogle<CR>
augroup loadSearchByGoogle
	autocmd!
	autocmd CmdUndefined SearchByGoogle packadd google-search | autocmd! loadSearchByGoogle
augroup END

" vim のヘルプ・ファイルから Readme.md を作成する https://github.com/LeafCage/vimhelpgenerator {{{2
augroup loadVimHelpGenerator
	autocmd!
	autocmd CmdUndefined VimHelpGenerator packadd vimhelpgenerator| set filetype=help | autocmd! loadVimHelpGenerator
	autocmd BufWinEnter *.jax packadd vimhelpgenerator | set filetype=help | autocmd! loadVimHelpGenerator
augroup END

" 編集中の Markdown などをブラウザでプレビュー https://github.com/previm/previm {{{2
augroup MyMarkdown
	autocmd!
	autocmd FileType markdown nnoremap <silent><buffer><Leader>v :PrevimOpen<CR>
augroup END
augroup loadPreview
	autocmd!
	autocmd CmdUndefined PrevimOpen
				\ call set_previm#main()
				\ | autocmd! loadPreview
				\ | delfunction set_previm#main
augroup END

" EPWING の辞書を呼び出す https://github.com/deton/eblook.vim {{{2
nmap <silent><Leader>eb <Cmd>call set_eblook#main() <bar> delfunction set_eblook#main<CR>
vmap <silent><Leader>eb <Cmd>call set_eblook#main() <bar> delfunction set_eblook#main<CR>

" Undo をツリー表示で行き来する https://github.com/mbbill/undotree {{{2
nnoremap <silent><Leader>u <Cmd>UndotreeToggle<CR>
augroup loadUndotree
	autocmd!
	autocmd CmdUndefined UndotreeToggle packadd undotree | autocmd! loadUndotree
augroup END

" https://github.com/prabirshrestha/vim-lsp {{{2
augroup loadvimlsp
	autocmd!
	autocmd FileType c,cpp,python,vim,ruby,yaml,markdown,html,xhtml,tex,css,sh,go,conf
				\ call set_vimlsp#main()
				\ | autocmd! loadvimlsp
				\ | autocmd! loadasyncomplete
				" \ | delfunction set_vimlsp#main
augroup END

" https://github.com/puremourning/vimspector {{{2
augroup loadVimspector
	autocmd!
	autocmd FuncUndefined vimspector#*
				\ call set_vimspector#main()
				\ | autocmd! loadVimspector
				\ | delfunction set_vimspector#main
augroup END
nnoremap <leader>df       <Cmd>call vimspector#AddFunctionBreakpoint('<cexpr>')<CR>
nnoremap <leader>dc       <Cmd>call vimspector#Continue()<CR>
nnoremap <leader>dd       <Cmd>call vimspector#DownFrame()<CR>
nnoremap <leader>dp       <Cmd>call vimspector#Pause()<CR>
nnoremap <leader>dR       <Cmd>call vimspector#Restart()<CR>
nnoremap <leader>dr       <Cmd>call vimspector#RunToCursor()<CR>
nnoremap <leader>ds       <Cmd>call vimspector#StepInto()<CR>
nnoremap <leader>dS       <Cmd>call vimspector#StepOut()<CR>
nnoremap <leader>dn       <Cmd>call vimspector#StepOver()<CR>
nnoremap <leader>d<space> <Cmd>call vimspector#Stop()<CR>
nnoremap <leader>db       <Cmd>call vimspector#ToggleBreakpoint()<CR>
nnoremap <leader>dx       <Cmd>call vimspector#Reset( { 'interactive': v:false } )<CR>
nmap     <Leader>di       <Plug>VimspectorBalloonEval
xmap     <Leader>di       <Plug>VimspectorBalloonEval

" カーソル位置のコンテキストに合わせて filetype を切り替える https://github.com/osyo-manga/vim-precious {{{2
" 上の context_filetype.vim はあくまで判定
augroup loadprecious
	autocmd!
	autocmd FileType sh,html,markdown,lua call set_precious#main()
				\ | autocmd! loadprecious
				\ | delfunction set_precious#main
augroup END

" ファイル・マネージャー https://github.com/lambdalisue/fern.vim {{{2
nnoremap <leader>e <Cmd>Fern $HOME -drawer -reveal=%:p -toggle<CR>
" nnoremap <leader>e <Cmd>Fern %:p:h -drawer -reveal=%:p -toggle<CR>
augroup loadFern
	autocmd!
	autocmd CmdUndefined Fern call set_fern#main()
				\ | autocmd! loadFern
				\ | delfunction set_fern#main
augroup END

" カーソル位置に合わせて filetype を判定←各種プラグインが依存 https://github.com/Shougo/context_filetype.vim {{{2
augroup loadcontext_filetype
	autocmd!
	autocmd CursorMoved * call set_context_filetype#main()
				\ | autocmd! loadcontext_filetype
				\ | delfunction set_context_filetype#main
augroup END

" 素早く移動する https://github.com/easymotion/vim-easymotion {{{2
for key in ['f', 'F', 't', 'T', 'w', 'W', 'b', 'B', 'e', 'E', 'ge', 'gE', 'j', 'k', 'n', 'N']
	execute 'nmap <leader><leader>' .. key .. '  <Cmd>call set_easymotion#main(''(easymotion-' .. key .. ')'') <bar> delfunction set_easymotion#main<CR>'
	execute 'vmap <leader><leader>' .. key .. '  <Cmd>call set_easymotion#main(''(easymotion-' .. key .. ')'') <bar> delfunction set_easymotion#main<CR>'
endfor

" 各種言語のコメントの追加/削除 gc{motion} https://github.com/tpope/vim-commentary {{{2
" マッピングは gc{motion}
nmap gcu <Cmd>call set_commentary#main('Commentary Commentary') <bar> delfunction set_commentary#main<CR>
nmap gcc <Cmd>call set_commentary#main('CommentaryLine') <bar> delfunction set_commentary#main<CR>
omap gc  <Cmd>call set_commentary#main('Commentary') <bar> delfunction set_commentary#main<CR>
nmap gc  <Cmd>call set_commentary#main('Commentary') <bar> delfunction set_commentary#main<CR>
xmap gc  <Cmd>call set_commentary#main('Commentary') <bar> delfunction set_commentary#main<CR>

" カッコだけでなくタグでも括る https://github.com/tpope/vim-surround {{{2
xmap s   <Cmd>call set_surround#main('VSurround') <bar> delfunction set_surround#main<CR>
xmap gS  <Cmd>call set_surround#main('VgSurround') <bar> delfunction set_surround#main<CR>
" ↑s と似ているが前後で改行 v_s は v_c と同じなのでキーマップを潰しても良いが、v_S は同じ意味のキーマップが無いので、gS に割り当てている
nmap ysS <Cmd>call set_surround#main('YSsurround') <bar> delfunction set_surround#main<CR>
" ↑行全体を挟む (前後に改行)
nmap yss <Cmd>call set_surround#main('Yssurround') <bar> delfunction set_surround#main<CR>
" ↑行全体を挟む
nmap yS  <Cmd>call set_surround#main('YSurround') <bar> delfunction set_surround#main<CR>
"↑↓に対して前後に改行
nmap ys  <Cmd>call set_surround#main('Ysurround') <bar> delfunction set_surround#main<CR>
nmap cS  <Cmd>call set_surround#main('CSurround') <bar> delfunction set_surround#main<CR>
nmap cs  <Cmd>call set_surround#main('Csurround') <bar> delfunction set_surround#main<CR>
nmap ds  <Cmd>call set_surround#main('Dsurround') <bar> delfunction set_surround#main<CR>

" 選択範囲をテキストオブジェクトで広げたり、狭めたり https://github.com/terryma/vim-expand-region {{{2
vmap v <Cmd>call set_expand_region#main('(expand_region_expand)') <bar> delfunction set_expand_region#main<CR>
vmap V <Cmd>call set_expand_region#main('(expand_region_shrink)') <bar> delfunction set_expand_region#main<CR>

" Markdown のシンタックス https://github.com/preservim/vim-markdown {{{2
" vim-precious と相性が悪く、一度コード例内にカーソル移動すると、コード内シンタックスが働かなくなる

" getmail syntax https://github.com/vim-scripts/getmail.vim {{{2
augroup Gatmail
	autocmd!
	autocmd BufRead ~/.getmail/*,~/.config/getmail/* call set_getmail_vim#main()
augroup END

" ~/.vim/pack/*/{stat,opt}/*/doc に有る tags{,-??} が古ければ再作成 ~/.vim/pack/my-plug/opt/pack-helptags {{{2
augroup loadPackHelpTags
	autocmd!
	autocmd CmdUndefined PackHelpTags packadd pack-helptags | autocmd! loadPackHelpTags
augroup END

