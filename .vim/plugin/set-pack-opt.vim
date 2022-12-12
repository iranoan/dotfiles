vim9script
scriptencoding utf-8

# 小文字で始まるコマンドを定義可能に https://github.com/kana/vim-altercmd {{{1
# ↓実質 /start/と同じになるが、単純に /start/ に置くと、このスクリプト読み込み時点では AlterCommand が使えず、エラーになるので読み込み明示形式にする
packadd vim-altercmd
AlterCommand e[dit]     TabEdit
AlterCommand u[tf8]     edit\ ++enc=utf8
AlterCommand sj[is]     edit\ ++enc=cp932
AlterCommand cp[932]    edit\ ++enc=cp932
AlterCommand eu[c]      edit\ ++enc=eucjp-ms
AlterCommand ji[s]      edit\ ++enc=iso-2022-jp-3
AlterCommand gr[ep]     silent\ grep
AlterCommand lgr[ep]    silent\ lgrep
AlterCommand mak[e]     silent\ make
AlterCommand lmak[e]    silent\ lmake
AlterCommand tabd[o]    silent\ tabdo
AlterCommand windo      silent\ windo
AlterCommand argdo      silent\ argdo
AlterCommand cdo        silent\ cdo
AlterCommand cfdo       silent\ cfdo
AlterCommand ld[o]      silent\ ldo
AlterCommand lfdo       silent\ lfdo
AlterCommand ter[minal] topleft\ terminal
AlterCommand man        Man
AlterCommand p[rint]    call\ print#main()
# ↑:print は使わないので、印刷関数 (~/.vim/autoload/print.vim) に置き換え
AlterCommand helpt[ags] call\ manage_pack#Helptags()
AlterCommand bc         .!bc\ -l\ -q\ ~/.bc\ <Bar>\ sed\ -E\ -e\ 's/^\\\./0./g'\ -e\ 's/(\\\.[0-9]*[1-9])0+/\\\1/g'\ -e\ 's/\\\.$//g'
AlterCommand bi[nary]   if\ !&binary\ <Bar>\ execute('setlocal\ binary\ <Bar>\ %!xxd')\ <Bar>\ endif
AlterCommand nob[inary] if\ &binary\ <Bar>\ execute('setlocal\ nobinary\ <Bar>\ %!xxd\ -r')\ <Bar>\ endif
if glob('~/.vim/pack/*/*/vim-fugitive/plugin/fugitive.vim') !=# ''
	AlterCommand git      Git
	AlterCommand gl[og]   Gllog
	AlterCommand gd[iff]  Gdiffsplit
endif

# 2019-03-31 14:51 などの日付や時刻もうまい具合に Ctrl-a/x で加算減算する https://github.com/tpope/vim-speeddating {{{1
# 遅延読み込みにしているので最初の {count}<C-X>/<C-A> の {count} が無視される
nmap d<C-X> <Cmd>call set_speeddating#main('SpeedDatingNowLocal') <bar> delfunction set_speeddating#main<CR>
nmap d<C-A> <Cmd>call set_speeddating#main('SpeedDatingNowUTC') <bar> delfunction set_speeddating#main<CR>
xmap <C-X>  <Cmd>call set_speeddating#main('SpeedDatingDown') <bar> delfunction set_speeddating#main<CR>
xmap <C-A>  <Cmd>call set_speeddating#main('SpeedDatingUp') <bar> delfunction set_speeddating#main<CR>
nmap <C-X>  <Cmd>call set_speeddating#main('SpeedDatingDown') <bar> delfunction set_speeddating#main<CR>
nmap <C-A>  <Cmd>call set_speeddating#main('SpeedDatingUp') <bar> delfunction set_speeddating#main<CR>

# https://github.com/junegunn/fzf.vim {{{1
nnoremap <silent><Leader>fr :Files ~<CR>
nnoremap <silent><Leader>ff :Files<CR>
nnoremap <silent><Leader>f. :Files ..<CR>
nnoremap <silent><Leader>fv :Files ~/.vim<CR>
nnoremap <silent><Leader>fs :Files ~/src<CR>
nnoremap <silent><Leader>fx :Files ~/bin<CR>
nnoremap <silent><Leader>fe :Files ~/book/epub<CR>
nnoremap <silent><Leader>fp :Files ~/public_html/iranoan<CR>
nnoremap <silent><Leader>ft :Files ~/Information/slide<CR>
nnoremap <silent><Leader>fb :Buffers<CR>
nnoremap <silent><Leader>fc :Commands<CR>
nnoremap <silent><Leader>fg :GFiles?<CR>
nnoremap <silent><Leader>fh :HISTORY<CR>
nnoremap <silent><Leader>fl :BLines<CR>
nnoremap <silent><Leader>fm :Marks<CR>
nnoremap <silent>m/         :Marks<CR>
# ↑ vim-signature のデフォルト・キーマップをこちらに再定義
# nnoremap <silent><Leader>ft :Tags<CR>
nnoremap <silent><Leader>fw :Windows<CR>
nnoremap <silent><Leader>f: :History:<CR>
nnoremap <silent><Leader>f/ :History/<CR>
augroup loadFZF_Vim
	autocmd!
	autocmd CmdUndefined Files,Buffers,Tags,Marks,History,HISTORY,GFiles,Windows,Helptags,Commands,BLines
				\ set_fzf_vim#main()
				| autocmd! loadFZF_Vim
				| augroup! loadFZF_Vim
				| delfunction set_fzf_vim#main
augroup END

# 日本語入力に向いた設定にする (行の連結など) https://github.com/vim-jp/autofmt {{{1
augroup loadautofmt
	autocmd!
	autocmd FileType text,mail,notmuch-edit set_autofmt#main()
				| autocmd! loadautofmt
				| augroup! loadautofmt
				| delfunction set_autofmt#main
augroup END

# vim 折りたたみ fold https://github.com/thinca/vim-ft-vim_fold を組み合わせ追加のため ~/.vim/pack/my-plug/opt/vim-ft-vim_fold/ に置き換え {{{1
augroup loadvim_ft_vim_fold
	autocmd!
	autocmd FileType vim packadd vim-ft-vim_fold
	| autocmd! loadvim_ft_vim_fold
	| augroup! loadvim_ft_vim_fold
augroup END

# ディレクトリを再帰的に diff https://github.com/will133/vim-dirdiff {{{1
augroup loadDirDiff
	autocmd!
	autocmd CmdUndefined DirDiff packadd vim-dirdiff
	| autocmd! loadDirDiff
	| augroup! loadDirDiff
augroup END

# notmuch-python-Vim ~/.vim/pack/my-plug/opt/notmuch-py-vim/ {{{1
nnoremap <silent><Leader>m :Notmuch start<CR>
augroup loadNotmuchPy
	autocmd!
	autocmd CmdUndefined Notmuch
				\ set_notmuchpy#main()
				| autocmd! loadNotmuchPy
				| augroup! loadNotmuchPy
				| delfunction set_notmuchpy#main
augroup END

# yank の履歴 https://github.com/justinhoward/fzf-neoyank {{{1
nnoremap <Leader>fy :FZFNeoyank<CR>
nnoremap <Leader>fY :FZFNeoyank # P<CR>
xnoremap <Leader>fy :FZFNeoyankSelection<CR>
# nnoremap <Leader>dy :FZFNeoyank<CR>
# nnoremap <Leader>dY :FZFNeoyank " P<CR>
# vnoremap <Leader>dy :FZFNeoyankSelection<CR>
augroup loadfzf_neoyank
	autocmd!
	autocmd CmdUndefined FZFNeoyank,FZFNeoyankSelection
				\ set_fzf_neoyank#main()
				| autocmd! loadfzf_neoyank
				| augroup! loadfzf_neoyank
				| delfunction set_fzf_neoyank#main
augroup END

# 各種言語の構文チェック https://github.com/dense-analysis/ale {{{1
augroup loadALE
	autocmd!
	autocmd FileType c,cpp,python,ruby,yaml,markdown,html,xhtml,css,tex,help,json
				\ set_ale#main()
				| autocmd! loadALE
				| augroup! loadALE
				| delfunction set_ale#main
augroup END

# CSS シンタックス https://github.com/hail2u/vim-css3-syntax {{{1
augroup loadSyntaxCSS
	autocmd!
	autocmd FileType css packadd vim-css3-syntax
	| autocmd! loadSyntaxCSS
	| augroup! loadSyntaxCSS
augroup END

# conky シンタックス https://github.com/smancill/conky-syntax.vim {{{1 ←署名を見ると同じ開発元だが、標準パッケージに含まれているものだと上手く動作しない
augroup loadSyntaxConky
	autocmd!
	autocmd FileType conkyrc packadd conky-syntax.vim
	| autocmd! loadSyntaxConky
	| augroup! loadSyntaxConky
augroup END

# C/C++シンタックス https://github.com/vim-jp/vim-cpp {{{1
augroup loadSyntaxC
	autocmd!
	autocmd FileType c,cpp packadd vim-cpp
	| autocmd! loadSyntaxC
	| augroup! loadSyntaxC
augroup END

# #ifdef 〜 #endif をテキストオプジェクト化→a#, i# https://github.com/anyakichi/vim-textobj-ifdef {{{1
# depends = ['vim-textobj-user']
augroup loadVimTextObjIfdef
	autocmd!
	autocmd FileType c,cpp packadd vim-textobj-ifdef
	| autocmd! loadVimTextObjIfdef
	| augroup! loadVimTextObjIfdef
augroup END
# a#, i# に割当

# 関数をテキストオプジェクト化 https://github.com/kana/vim-textobj-function {{{1
# 判定にシンタックスを用いる https://github.com/haya14busa/vim-textobj-function-syntax {{{2 }}}
# depends = ['vim-textobj-user']
# af, if に割当
augroup loadTextObjFunc
	autocmd!
	autocmd FileType c,cpp,python,vim,ruby,yaml,markdown,html,xhtml,css,tex,sh,bash packadd vim-textobj-function
	| packadd vim-textobj-function-syntax
	| autocmd! loadTextObjFunc
	| augroup! loadTextObjFunc
augroup END

# LaTeXをテキストオプジェクト化 https://github.com/rbonvall/vim-textobj-latex {{{1
# depends = ['vim-textobj-user']
augroup loadTextObjLaTeX
	autocmd!
	autocmd FileType tex packadd vim-textobj-latex
	| autocmd! loadTextObjLaTeX
	| augroup! loadTextObjLaTeX
augroup END
# できるのは次のテキストオプジェクト
# a\ 	i\ 	Inline math surrounded by \( and \).
# a$ 	i$ 	Inline math surrounded by dollar signs.
# aq 	iq 	Single-quoted text `like this'.
# aQ 	iQ 	Double-quoted text ``like this''.
# ae 	ie 	Environment \begin{…} to \end{…}

# CSS をテキストオプジェクト化 https://github.com/rbonvall/vim-textobj-css {{{1 ← vim-textobj-fold で代用できるしカーソルの桁位置でも変わるので、使いづらい

# 整形 https://github.com/junegunn/vim-easy-align {{{1
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
xmap <Enter>    <Cmd>call set_easy_align#main()<CR>
xmap <Leader>ea <Cmd>call set_easy_align#main()<CR>
nmap <Leader>ea <Cmd>call set_easy_align#main()<CR>
# ↑全て対象を全体 * にしたいが、nmap の <Leader>eaip などテキストオブジェクトの場合の方法がわからない

# ctags や LSP を使ったlist https://github.com/liuchengxu/vista.vim {{{1
augroup loadVista
	autocmd!
	autocmd CmdUndefined Vista
				\ set_vista#main()
				| autocmd! loadVista
				| augroup! loadVista
				| delfunction set_vista#main
augroup END
# 次の Voom に未対応は Vista を使う様に分岐関数とキーマップ
nnoremap <silent><Leader>o :call switch_voom_vista#main()<CR>

# アウトライン https://github.com/vim-voom/VOoM {{{1
augroup loadVOoM
	autocmd!
	autocmd CmdUndefined Voom
				\ set_voom#main()
				| autocmd! loadVOoM
				| augroup! loadVOoM
				| delfunction set_voom#main
augroup END

# LaTeX fold 折りたたみ https://github.com/matze/vim-tex-fold {{{1
augroup loadvimTeXfold
	autocmd!
	autocmd FileType tex
				\ set_vim_tex_fold#main()
				| autocmd! loadvimTeXfold
				| augroup! loadvimTeXfold
				| delfunction set_vim_tex_fold#main
augroup END

# ソースの実行結果を別バッファに表示 https://github.com/thinca/vim-quickrun {{{1
nnoremap <silent><Leader>qr       :QuickRun<CR>
xnoremap <silent><Leader>qr       :QuickRun<CR>
inoremap <silent><C-\>qr     <ESC>:QuickRun<CR>a
augroup QuickRnnKeymap
	autocmd!
	autocmd FileType quickrun nnoremap <buffer><nowait><silent>q :bwipeout!<CR>
	autocmd FileType quickrun setlocal signcolumn=auto foldcolumn=0
	# autocmd FileType tex nnoremap <silent><buffer><Leader>qr       :cclose \| QuickRun<CR>
augroup END
augroup loadQuickRun
	autocmd!
	autocmd CmdUndefined QuickRun
				\ set_quickrun#main()
				| autocmd! loadQuickRun
				| augroup! loadQuickRun
				| delfunction set_quickrun#main
augroup END

# Git 連携 https://github.com/tpope/vim-fugitive {{{1
augroup loadFugitive
	autocmd!
	autocmd CmdUndefined Git,Ggrep,Glgrep,Gclog,Gllog,Gedit,Gread,Gwrite,Gdiffsplit,GRename,GBrowser
				\ set_fugitve#main()
				| autocmd! loadFugitive
				| augroup! loadFugitive
				| delfunction set_fugitve#main
augroup END

# カーソル位置の Syntax の情報を表示する ~/.vim/pack/my-plug/opt/syntax_info/ http://cohama.hateblo.jp/entry/2013/08/11/020849 から {{{1
augroup loadSyntaxInfo
	autocmd!
	autocmd CmdUndefined SyntaxInfo packadd syntax_info
	| autocmd! loadSyntaxInfo
	| augroup! loadSyntaxInfo
augroup END

# Linux では wmctrl を使ってフル・スクリーンをトグル ~/.vim/pack/my-plug/opt/full-screen {{{1
noremap <silent><F11> :Fullscreen<CR>
augroup loadFullScreen
	autocmd!
	autocmd CmdUndefined Fullscreen packadd full-screen
	| autocmd! loadFullScreen
	| augroup! loadFullScreen
augroup END

# Man コマンドを使用可能にする ~/.vim/pack/my-plug/opt/man {{{1
augroup ManCommand
	autocmd!
	autocmd CmdUndefined Man packadd man
	| autocmd! ManCommand
	| augroup! ManCommand
augroup END

# カレント・タブ・ページ内では同じターミナルを閉じる ~/.vim/pack/my-plug/opt/kill-terminal {{{1
augroup KillTerminal
	autocmd!
	autocmd TerminalOpen * kill_terminal#main()
augroup END
augroup loadKillTerminal
	autocmd!
	autocmd FuncUndefined kill_terminal#main packadd kill-terminal
	| autocmd! loadKillTerminal
	| augroup! loadKillTerminal
augroup END

# ページ送りに ~/.vim/pack/my-plug/opt/page-down {{{1
nnoremap <silent><space> :call page_down#Main()<CR>
augroup loadPageDown
	autocmd!
	autocmd FuncUndefined page_down#Main packadd page-down
	| autocmd! loadPageDown
	| augroup! loadPageDown
augroup END

# カーソル位置の単語を Google で検索 ~/.vim/pack/my-plug/opt/google-search/ https://www.rasukarusan.com/entry/2019/03/09/011630 を参考にした {{{1
nnoremap <silent><Leader>g :SearchByGoogle<CR>
xnoremap <silent><Leader>g :SearchByGoogle<CR>
augroup loadSearchByGoogle
	autocmd!
	autocmd CmdUndefined SearchByGoogle packadd google-search
	| autocmd! loadSearchByGoogle
	| augroup! loadSearchByGoogle
augroup END

# vim のヘルプ・ファイルから Readme.md を作成する https://github.com/LeafCage/vimhelpgenerator {{{1
augroup loadVimHelpGenerator
	autocmd!
	autocmd CmdUndefined VimHelpGenerator packadd vimhelpgenerator
	| set filetype=help
	| autocmd! loadVimHelpGenerator
	| augroup! loadVimHelpGenerator
	autocmd BufWinEnter *.jax packadd vimhelpgenerator
	| set filetype=help |
	| autocmd! loadVimHelpGenerator
	| augroup! loadVimHelpGenerator
augroup END

# 編集中の Markdown などをブラウザでプレビュー https://github.com/previm/previm {{{1
augroup MyMarkdown
	autocmd!
	autocmd FileType markdown nnoremap <silent><buffer><Leader>v :PrevimOpen<CR>
augroup END
augroup loadPreview
	autocmd!
	autocmd CmdUndefined PrevimOpen
				\ set_previm#main()
				| autocmd! loadPreview
				| augroup! loadPreview
				| delfunction set_previm#main
augroup END

# EPWING の辞書を呼び出す https://github.com/deton/eblook.vim {{{1
nmap <silent><Leader>eb <Cmd>call set_eblook#main() <bar> delfunction set_eblook#main<CR>
xmap <silent><Leader>eb <Cmd>call set_eblook#main() <bar> delfunction set_eblook#main<CR>

# Undo をツリー表示で行き来する https://github.com/mbbill/undotree {{{1
nnoremap <silent><Leader>u <Cmd>UndotreeToggle<CR>
augroup loadUndotree
	autocmd!
	autocmd CmdUndefined UndotreeToggle packadd undotree
	| autocmd! loadUndotree
	| augroup! loadUndotree
augroup END

# https://github.com/prabirshrestha/vim-lsp {{{1
augroup loadvimlsp
	autocmd!
	autocmd FileType c,cpp,python,vim,ruby,yaml,markdown,html,xhtml,tex,css,sh,bash,go,conf
				\ set_vimlsp#main()
				| autocmd! loadvimlsp
				| augroup! loadvimlsp
				| delfunction set_vimlsp#main
augroup END

# https://github.com/puremourning/vimspector {{{1
augroup loadVimspector
	autocmd!
	autocmd FuncUndefined vimspector#*
				\ set_vimspector#main()
				| autocmd! loadVimspector
				| augroup! loadVimspector
				| delfunction set_vimspector#main
augroup END
nnoremap <Leader>df       <Cmd>call vimspector#AddFunctionBreakpoint('<cexpr>')<CR>
nnoremap <Leader>dc       <Cmd>call vimspector#Continue()<CR>
nnoremap <Leader>dd       <Cmd>call vimspector#DownFrame()<CR>
nnoremap <Leader>dp       <Cmd>call vimspector#Pause()<CR>
nnoremap <Leader>dR       <Cmd>call vimspector#Restart()<CR>
nnoremap <Leader>dr       <Cmd>call vimspector#RunToCursor()<CR>
nnoremap <Leader>ds       <Cmd>call vimspector#StepInto()<CR>
nnoremap <Leader>dS       <Cmd>call vimspector#StepOut()<CR>
nnoremap <Leader>dn       <Cmd>call vimspector#StepOver()<CR>
nnoremap <Leader>d<space> <Cmd>call vimspector#Stop()<CR>
nnoremap <Leader>db       <Cmd>call vimspector#ToggleBreakpoint()<CR>
nnoremap <Leader>dx       <Cmd>call vimspector#Reset( { 'interactive': v:false } )<CR>
nmap     <Leader>di       <Plug>VimspectorBalloonEval
xmap     <Leader>di       <Plug>VimspectorBalloonEval

# ファイル・マネージャー https://github.com/lambdalisue/fern.vim {{{1
nnoremap <Leader>e <Cmd>Fern $HOME -drawer -reveal=%:p -toggle<CR>
# nnoremap <Leader>e <Cmd>Fern %:p:h -drawer -reveal=%:p -toggle<CR>
augroup loadFern
	autocmd!
	autocmd CmdUndefined Fern set_fern#main()
				| autocmd! loadFern
				| augroup! loadFern
				| delfunction set_fern#main
augroup END

# カーソル位置に合わせて filetype を判定←各種プラグインが依存 https://github.com/Shougo/context_filetype.vim {{{1
augroup loadcontext_filetype
	autocmd!
	autocmd FileType sh,bash,vim,html,markdown,lua set_context_filetype#main()
				| autocmd! loadcontext_filetype
				| augroup! loadcontext_filetype
				| delfunction set_context_filetype#main
augroup END

# 素早く移動する https://github.com/easymotion/vim-easymotion {{{1
for key in ['f', 'F', 't', 'T', 'w', 'W', 'b', 'B', 'e', 'E', 'ge', 'gE', 'j', 'k', 'n', 'N']
	execute 'nmap <Leader><Leader>' .. key .. '  <Cmd>call set_easymotion#main(''(easymotion-' .. key .. ')'') <bar> delfunction set_easymotion#main<CR>'
	execute 'vmap <Leader><Leader>' .. key .. '  <Cmd>call set_easymotion#main(''(easymotion-' .. key .. ')'') <bar> delfunction set_easymotion#main<CR>'
endfor

# 各種言語のコメントの追加/削除 gc{motion} https://github.com/tpope/vim-commentary {{{1
# マッピングは gc{motion}
nmap gcu <Cmd>call set_commentary#main('Commentary Commentary') <bar> delfunction set_commentary#main<CR>
nmap gcc <Cmd>call set_commentary#main('CommentaryLine') <bar> delfunction set_commentary#main<CR>
omap gc  <Cmd>call set_commentary#main('Commentary') <bar> delfunction set_commentary#main<CR>
nmap gc  <Cmd>call set_commentary#main('Commentary') <bar> delfunction set_commentary#main<CR>
xmap gc  <Cmd>call set_commentary#main('Commentary') <bar> delfunction set_commentary#main<CR>

# カッコだけでなくタグでも括る https://github.com/tpope/vim-surround {{{1
xmap s   <Cmd>call set_surround#main('VSurround') <bar> delfunction set_surround#main<CR>
xmap gS  <Cmd>call set_surround#main('VgSurround') <bar> delfunction set_surround#main<CR>
# ↑s と似ているが前後で改行 v_s は v_c と同じなのでキーマップを潰しても良いが、v_S は同じ意味のキーマップが無いので、gS に割り当てている
nmap ysS <Cmd>call set_surround#main('YSsurround') <bar> delfunction set_surround#main<CR>
# ↑行全体を挟む (前後に改行)
nmap yss <Cmd>call set_surround#main('Yssurround') <bar> delfunction set_surround#main<CR>
# ↑行全体を挟む
nmap yS  <Cmd>call set_surround#main('YSurround') <bar> delfunction set_surround#main<CR>
#↑↓に対して前後に改行
nmap ys  <Cmd>call set_surround#main('Ysurround') <bar> delfunction set_surround#main<CR>
nmap cS  <Cmd>call set_surround#main('CSurround') <bar> delfunction set_surround#main<CR>
nmap cs  <Cmd>call set_surround#main('Csurround') <bar> delfunction set_surround#main<CR>
nmap ds  <Cmd>call set_surround#main('Dsurround') <bar> delfunction set_surround#main<CR>
# <Shift> を押すのが面倒
nmap ys4 ys$
nmap ds, ds<
nmap ds. ds>
nmap ds2 ds"
nmap ds7 ds'
nmap ds8 ds(
nmap ds9 ds)
nmap ds@ ds`
nmap cs, cs<
nmap cs. cs>
nmap cs2 cs"
nmap cs7 cs'
nmap cs8 cs(
nmap cs9 cs)
nmap cs@ cs`

# 選択範囲をテキストオブジェクトで広げたり、狭めたり https://github.com/terryma/vim-expand-region {{{1
xmap v <Cmd>call set_expand_region#main('(expand_region_expand)') <bar> delfunction set_expand_region#main<CR>
xmap V <Cmd>call set_expand_region#main('(expand_region_shrink)') <bar> delfunction set_expand_region#main<CR>

# getmail syntax https://github.com/vim-scripts/getmail.vim {{{1
augroup Gatmail
	autocmd!
	autocmd BufRead ~/.getmail/*,~/.config/getmail/* set_getmail_vim#main()
augroup END

# ~/.vim/pack/*/{stat,opt}/*/doc に有る tags{,-??} が古ければ再作成 ~/.vim/pack/my-plug/opt/pack-helptags {{{1
augroup loadManagePack
	autocmd!
	autocmd FuncUndefined manage_pack#* packadd manage-pack
	| autocmd! loadManagePack
	| augroup! loadManagePack
augroup END

# dog と cat の入れ替えなどサイクリックに置換する関数などの定義 ~/.vim/pack/my-plug/opt/replace-cyclic {{{1
augroup loadReplaceCyclic
	autocmd!
	autocmd FuncUndefined replace#* packadd replace-cyclic
	| autocmd! loadReplaceCyclic
	| augroup! loadReplaceCyclic
augroup END

# *.docx をまとめて epub 用のファイルに変換 ~/.vim/pack/my-plug/opt/docx2xhtml {{{1
# カレント・ディレクトリに有る Google Document を使って OCR したファイルを前提とし、自作シェル・スクリプトや LibreOffice も呼び出しているごく個人的なスクリプト
augroup loadDocx2xhtml
	autocmd!
	autocmd FuncUndefined docx2xhtml#main packadd docx2xhtml
	| autocmd! loadDocx2xhtml
	| augroup! loadDocx2xhtml
augroup END

# 文字の変換 ~/.vim/pack/my-plug/opt/transform/ {{{1
augroup loadtransform
	autocmd!
	autocmd FuncUndefined transform#* packadd transform
	| autocmd! loadtransform
	| augroup! loadtransform
	autocmd CmdUndefined Zen2han packadd transform
	| autocmd! loadtransform
	| augroup! loadtransform
augroup END
nnoremap <Leader>ha :Zen2han<CR>
xnoremap <Leader>ha :Zen2han<CR>