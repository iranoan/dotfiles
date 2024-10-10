"メール用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

"--------------------------------
"ファイルタイプ別のグローバル設定
"--------------------------------
" if !exists('g:vim_plugin')
" 	let g:vim_plugin = 1
" 	augroup MailType
" 		autocmd!
" 		autocmd BufWinEnter,WinEnter,FocusGained * if &filetype ==# 'mail' | setlocal textwidth=0 expandtab | endif
" 		autocmd FileType mail setlocal textwidth=0 expandtab
" 	augroup END
" endif

"--------------------------------
"ファイルタイプ別のローカル設定
"--------------------------------
setlocal foldmethod=syntax commentstring=>%s
