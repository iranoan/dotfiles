"TeX 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

"--------------------------------
"ファイルタイプ別のグローバル設定
"--------------------------------
" if !exists('g:tex_plugin')
" 	let g:tex_plugin = 1
" 	" let g:tex_conceal=''                    " TeXのキーワード置き換えはかえって見難いのでキャンセル
" 	" setlocal conceallevel=0                 " vimrc 側でやっている
" 	augroup myTeX
" 		autocmd!
" 		autocmd FileType tex setlocal termwinsize=5x0
" 	augroup END
" endif
"--------------------------------
"ファイルタイプ別ローカル設定
"--------------------------------
"find コマンドが使えることは前提で、~/texmf/ やシステム配下にある個人用のファイルを gf で開けるようにする
" r!find $HOME/texmf/ -type f -name "*.ty" -o -name "*.tex" -o -name "*.cls" -o -name "*.bst" -o -name "*.bib" | sed -r 's/\/[^\/]+$//g' | sort | uniq | sed -e 's/^/\t\t\t\\ .. '\''/g' -e 's/$/,'\''/g'
" r!find /usr/local/texlive/*/texmf-dist -type f -name "*.sty" -o -name "*.cls" -o -name "*.bst" -o -name "*.bib" | sed -r 's/\/[^\/]+$//g' | sort | uniq |  sed -e 's/^/\t\t\t\\ .. '\''/g' -e 's/$/,'\''/g'
" で探す
let &l:path=',/home/hiroyuki/texmf/**,/usr/local/texlive/*/texmf-dist/tex/**,'
" 検索 path の設定:あまりに長いので、一行一ディレクトリ形式は次の方法でも出来るが開くのに時間がかかる
" let &l:path=
" 			\ '.,' .. substitute(substitute(substitute(system('find ~/texmf/ -type d'),'\n',',',"g"),
" 			\ ',$','',""),
" 			\ '\\','/',"g")
" 			\ .. ',' .. substitute(substitute(substitute(system('find /usr/local/texlive/*/texmf-dist/ -type d'),'\n',',',"g"),
" 			\ ',$','',""),
" 			\ '\\','/',"g")
"↑カレント・ディレクトリ追加+リストアップ、改行を , に変換、最後の , は削除、Windows に対応 (\→/ 変換) の順序
setlocal makeprg=lacheck\ %
"Warning+lacheck+latex で -file-line-error オプションを使ったフォーマット
" setlocal errorformat=%WLaTeX\ %.%#Warning:\ %m,%WLaTeX\ Warning:\ %.%#line\ %l%m,\"%f\"\\,\ line\ %l:\ %m,%f:%l:\ %m,
setlocal errorformat=%WLaTeX\ Warning:\ %.%#line\ %l%m,\"%f\"\\,\ line\ %l:\ %m,%f:%l:\ %m,
"--------------------------------
"ファイルタイプ別 map
nnoremap <buffer><Leader>v         <Cmd>wa<CR>:silent !zathura-sync.sh <C-r>=expand('%:p')<CR> <C-r>=line(".")<CR> <C-r>=col(".")<CR><CR>
" <Enter> の組み合わせは GUI のみ有効
inoremap <expr><buffer><S-Enter>   pumvisible#insert('\item<Tab>')
inoremap <expr><buffer><S-C-Enter> pumvisible#insert_after('\\')
inoremap <expr><buffer><C-Enter>   pumvisible#insert("\\clearpage\n")
"--------------------------------
"gfなどで、拡張子を補完
setlocal suffixesadd=.tex,.cls,.sty
"--------------------------------
setlocal iskeyword=@,48-57,_,-,:,.,192-255 "\labelには/を使うことも有るが、使い難いので止めておく←タグジャンプなら範囲選択してから行えば良い
" setlocal termwinsize=5x0 " ←グローバルな set なら利く
" let b:match_ignorecase = 1
" let b:match_words =  &matchpairs .. ",{,}:[:],<:>,\\begin{\([A-Za-z]\+\)}:\\end{\1}"

