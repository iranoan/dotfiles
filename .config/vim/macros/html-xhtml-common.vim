scriptencoding utf-8
" HTML/XHTML 共通設定
" 一部の参照表記や閉じるタグをつける/省略を変えているため

setlocal makeprg=html-check.sh\ \"%\"
setlocal errorformat=%f:%l:%c:\ %trror:\ %m,%f:%l:%c:\ info\ %tarning:\ %m,%f:%l:%c:\ %tnfo\ warning:\ %m,%f:%l:%c:\ %m,%f:%l:%m
setlocal formatlistpat=^\\s*<\\(li\\\|dt\\\|dd\\)\\(>\\\|\\s\\+\\ze[^>]\\+\\)
setlocal breakindentopt=list:4
"--------------------------------
" オムニ補完関数指定
setlocal omnifunc=htmlcomplete#CompleteTags
"--------------------------------
"ファイルタイプ別 map
inoremap <buffer> </ </<C-x><C-o>
" ↑オムニ補完を利用して閉じタグ自動補完
nnoremap <silent><buffer><Leader>v :update<Bar>silent !firefox %<CR>
" <S,C-Enter> の組み合わせは GUI のみ有効
inoremap <expr><buffer><C-Enter>   (getline('.') =~# '^\s*$' ?  '' : '<CR>') . '<End><p></p><Left><Left><Left><Left><C-G>u'
inoremap <buffer><<                &lt;
inoremap <buffer>>>                &gt;
inoremap <buffer>&&                &amp;
inoremap <buffer>--                ‐
inoremap <buffer>---               ―
setlocal spelloptions=camel
"折りたたみ
setlocal foldmethod=syntax
