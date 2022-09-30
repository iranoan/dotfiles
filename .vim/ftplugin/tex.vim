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
" <S,C-Enter> の組み合わせは GUI のみ有効
inoremap <expr><buffer><S-Enter>   pumvisible#insert('\item<Tab>')
inoremap <expr><buffer><S-C-Enter> pumvisible#insert_after('\\')
inoremap <expr><buffer><C-Enter>   pumvisible#insert("\\clearpage\n")
nnoremap <buffer><leader>bb       <Cmd>call <SID>xbb()<CR>
"--------------------------------
"gfなどで、拡張子を補完
setlocal suffixesadd=.tex,.cls,.sty
"--------------------------------
setlocal iskeyword=@,48-57,_,-,:,.,192-255 "\labelには/を使うことも有るが、使い難いので止めておく←タグジャンプなら範囲選択してから行えば良い
" setlocal termwinsize=5x0 " ←グローバルな set なら利く
" let b:match_ignorecase = 1
" let b:match_words =  &matchpairs .. ",{,}:[:],<:>,\\begin{\([A-Za-z]\+\)}:\\end{\1}"
augroup TeXiskeyword " 入力時は補完時は数字を単語から外す (例:width=0.8textw→width=0.8\textwidth をやりやすく)
	autocmd!
	autocmd InsertEnter <buffer> setlocal iskeyword=@,_,-,:,.,192-255
	autocmd InsertLeave <buffer> setlocal iskeyword=@,48-57,_,-,:,.,192-255
augroup END

def s:xbb(): void # カーソル位置のパスの ebb -x -O の出力 (一部、ファイル名と HiResBoundingBox) を書き込む
	var line_str = getline('.')
	var end = 0
	var urls: list<any>
	var url: string
	var start: number
	while 1
		[url, start, end] = matchstrpos(line_str, '\m\C\(\~\=/\)\=\([A-Za-z\.\-_0-9]\+/\)*[A-Za-z\.\-_0-9]\+\.[A-Za-z]\{1,4\}', end)
		if start == -1
			break
		endif
		add(urls, [url, start, end])
	endwhile
	var col = col('.')
	for i in urls
		if i[1] < col + 1 && i[2] >= col - 1
			# カーソル位置は開始位置は一つ前、終了位置は一つ後でも許容範囲とする
			# TeX で画像を扱う時は、\includegraphics{graphic-path} と {} で挟むことが多いから
			url = i[0]
			if getftype(url) ==# ''
				echohl WarningMsg
				echo 'Not exist: ' .. url
				echohl None
				return
			endif
			if !filereadable(url)
				echohl WarningMsg
				echo 'Not readable ' .. url
				echohl None
				return
			endif
			urls = split(system('ebb -x -O ' .. url), '[\r\n]')
			execute "normal! o" .. urls[0] .. "\n" .. urls[3]
			return
		endif
	endfor
	echohl WarningMsg
	echo 'cursor postion do not write path.'
	echohl None
enddef
