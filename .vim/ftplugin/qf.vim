"QuickFix 用の設定
scriptencoding utf-8

if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

"ファイルタイプ別のグローバル設定 {{{1
"--------------------------------
if !exists("g:qf_plugin")
	let g:qf_plugin = 1
	augroup QuickFix
		autocmd!
		autocmd WinEnter     *
					\ if winnr('$') == 1 && getbufvar(winbufnr(0), '&buftype') == 'quickfix' |
					\ 	if tabpagenr('$') == 1  |
					\ 		quit |
					\ 	else |
					\ 		let qfwin = bufnr('') |
					\ 		:normal! gt |
					\ 		execute 'bwipeout ' .. qfwin |
					\ 	endif |
					\ endif " QuickFix だけなら閉じる
	augroup END
endif
" }}}
nnoremap <buffer><silent>q :close<CR> | setlocal signcolumn=auto foldcolumn=0
