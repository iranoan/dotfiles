vim9script
# sh 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
b:did_ftplugin_user = 1

#ファイルタイプ別のグローバル設定 {{{1
# if !exists('g:sh_plugin')
# 	g:sh_plugin = 1
# endif

# ファイルタイプ別ローカル設定 {{{1
setlocal keywordprg=:Man
