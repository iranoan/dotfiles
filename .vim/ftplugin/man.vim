"man 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

"--------------------------------
"ファイルタイプ別のグローバル設定
"--------------------------------
" if !exists('g:ft_man_open_mode')
" 	let g:ft_man_open_mode = 'tab'
" 	--------------------------------
" 	 augroup myMAN
" 	 	autocmd!
" 		autocmd FileType man nnoremap <buffer><nowait>q :bwipeout!
" 	 	" autocmd FileType markdown inoremap <buffer> </ </<C-x><C-o>
" 	 augroup END
" endif
"--------------------------------
"ファイルタイプ別ローカル設定
"--------------------------------
setlocal nolist
setlocal nospell
setlocal foldmethod=indent foldenable foldlevelstart=99
