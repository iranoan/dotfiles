"CSS 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

" ファイルタイプ別のグローバル設定 {{{1
if !exists("g:css_plugin")
	let g:css_plugin = 1
	packadd vim-css3-syntax
	augroup MyCSS
		autocmd!
		autocmd BufEnter ~/bin/kindle/*,~/book/epub/*/OEBPS/css/*.css let b:ale_linters = #{ css: ['stylelint-v16']} | ALEDisableBuffer | ALEEnableBuffer
	augroup END
endif

" ファイルタイプ別ローカル設定 {{{1
setlocal makeprg=css-check.sh\ \"%\"
setlocal omnifunc=csscomplete#CompleteCSS
setlocal spelloptions=camel
" 折りたたみ fold {{{2
" setlocal foldmethod=marker foldmarker={,} " ←連続するコメントも対象にしたいので止め
setlocal foldmethod=syntax
"対応するカッコの入力 {{{2
" inoremap <buffer> " ""<Left>
" inoremap <buffer> ' ''<Left>
" inoremap <buffer> /* /*  */<Left><Left><Left>
