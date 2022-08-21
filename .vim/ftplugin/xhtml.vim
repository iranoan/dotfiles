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
" " 	"--------------------------------
" " 	" augroup myHTML
" " 	" 	autocmd!
" " 	" 	" 以下プラグインに変えた
" " 	" 	" autocmd FileType markdown      inoremap <buffer> </ </<C-x><C-o>
" " 	" augroup END
" endif
"--------------------------------
"ファイルタイプ別ローカル設定
"--------------------------------
" オムニ補完関数指定
setlocal omnifunc=htmlcomplete#CompleteTags
"--------------------------------
"ファイルタイプ別 map
inoremap <buffer> </ </<C-x><C-o>
" ↑オムニ補完を利用して閉じタグ自動補完

nnoremap <silent><buffer><Leader>v :silent !/usr/bin/firefox %<CR>
inoremap <expr><buffer><C-Enter>   (getline('.') =~# '^\s*$' ?  '' : '<CR>') . '<End><p><CR></p><CR><UP><CR><UP>'
inoremap <buffer><S-C-Enter>       <End><br><Enter>
inoremap <buffer><<                &lt;
inoremap <buffer>>>                &gt;
inoremap <buffer><=                &#8804;
inoremap <buffer>>=                &#8805;
inoremap <buffer>&&                &amp;
inoremap <buffer>~~                &#8764;
inoremap <buffer>--                &#8211;
inoremap <buffer>---               &#8212;
inoremap <buffer><C-space>         &#160;
inoremap <buffer>&<space>          &#160;
inoremap <buffer>\\                &#165;
inoremap <buffer>+-                &#177;
inoremap <buffer>**                &#215;
inoremap <buffer>==                &#8801;
"--------------------------------
setlocal foldmethod=syntax
