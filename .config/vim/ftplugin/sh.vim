" scriptencoding utf-8
" " シェルスクリプト用の設定
" if exists('b:did_ftplugin_user')
" 	finish
" endif
" let b:did_ftplugin_user = 1
"
" " ファイルタイプ別のグローバル設定 {{{1
" " if !exists('g:sh_plugin')
" " 	let g:sh_plugin = 1
" " 	augroup mySh
" " 		autocmd!
" " 	augroup END
" " endif
"
" " ファイルタイプ別ローカル設定 {{{1
" " " setlocal foldmethod=syntax " ← set syntax=sh 相当になるので、それに伴い設定が変えられる
" " setlocal keywordprg=:Man\ <C-R>w " vim-lsp の <Plug>(lsp-hover) を使うので不要
