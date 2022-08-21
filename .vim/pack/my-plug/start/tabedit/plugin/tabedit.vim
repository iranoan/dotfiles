" Author:  Iranoan <iranoan+vim@gmail.com>
" License: GPL Ver.3.
" :TabEdit
" 指定されたバッファ/ファイルがあればそれをアクティブにし、無ければ開く
" 複数指定では、最初に見つかった分をアクティブに

scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

if exists('g:loaded_tabedit')
	finish
endif

command! -nargs=* -complete=file TabEdit call tabedit#tabedit(<f-args>)

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
