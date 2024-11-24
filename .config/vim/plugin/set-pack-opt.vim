vim9script
scriptencoding utf-8

# 補完 https://github.com/prabirshrestha/asyncomplete.vim {{{1
augroup loadasyncomplete
	autocmd!
	autocmd InsertEnter *
				\ set_asyncomplete#main()
				| autocmd! loadasyncomplete
				| augroup! loadasyncomplete
				| delfunction set_asyncomplete#main
augroup END

# 小文字で始まるコマンドを定義可能に https://github.com/kana/vim-altercmd {{{1
# ↓実質 /start/と同じになるが、単純に /start/ に置くと、このスクリプト読み込み時点では AlterCommand が使えず、エラーになるので読み込み明示形式にする
packadd vim-altercmd
AlterCommand e[dit]     TabEdit
AlterCommand ut[f8]     edit\ ++enc=utf8
AlterCommand sj[is]     edit\ ++enc=cp932
AlterCommand cp[932]    edit\ ++enc=cp932
AlterCommand eu[c]      edit\ ++enc=eucjp-ms
AlterCommand ji[s]      edit\ ++enc=iso-2022-jp-3
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
AlterCommand p[rint]    PrintBuffer
# ↑:print は使わないので、印刷に置き換え
AlterCommand u[pdate]   update
# ↑:update の短縮形は :up で :u は :undo だがまず使わない
AlterCommand ua[ll]     bufdo\ update
AlterCommand helpt[ags] PackManage\ tags
AlterCommand bc         .!bc\ -l\ -q\ ~/.bc\ <Bar>\ sed\ -E\ -e\ 's/^\\\./0./g'\ -e\ 's/(\\\.[0-9]*[1-9])0+/\\\1/g'\ -e\ 's/\\\.$//g'
AlterCommand bi[nary]   if\ !&binary\ <Bar>\ execute('setlocal\ binary\ <Bar>\ %!xxd')\ <Bar>\ endif
AlterCommand nob[inary] if\ &binary\ <Bar>\ execute('setlocal\ nobinary\ <Bar>\ %!xxd\ -r')\ <Bar>\ endif
# fugitive.vim 用 (glob() を使う存在確認は遅い)
AlterCommand git      Git
AlterCommand gl[og]   Gllog
AlterCommand gd[iff]  Gdiffsplit
# grep, lgpre は gnu-grep に置き換え
AlterCommand gr[ep]     Grep
AlterCommand lgr[ep]    LGrep
AlterCommand grepa[dd]  Grepadd
AlterCommand lgrepa[dd] LGrepadd

# 2019-03-31 14:51 などの日付や時刻もうまい具合に Ctrl-a/x で加算減算する https://github.com/tpope/vim-speeddating {{{1
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

# https://github.com/junegunn/fzf.vim {{{1
nnoremap <silent><Leader>fr <Cmd>Files ~<CR>
xnoremap <silent><Leader>fr <Cmd>Files ~<CR>
nnoremap <silent><Leader>ff <Cmd>Files<CR>
xnoremap <silent><Leader>ff <Cmd>Files<CR>
nnoremap <silent><Leader>fu <Cmd>Files ..<CR>
xnoremap <silent><Leader>fu <Cmd>Files ..<CR>
nnoremap <silent><Leader>f. <Cmd>Files ~/dotfiles<CR>
xnoremap <silent><Leader>f. <Cmd>Files ~/dotfiles<CR>
nnoremap <silent><Leader>fv <Cmd>Files $MYVIMDIR<CR>
xnoremap <silent><Leader>fv <Cmd>Files $MYVIMDIR<CR>
nnoremap <silent><Leader>fs <Cmd>Files ~/src<CR>
xnoremap <silent><Leader>fs <Cmd>Files ~/src<CR>
nnoremap <silent><Leader>fx <Cmd>Files ~/bin<CR>
xnoremap <silent><Leader>fx <Cmd>Files ~/bin<CR>
nnoremap <silent><Leader>fe <Cmd>Files ~/book/epub<CR>
xnoremap <silent><Leader>fe <Cmd>Files ~/book/epub<CR>
nnoremap <silent><Leader>fd <Cmd>Files ~/downloads<CR>
xnoremap <silent><Leader>fd <Cmd>Files ~/downloads<CR>
nnoremap <silent><Leader>fD <Cmd>Files ~/Document<CR>
xnoremap <silent><Leader>fD <Cmd>Files ~/Document<CR>
nnoremap <silent><Leader>fp <Cmd>Files ~/public_html/iranoan<CR>
xnoremap <silent><Leader>fp <Cmd>Files ~/public_html/iranoan<CR>
nnoremap <silent><Leader>fi <Cmd>Files ~/Information/slide<CR>
xnoremap <silent><Leader>fi <Cmd>Files ~/Information/slide<CR>
# nnoremap <silent><Leader>fb <Cmd>Buffers<CR>
# xnoremap <silent><Leader>fb <Cmd>Buffers<CR>
nnoremap <silent><Leader>fc <Cmd>Commands<CR>
xnoremap <silent><Leader>fc <Cmd>Commands<CR>
nnoremap <silent><Leader>fg <Cmd>GFiles?<CR>
xnoremap <silent><Leader>fg <Cmd>GFiles?<CR>
nnoremap <silent><Leader>fh <Cmd>HISTORY<CR>
xnoremap <silent><Leader>fh <Cmd>HISTORY<CR>
nnoremap <silent><Leader>fH <Cmd>HelpTags<CR>
xnoremap <silent><Leader>fH <Cmd>HelpTags<CR>
nnoremap <silent><Leader>fl <Cmd>BLines<CR>
xnoremap <silent><Leader>fl <Cmd>BLines<CR>
nnoremap <silent><Leader>fm <Cmd>Marks<CR>
xnoremap <silent><Leader>fm <Cmd>Marks<CR>
nnoremap <silent>m/         <Cmd>Marks<CR>
xnoremap <silent>m/         <Cmd>Marks<CR>
# ↑ vim-signature のデフォルト・キーマップをこちらに再定義
# nnoremap <silent><Leader>ft :Tags<CR>
# xnoremap <silent><Leader>ft :Tags<CR>
# nnoremap <silent><Leader>fw <Cmd>Windows<CR>
# xnoremap <silent><Leader>fw <Cmd>Windows<CR>
nnoremap <silent><Leader>f: <Cmd>History:<CR>
xnoremap <silent><Leader>f: <Cmd>History:<CR>
nnoremap <silent><Leader>f/ <Cmd>History/<CR>
xnoremap <silent><Leader>f/ <Cmd>History/<CR>
augroup loadFZF_Vim
	autocmd!
	autocmd CmdUndefined Files,Buffers,Tags,Marks,History,HISTORY,GFiles,Windows,Helptags,Commands,BLines,HelpTags
				\ set_fzf_vim#main()
				| autocmd! loadFZF_Vim
				| augroup! loadFZF_Vim
				| delfunction set_fzf_vim#main
augroup END

# yank の履歴 https://github.com/justinhoward/fzf-neoyank {{{1
nnoremap <Leader>fy <Cmd>FZFNeoyank<CR>
nnoremap <Leader>fY <Cmd>FZFNeoyank # P<CR>
xnoremap <Leader>fy <Cmd>FZFNeoyankSelection<CR>
# nnoremap <Leader>dy <Cmd>FZFNeoyank<CR>
# nnoremap <Leader>dY <Cmd>FZFNeoyank " P<CR>
# xnoremap <Leader>dy <Cmd>FZFNeoyankSelection<CR>
augroup loadfzf_neoyank
	autocmd!
	autocmd CmdUndefined FZFNeoyank,FZFNeoyankSelection
				\ set_fzf_neoyank#main()
				| autocmd! loadfzf_neoyank
				| augroup! loadfzf_neoyank
				| delfunction set_fzf_neoyank#main
augroup END

# fzf を使ってタブ・ページの切り替え $MYVIMDIR/pack/my-plug/opt/fzf-tabs/ {{{1
nnoremap <Leader>ft <Cmd>FZFTabOpen<CR>
vnoremap <Leader>ft <Cmd>FZFTabOpen<CR>
nnoremap <Leader>fb <Cmd>FZFTabOpen<CR>
nnoremap <Leader>fw <Cmd>FZFTabOpen<CR>
augroup load_fzf_tabs
	autocmd!
	autocmd CmdUndefined FZFTabOpen
				\ set_fzf_tabs#main()
				| autocmd! load_fzf_tabs
				| augroup! load_fzf_tabs
				| delfunction set_fzf_tabs#main
augroup END

# 日本語入力に向いた設定にする (行の連結など) https://github.com/vim-jp/autofmt {{{1
augroup loadautofmt
	autocmd!
	autocmd FileType text,mail,notmuch-edit set_autofmt#main()
				| autocmd! loadautofmt
				| augroup! loadautofmt
				| delfunction set_autofmt#main
augroup END

# vim 折りたたみ fold $MYVIMDIR/pack/my-plug/opt/vim-ft-vim_fold/ {{{1 https://github.com/thinca/vim-ft-vim_fold を組み合わせ追加のために置き換え
augroup loadvim_ft_vim_fold
	autocmd!
	autocmd FileType vim packadd vim-ft-vim_fold
	| autocmd! loadvim_ft_vim_fold
	| augroup! loadvim_ft_vim_fold
augroup END

# ディレクトリを再帰的に diff https://github.com/will133/vim-dirdiff {{{1
augroup loadDirDiff
	autocmd!
	autocmd CmdUndefined DirDiff g:DirDiffForceLang = 'C LC_MESSAGES=C'
	| g:DirDiffExcludes = ".git,.*.swp"
	| packadd vim-dirdiff
	| autocmd! loadDirDiff
	| augroup! loadDirDiff
augroup END

# notmuch-python-Vim $MYVIMDIR/pack/my-plug/opt/notmuch-py-vim/ {{{1
nnoremap <silent><Leader>m :Notmuch start<CR>
augroup loadNotmuchPy
	autocmd!
	autocmd CmdUndefined Notmuch
				\ set_notmuchpy#main()
				| autocmd! loadNotmuchPy
				| augroup! loadNotmuchPy
				| delfunction set_notmuchpy#main
augroup END
# augroup NotmuchDraft # バッファを開き終わった後に asyncomplete が効かない
# 	autocmd!
# 	autocmd FileType notmuch-draft
# 				\ if !pack_manage#IsInstalled('asyncomplete.vim')
# 				| 	set_asyncomplete#main()
# 				| 	autocmd! loadasyncomplete
# 				| 	augroup! loadasyncomplete
# 				| 	delfunction set_asyncomplete#main
# 				| endif
# 				| call asyncomplete#enable_for_buffer()
# 				| autocmd! NotmuchDraft
# 				| augroup! NotmuchDraft
# augroup END

# 各種言語の構文チェック https://github.com/dense-analysis/ale {{{1
augroup loadALE
	autocmd!
	# autocmd FileType c,cpp,python,ruby,yaml,markdown,html,xhtml,css,tex,help,json
	autocmd FileType c,cpp,ruby,yaml,markdown,html,xhtml,css,tex,help,json
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
				\ set_vista_voom#Vista()
				| autocmd! loadVista
				| augroup! loadVista
				| delfunction set_vista_voom#Vista
augroup END
# 次の Voom に未対応は Vista を使う様に分岐関数とキーマップ
nnoremap <silent><Leader>o :call set_vista_voom#Switch()<CR>

# アウトライン https://github.com/vim-voom/VOoM {{{1
augroup loadVOoM
	autocmd!
	autocmd CmdUndefined Voom
				\ set_vista_voom#VOom()
				| autocmd! loadVOoM
				| augroup! loadVOoM
				| delfunction set_vista_voom#VOom
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
	autocmd FuncUndefined fugitive#*
				\ set_fugitve#main()
				| autocmd! loadFugitive
				| augroup! loadFugitive
				| delfunction set_fugitve#main
augroup END

# Git の変更のあった signcolumn にマークをつける https://github.com/airblade/vim-gitgutter {{{1
# 遅延読み込みをすると vim-signature との連携機能が使えない←連携できないだけ+ただし単純に /start に置くと git がないときに起動時にエラーになる
# augroup loadGitgutter
# 	autocmd!
# 	autocmd FileType c,cpp,python,vim,ruby,yaml,markdown,html,xhtml,css,tex,sh,bash set_gitgutter#main()
# 				| autocmd! loadGitgutter
# 				| augroup! loadGitgutter
# 				| delfunction set_gitgutter#main
# augroup END
if executable('git')
	packadd vim-gitgutter
	set_gitgutter#main()
	delfunction set_gitgutter#main
endif

# カーソル位置の Syntax の情報を表示する $MYVIMDIR/pack/my-plug/opt/syntax_info/ {{{1 http://cohama.hateblo.jp/entry/2013/08/11/020849 を参考にした
augroup loadSyntaxInfo
	autocmd!
	autocmd CmdUndefined SyntaxInfo packadd syntax_info
	| autocmd! loadSyntaxInfo
	| augroup! loadSyntaxInfo
augroup END

# Man コマンドを使用可能にする $MYVIMDIR/pack/my-plug/opt/man {{{1
augroup ManCommand
	autocmd!
	autocmd CmdUndefined Man packadd man
	| autocmd! ManCommand
	| augroup! ManCommand
augroup END

# カレント・タブ・ページ内では同じターミナルを閉じる $MYVIMDIR/pack/my-plug/opt/kill-terminal {{{1
augroup KillTerminal
	autocmd!
	autocmd TerminalOpen * kill_terminal#Main()
augroup END
augroup loadKillTerminal
	autocmd!
	autocmd FuncUndefined kill_terminal#Main packadd kill-terminal
	| autocmd! loadKillTerminal
	| augroup! loadKillTerminal
augroup END

# ページ送りに $MYVIMDIR/pack/my-plug/opt/page-down {{{1
nnoremap <silent><space> :call page_down#Main()<CR>
augroup loadPageDown
	autocmd!
	autocmd FuncUndefined page_down#Main packadd page-down
	| autocmd! loadPageDown
	| augroup! loadPageDown
augroup END

# カーソル位置の単語を Google で検索 $MYVIMDIR/pack/my-plug/opt/google-search/ {{{1 https://www.rasukarusan.com/entry/2019/03/09/011630 を参考にした
nnoremap <silent><Leader>s :SearchByGoogle<CR>
xnoremap <silent><Leader>s :SearchByGoogle<CR>
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
	| if &filetype !=# 'help' | setlocal filetype=help | endif
	| autocmd! loadVimHelpGenerator
	| augroup! loadVimHelpGenerator
	autocmd BufWinEnter *.jax packadd vimhelpgenerator
	| if &filetype !=# 'help' | setlocal filetype=help | endif
	| autocmd! loadVimHelpGenerator
	| augroup! loadVimHelpGenerator
augroup END

# 編集中の Markdown をブラウザでプレビュー https://github.com/shime/vim-livedown {{{1
augroup MyMarkdown
	autocmd!
	autocmd FileType markdown nnoremap <silent><buffer><Leader>v <Cmd>LivedownPreview<CR>
augroup END
augroup loadLivedownPreview
	autocmd!
	autocmd CmdUndefined LivedownPreview
				\ packadd vim-livedown
				| autocmd! loadLivedownPreview
				| augroup! loadLivedownPreview
augroup END

# EPWING の辞書を呼び出す https://github.com/deton/eblook.vim {{{1
xnoremap <silent><Leader>eb <Cmd>call set_eblook#SearchVisual()<CR>
nnoremap <silent><Leader>eb <Cmd>call set_eblook#SearchWord()<CR>
xnoremap <silent>K          <Cmd>call set_eblook#SearchVisual()<CR>
nnoremap <silent>K          <Cmd>call set_eblook#SearchWord()<CR>

# Undo をツリー表示で行き来する https://github.com/mbbill/undotree {{{1
nnoremap <silent><Leader>u <Cmd>UndotreeToggle<CR>
g:undotree_CustomUndotreeCmd  = 'vertical 30 new'
g:undotree_CustomDiffpanelCmd = 'botright 10 new'
augroup UndoTreeStatus
	autocmd!
	autocmd FileType undotree setlocal statusline=%#StatusLineLeft#%{t:undotree.GetStatusLine()}
augroup END
augroup loadUndotree
	autocmd!
	autocmd CmdUndefined UndotreeToggle packadd undotree
	| autocmd! loadUndotree
	| augroup! loadUndotree
augroup END

# https://github.com/prabirshrestha/vim-lsp {{{1
augroup loadvimlsp
	autocmd!
	autocmd FileType awk,c,cpp,python,vim,ruby,yaml,markdown,html,xhtml,tex,css,sh,bash,go,conf
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
nnoremap <Leader>d<Space> <Cmd>call vimspector#Stop()<CR>
nnoremap <Leader>db       <Cmd>call vimspector#ToggleBreakpoint()<CR>
nnoremap <Leader>dx       <Cmd>call vimspector#Reset( { 'interactive': v:false } )<CR>
nnoremap <Leader>di       <Plug>VimspectorBalloonEval
xnoremap <Leader>di       <Plug>VimspectorBalloonEval

# ファイル・マネージャー https://github.com/lambdalisue/fern.vim {{{1
nnoremap <Leader>e <Cmd>topleft Fern $HOME -drawer -reveal=%:p -toggle<CR>
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
	autocmd FileType sh,bash,vim,html,xhtml,markdown,lua set_context_filetype#main()
				| autocmd! loadcontext_filetype
				| augroup! loadcontext_filetype
				| delfunction set_context_filetype#main
augroup END

# 素早く移動する https://github.com/easymotion/vim-easymotion {{{1
for key in ['f', 'F', 't', 'T', 'w', 'W', 'b', 'B', 'e', 'E', 'ge', 'gE', 'j', 'k', 'n', 'N']
	execute 'nmap <Leader><Leader>' .. key .. '  <Cmd>call set_easymotion#main(''(easymotion-' .. key .. ')'') <bar> delfunction set_easymotion#main<CR>'
	execute 'xmap <Leader><Leader>' .. key .. '  <Cmd>call set_easymotion#main(''(easymotion-' .. key .. ')'') <bar> delfunction set_easymotion#main<CR>'
endfor
nmap <Leader><Leader>; <Cmd>call set_easymotion#main('(easymotion-next)') <bar> delfunction set_easymotion#main<CR>
nmap <Leader><Leader>, <Cmd>call set_easymotion#main('(easymotion-prev)') <bar> delfunction set_easymotion#main<CR>

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
for [n, q] in items({ 2: '"', 7: "'", 8: '(', 9: ')', '@': '`', ',': '<', '.': '>'})
	execute 'nmap ds' .. n .. ' ds' .. q
endfor
for [n1, q1] in items({ 2: '"', 7: "'", 8: '(', 9: ')', '@': '`', ',': '<', '.': '>', '"': '"', "'": "'", '(': '(', ')': ')', '`': '`', '<': '<', '>': '>', '[': '[', ']': ']', '{': '{', '}': '}' })
	for [n2, q2] in items({ 2: '"', 7: "'", 8: '(', 9: ')', '@': '`', ',': '<', '.': '>', '"': '"', "'": "'", '(': '(', ')': ')', '`': '`', '<': '<', '>': '>', '[': '[', ']': ']', '{': '{', '}': '}' })
		if n1 !=# n2 && q1 !=# q2 && n1 !=# q2 && q1 !=# n2 && n1 .. n2 !=# q1 .. q2
			execute 'nmap cs' .. n1 .. n2 .. ' cs' .. q1 .. q2
		endif
	endfor
endfor

# getmail syntax https://github.com/vim-scripts/getmail.vim {{{1
# augroup Gatmail
# 	autocmd!
# 	autocmd BufRead ~/.getmail/*,~/.config/getmail/* set_getmail_vim#main()
# augroup END

# dog と cat の入れ替えなどサイクリックに置換する関数などの定義 $MYVIMDIR/pack/my-plug/opt/replace-cyclic {{{1
augroup loadReplaceCyclic
	autocmd!
	autocmd FuncUndefined replace#* packadd replace-cyclic
	| autocmd! loadReplaceCyclic
	| augroup! loadReplaceCyclic
augroup END

# *.docx をまとめて epub 用のファイルに変換 $MYVIMDIR/pack/my-plug/opt/docx2xhtml {{{1
# カレント・ディレクトリに有る Google Document を使って OCR したファイルを前提とし、自作シェル・スクリプトや LibreOffice も呼び出しているごく個人的なスクリプト
augroup loadDocx2xhtml
	autocmd!
	autocmd FuncUndefined docx2xhtml#main packadd docx2xhtml
	| autocmd! loadDocx2xhtml
	| augroup! loadDocx2xhtml
augroup END

# 文字の変換 $MYVIMDIR/pack/my-plug/opt/transform/ {{{1
augroup loadtransform
	autocmd!
	autocmd FuncUndefined transform#* packadd transform
	| autocmd! loadtransform
	| augroup! loadtransform
	autocmd CmdUndefined Zen2han,InsertSpace,Han2zen,Hira2kata,Kata2hira,Base64 packadd transform
	| autocmd! loadtransform
	| augroup! loadtransform
augroup END
nnoremap <Leader>ha :Zen2han<CR>
xnoremap <Leader>ha :Zen2han<CR>
nnoremap <Leader>hh :InsertSpace<CR>
xnoremap <Leader>hh :InsertSpace<CR>
nnoremap <Leader>hz :Han2zen<CR>
xnoremap <Leader>hz :Han2zen<CR>
nnoremap <Leader>hk :Hira2kata<CR>
xnoremap <Leader>hk :Hira2kata<CR>
nnoremap <Leader>hH :Kata2hira<CR>
xnoremap <Leader>hH :Kata2hira<CR>
# nnoremap <Leader>hb :Base64<CR>

# Vim の環境を出力する $MYVIMDIR/pack/my-plug/opt/vim-system/ {{{1
augroup loadVimSystem
	autocmd!
	autocmd FuncUndefined vim_system#* packadd vim-system
	| autocmd! loadVimSystem
	| augroup! loadVimSystem
	autocmd CmdUndefined VimSystem,VimSystemEcho,System,SystemEcho packadd vim-system
	| autocmd! loadVimSystem
	| augroup! loadVimSystem
augroup END

# 印刷 $MYVIMDIR/pack/my-plug/opt/print/ {{{1
augroup loadPrint
	autocmd!
	autocmd CmdUndefined PrintBuffer packadd print
				| autocmd! loadPrint
				| augroup! loadPrint
augroup END

# 秀丸マクロ $MYVIMDIR/pack/my-plug/opt/hidemaru/ {{{1
augroup loadHidemaru
	autocmd!
	autocmd BufNewFile,BufRead ~/Hidemaru/Macro/{**/,}*.mac packadd hidemaru
				| autocmd! loadHidemaru
				| augroup! loadHidemaru
augroup END
augroup SetHidemaru
	autocmd!
	autocmd BufNewFile,BufRead ~/Hidemaru/Macro/{**/,}*.mac setlocal filetype=hidemaru
augroup END

# タグで挟む $MYVIMDIR/pack/my-plug/opt/surroundTag/ {{{1
# vim-surround では複数のタグを一度につけたり、クラス指定まで含む場合タイプ量が多くなる
augroup loadSurroundTag
	autocmd!
	autocmd CmdUndefined SurroundTag packadd surroundTag
				| autocmd! loadSurroundTag
				| augroup! loadSurroundTag
augroup END
augroup loadSurroundTagMap
	autocmd!
	autocmd FileType html,xhtml nnoremap <silent><buffer><leader>tt <Cmd>SurroundTag <span\ class="tcy"><CR>
	autocmd FileType html,xhtml xnoremap <silent><buffer><leader>tt <Cmd>SurroundTag <span\ class="tcy"><CR>
	autocmd FileType html,xhtml nnoremap <silent><buffer><leader>tr <Cmd>SurroundTag <ruby> <rp>(</rp><rt></rt><rp>)</rp><CR>
	autocmd FileType html,xhtml xnoremap <silent><buffer><leader>tr <Cmd>SurroundTag <ruby> <rp>(</rp><rt></rt><rp>)</rp><CR>
augroup END

# Markdown マッピング $MYVIMDIR/pack/my-plug/opt/map-markdown/ {{{1
augroup loadMapMarkdown
	autocmd!
	autocmd FileType markdown
				\ packadd map-markdown
				| autocmd! loadMapMarkdown
				| augroup! loadMapMarkdown
augroup END

# カーソル行の URL やファイルを開く $MYVIMDIR/pack/my-plug/opt/open_uri/ {{{1
nnoremap <silent><Leader>x <Cmd>call open_uri#main()<CR>
nnoremap <2-LeftMouse> <Cmd>call open_uri#main()<CR>
augroup OpenURI
	autocmd!
	autocmd FuncUndefined open_uri#* packadd open_uri
		| autocmd! OpenURI
		| augroup! OpenURI
augroup END

# $MYVIMDIR/pack/my-plug/opt/python-fold {{{1
augroup loadPythonFold
	autocmd!
	autocmd FileType python
				\ packadd python-fold
				| autocmd! loadPythonFold
				| augroup! loadPythonFold
augroup END
