"CSS 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

"ファイルタイプ別のグローバル設定
"--------------------------------
" if !exists("g:css_plugin")
" 	let g:css_plugin = 1
" endif
"--------------------------------
"ファイルタイプ別ローカル設定
"--------------------------------
setlocal makeprg=css-check.sh\ \"%\"
setlocal omnifunc=csscomplete#CompleteCSS
"----------------------------------------------------------------------
"折りたたみ fold
" setlocal foldmethod=marker foldmarker={,} " ←連続するコメントも対象にしたいので止め
setlocal foldmethod=syntax
"対応するカッコの入力
" inoremap <buffer> " ""<Left>
" inoremap <buffer> ' ''<Left>
" inoremap <buffer> /* /*  */<Left><Left><Left>
setlocal equalprg=prettier\ --write\ --use-tabs\ --stdin-filepath\ %\|stylelint\ --fix\ --stdin\ --no-color
setlocal spelloptions=camel
