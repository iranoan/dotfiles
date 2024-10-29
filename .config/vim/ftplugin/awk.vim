" AWK 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

"ファイルタイプ別のグローバル設定 {{{1
" if !exists("g:c_plugin")
" 	let g:c_plugin = 1
" endif

" ファイルタイプ別ローカル設定 {{{1
setlocal cindent smartindent
setlocal foldmethod=indent
setlocal errorformat=awk:\ %f:%l:\ %m,gawk:\ %f:%l:\ %m,mawk:\ %f:%l:\ %m
setlocal makeprg=mawk\ -f\ %\ % " 編集中のファイル自身を処理させる
