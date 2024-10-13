"XHTML 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

" ファイルタイプ別のグローバル設定 {{{1
" if !exists('g:did_ftplugin_html')
" 	let g:did_ftplugin_html = 1
" 	" augroup myXHTML
" 	" 	autocmd!
" 	" augroup END
" endif

" ファイルタイプ別ローカル設定 {{{1
source $MYVIMDIR/macros/html-xhtml-common.vim
inoremap <expr><buffer><S-Enter>   pumvisible#Insert('<li></li><Left><Left><Left><Left><Left><C-G>u')
inoremap <expr><buffer><S-C-Enter> pumvisible#Insert_after('<br />') .. '<C-G>u'
inoremap <buffer><=                &#8804;
inoremap <buffer>>=                &#8805;
imap     <expr><buffer><C-Space>   pumvisible() ? asyncomplete#close_popup() : '&#160;'
inoremap <buffer>&<space>          &#160;
inoremap <buffer>--                &#8211;
inoremap <buffer>---               &#8212;
inoremap <buffer>\\                &#165;
inoremap <buffer>+-                &#177;
inoremap <buffer>**                &#215;
inoremap <buffer>==                &#8801;
