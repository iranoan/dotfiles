scriptencoding utf-8
" 今の所デフォルトの再設定に用いている

if exists('b:did_reset')
	finish
endif
let b:did_reset = 1

if !exists('g:vim_after_plugin')
	let g:vim_after_plugin = 1
	augroup myAfterVIM
		autocmd!
		autocmd FileType vim set formatoptions-=c " textwidth を使った自動折返しをしない←vim で再設定されている
	augroup END
endif
