"XHTML 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

"--------------------------------
"ファイルタイプ別のグローバル設定
"--------------------------------
" if !exists('g:xml_syntax_folding')
" 	let g:xml_syntax_folding = 1
" 	"--------------------------------
" 	" augroup myHTML
" 	" 	autocmd!
" 	" 	" 以下プラグインに変えた
" 	" 	" autocmd FileType markdown      inoremap <buffer> </ </<C-x><C-o>
" 	" augroup END
" endif
"--------------------------------
"ファイルタイプ別ローカル設定
"--------------------------------
" compiler XHTML
setlocal makeprg=html-check.sh\ \"%\"
setlocal errorformat=%f:%l:%c:\ %trror:\ %m,%f:%l:%c:\ info\ %tarning:\ %m,%f:%l:%c:\ %tnfo\ warning:\ %m,%f:%l:%c:\ %m,%f:%l:%m
setlocal formatlistpat=^\\s*<\\(li\\\|dt\\\|dd\\)>
setlocal breakindentopt=list:4
"--------------------------------
" オムニ補完関数指定
setlocal omnifunc=htmlcomplete#CompleteTags
"--------------------------------
"ファイルタイプ別 map
inoremap <buffer> </ </<C-x><C-o>
" ↑オムニ補完を利用して閉じタグ自動補完
nnoremap <silent><buffer><Leader>v :silent !firefox %<CR>
" <S,C-Enter> の組み合わせは GUI のみ有効
inoremap <expr><buffer><S-Enter>   pumvisible#Insert('<li></li><Left><Left><Left><Left><Left><C-G>u')
inoremap <expr><buffer><C-Enter>   (getline('.') =~# '^\s*$' ?  '' : '<CR>') . '<End><p></p><Left><Left><Left><Left><C-G>u'
inoremap <expr><buffer><S-C-Enter> pumvisible#Insert_after('<br />') .. '<C-G>u'
inoremap <buffer><<                &lt;
inoremap <buffer>>>                &gt;
inoremap <buffer><=                &#8804;
inoremap <buffer>>=                &#8805;
inoremap <buffer>&&                &amp;
inoremap <buffer>--                ‐
inoremap <buffer>---               ―
" <S,C-Space> の組み合わせは GUI のみ有効
imap     <expr><buffer><C-Space>   pumvisible() ? asyncomplete#close_popup() : '&#160;'
inoremap <buffer>&<space>          &#160;
inoremap <buffer>\\                &#165;
inoremap <buffer>+-                &#177;
inoremap <buffer>**                &#215;
inoremap <buffer>==                &#8801;
"--------------------------------
setlocal spelloptions=camel
"折りたたみ
setlocal foldmethod=syntax
