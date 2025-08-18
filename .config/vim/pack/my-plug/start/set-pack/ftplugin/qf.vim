vim9script
# $MYVIMDIR/pack/ で管理している Vim 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_setpack')
	finish
endif
b:did_ftplugin_setpack = 1

#ファイルタイプ別のグローバル設定 {{{1
if !exists("g:qf_plugin_setpack")
	g:qf_plugin_setpack = 1
	augroup QfSetPack
		autocmd!
		autocmd BufRead * if &buftype ==# 'quickfix' | call gnu_grep#SetQfTitle() | endif
		autocmd QuickFixCmdPost * call gnu_grep#SetQfTitle()
	augroup END
endif

# ファイルタイプ別ローカル設定 {{{1
gnu_grep#SetQfTitle()
