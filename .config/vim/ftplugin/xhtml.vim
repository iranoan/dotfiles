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
setlocal iskeyword=a-z,A-Z,48-57,_,- " class, id 名に - が使える
execute 'source ' .. expand('<sfile>:p:h') .. '/../macros/html-xhtml-common.vim'
inoremap <expr><buffer><S-Enter>   pumvisible#Insert('<li></li><Left><Left><Left><Left><Left><C-G>u')
inoremap <expr><buffer><S-C-Enter> pumvisible#Insert_after('<br />') .. '<C-G>u'
inoremap <buffer><=                &#8804;
inoremap <buffer>>=                &#8805;
imap     <expr><buffer><C-Space>   pumvisible() ? asyncomplete#close_popup() : '&#160;'
inoremap <buffer>&<space>          &#160;
inoremap <buffer>\\                &#165;
inoremap <buffer>+-                &#177;
inoremap <buffer>**                &#215;
inoremap <buffer>==                &#8801;
