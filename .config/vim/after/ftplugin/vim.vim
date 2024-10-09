scriptencoding utf-8

if exists('b:did_reset')
	finish
endif
let b:did_reset = 1

if !exists('g:vim_after_plugin')
	let g:vim_after_plugin = 1
	augroup myAfterVIM
		autocmd!
		autocmd FileType vim setlocal formatoptions-=c textwidth=0 iskeyword-=# " デフォルト設定から好みに変更
	augroup END
endif
