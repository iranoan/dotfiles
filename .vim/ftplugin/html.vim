"HTML 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

"--------------------------------
"ファイルタイプ別のグローバル設定
"--------------------------------
" if !exists('g:html_plugin')
" 	let g:html_plugin = 1
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
" compiler HTML
setlocal makeprg=html-check.sh\ \"%\"
"setlocal makeprg=tidy\ -raw\ -quiet\ -errors\ -e\ --gnu-emacs\ yes\ \"%\"
"setlocal shellpipe=2>
" setlocal errorformat=%f:%l:%c:\ %m,%f:%l:%m
setlocal errorformat=%f:%l:%c:\ %trror:\ %m,%f:%l:%c:\ %m,%f:%l:%m
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
inoremap <expr><buffer><S-Enter>   pumvisible#Insert('<li>') .. '<C-G>u'
inoremap <expr><buffer><C-Enter>   (getline('.') =~# '^\s*$' ?  '' : '<CR>') . '<End><p></p><Left><Left><Left><Left><C-G>u'
inoremap <expr><buffer><S-C-Enter> pumvisible#Insert_after('<br>') .. '<C-G>u'
inoremap <buffer><<                &lt;
inoremap <buffer><=                &le;
inoremap <buffer>>>                &gt;
inoremap <buffer>>=                &ge;
inoremap <buffer>&&                &amp;
inoremap <buffer>--                ‐
inoremap <buffer>---               ―
" <S,C-Space> の組み合わせは GUI のみ有効
imap     <expr><buffer><C-Space>   pumvisible() ? asyncomplete#close_popup() : '&nbsp;'
inoremap <buffer>&<space>          &nbsp;
inoremap <buffer>\\                &yen;
inoremap <buffer>+-                &plusmn;
inoremap <buffer>==                &equiv;
inoremap <buffer><!                <!DOCTYPE html>
"--------------------------------
setlocal spelloptions=camel
"折りたたみ
setlocal foldmethod=syntax
" setlocal foldcolumn=6
"--------------------------------
"CSS を補完候補に↓必要無さそう
" setlocal include=<link\\s*rel=[\"\']stylesheet[\"\']\\s*type=[\"\']text\\/css[\"\']\\s*href=[\"\']\\zs[^\"\']\\+\\ze[\"\']>
