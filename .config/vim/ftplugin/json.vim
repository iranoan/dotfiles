"JSON 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

" ファイルタイプ別のグローバル設定 {{{1
" if !exists("g:json_plugin")
" 	let g:json_plugin = 1
" 	"--------------------------------
" endif

" ファイルタイプ別ローカル設定 {{{1
" 以下単純な setlocal や <buffer> 付き
setlocal errorformat=parse\ %trror:\ %m\ at\ line\ %l\\,\ column\ %c
setlocal makeprg=jq\ --tab\ --monochrome-output\ .\ %
setlocal equalprg=jq\ --tab\ --monochrome-output\ '.'
setlocal commentstring=/*%s*/ " 本来は JSON にコメントはないが、.vimspectore.json 用
setlocal foldmethod=syntax

" Undo {{{1
if exists('b:undo_ftplugin')
	let b:undo_ftplugin ..= ' | call undo_ftplugin#Reset("json")'
else
	let b:undo_ftplugin = 'call undo_ftplugin#Reset("json")'
endif
