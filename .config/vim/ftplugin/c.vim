"C/C++ 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

"ファイルタイプ別のグローバル設定 {{{1
" if !exists("g:c_plugin")
" 	let g:c_plugin = 1
" endif

" ファイルタイプ別ローカル設定 {{{1 {{{1
" % で行き来できる記号
setlocal matchpairs-=<:>     " C/C++ で <> をペアで使うのは #include ぐらいで、他は大小記号やアロー演算子
" setlocal matchpairs+==:;     " = (代入) と行末間で移動
"対応するカッコの入力 {{{2 ←lexima.vim に
" inoremap <buffer> " ""<Left>
" inoremap <buffer> ' ''<Left>
" inoremap <buffer> /* /*  */<Left><Left><Left>
"コンパイルして実行 {{{2
nnoremap <buffer><Leader>gcc :setlocal fileencoding= \| w! \| !gcc -W -Wall "%" -lm && ./a.out < ~/Information/slide/C/data/a.txt && ./a.out < ~/Information/slide/C/data/b.txt && ./a.out < ~/Information/slide/C/data/c.txt && ./a.out < ~/Information/slide/C/data/d.txt<CR>
"--------------------------------
" その他 {{{2
" setlocal keywordprg=:terminal\ ++close\ man\ 3 " ヘルプ
setlocal equalprg=clang-format\ - "clang-format
if filereadable('Makefile')
	setlocal makeprg=make
elseif executable('clang')
	setlocal makeprg=clang\ %:p\ -o\ %:p:r\ -Weverything\ -Wno-sign-conversion\ -Wno-old-style-cast\ -lm
else
	setlocal makeprg=gcc\ %:p\ -o\ %:p:r\ -W\ -Wall\ -lm
endif
setlocal path=.,/usr/include,/usr/local/include,/usr/lib/c++/v1
setlocal foldmethod=syntax
setlocal errorformat =
			\%E%f:%l:%c:\ fatal\ error:\ %m,
			\%E%f:%l:%c:\ error:\ %m,
			\%W%f:%l:%c:\ warning:\ %m,
			\%f:%l:%c:\ %m,
			\%E%f:%l:\ error:\ %m,
			\%W%f:%l:\ warning:\ %m,
			\%f:%l:\ %m,
			\%-G%\\m%\\%%(LLVM\ ERROR:%\\\|No\ compilation\ database\ found%\\)%\\@!%.%#,
			\%-G%f:%l:\ %#error:\ %#for\ each\ function\ it\ appears%.%#,
			\%-GIn\ file\ included%.%#,
			\%-G\ %#from\ %f:%l\\,,
			\%-G%f:%l:\ %#error:\ %#(Each\ undeclared\ identifier\ is\ reported\ only%.%#,
			\%-G%f:%s:,
			\%E%m
