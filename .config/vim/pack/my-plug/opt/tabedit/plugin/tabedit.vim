vim9script
scriptencoding utf-8
# Author:  Iranoan <iranoan+vim@gmail.com>
# License: GPL Ver.3.
# :TabEdit
# 指定されたバッファ/ファイルがあればそれをアクティブにし、無ければ開く
# 複数指定では、最初に見つかった分をアクティブに

if exists('g:loaded_tabedit')
	finish
endif

command! -nargs=* -complete=customlist,tabedit#CompFile TabEdit call tabedit#Tabedit(<f-args>)
