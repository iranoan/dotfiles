"HTML 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

" ファイルタイプ別のグローバル設定 {{{1
" if !exists('g:did_ftplugin_html')
" 	let g:did_ftplugin_html = 1
" 	"--------------------------------
" endif

" ファイルタイプ別ローカル設定 {{{1
execute 'source ' .. expand('<sfile>:p:h') .. '/../macros/html-xhtml-common.vim'
inoremap <expr><buffer><S-Enter>   pumvisible#Insert('<li>') .. '<C-G>u'
inoremap <expr><buffer><S-C-Enter> pumvisible#Insert_after('<br>') .. '<C-G>u'
inoremap <buffer><=                &le;
inoremap <buffer>>=                &ge;
imap     <expr><buffer><C-Space>   pumvisible() ? asyncomplete#close_popup() : '&nbsp;'
inoremap <buffer>&<space>          &nbsp;
inoremap <buffer>\\                &yen;
inoremap <buffer>+-                &plusmn;
inoremap <buffer>**                &times;
inoremap <buffer>==                &equiv;
