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
execute 'source ' .. expand('<sfile>:p:h') .. '/../macros/html-xhtml-common.vim'
inoremap <expr><buffer><S-Enter>   pumvisible#Insert('<li>') .. '<C-G>u'
inoremap <expr><buffer><S-C-Enter> pumvisible#Insert_after('<br>') .. '<C-G>u'
inoremap <buffer><=                &le;
inoremap <buffer>>=                &ge;
imap     <expr><buffer><C-Space>   pumvisible() ? asyncomplete#close_popup() : '&nbsp;'
inoremap <buffer>&<space>          &nbsp;
inoremap <buffer>\\                &yen;
inoremap <buffer>+-                &plusmn;
inoremap <buffer>==                &equiv;
inoremap <buffer><!                <!DOCTYPE html>
