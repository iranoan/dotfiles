vim9script
# AWK 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
b:did_ftplugin_user = 1

#ファイルタイプ別のグローバル設定 {{{1
# if !exists('g:awk_plugin')
# 	g:awk_plugin = 1
# endif

# ファイルタイプ別ローカル設定 {{{1
setlocal cindent autoindent smartindent
setlocal foldmethod=expr foldexpr=awk#fold#Level()
setlocal errorformat=awk:\ %f:%l:\ %m,gawk:\ %f:%l:\ %m,mawk:\ %f:%l:\ %m
setlocal makeprg=awk\ -f\ %\ % # 編集中のファイル自身を処理させる

# Undo {{{1
if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= ' | call undo_ftplugin#Reset("awk")'
else
	b:undo_ftplugin = 'call undo_ftplugin#Reset("awk")'
endif
