"Gnuplot 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

" ファイルタイプ別のグローバル設定 {{{1
" if !exists("g:gnuplot_plugin")
" 	let g:gnuplot_plugin = 1
" endif

" ファイルタイプ別ローカル設定 {{{1
setlocal commentstring=#%s
setlocal makeprg=gnuplot.sh\ %
setlocal errorformat=%E%p^,%C\"%f\"\\,\ line\ %l:\ %m
" タブ文字の幅の分だけズレてしまう+エラーの出力が gnuplot のスクリプトで、次行と連結する行末の \ を連結して表示するので、その分もズレてしまう欠点は残っている
"--------------------------------
"対応するカッコの入力
" inoremap <buffer> " ""<LEFT>
" inoremap <buffer> ' ''<LEFT>

" Undo {{{1
if exists('b:undo_ftplugin')
	let b:undo_ftplugin ..= ' | call undo_ftplugin#Reset("gnuplot")'
else
	let b:undo_ftplugin = 'call undo_ftplugin#Reset("gnuplot")'
endif
