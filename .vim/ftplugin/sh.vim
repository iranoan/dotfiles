"シェルスクリプト用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

"--------------------------------
"ファイルタイプ別のグローバル設定
"--------------------------------
if !exists('g:is_bash')
	let g:sh_fold_enabled=7
	let g:is_bash=1
endif
" if !exists('g:sh_plugin')
" 	let g:sh_plugin = 1
" 	" augroup mySh
" 	" 	autocmd!
" 	" augroup END
" endif
"--------------------------------
"ファイルタイプ別ローカル設定
"--------------------------------
setlocal foldmethod=syntax
" ヘルプ
" setlocal keywordprg=man
