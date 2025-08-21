vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
b:did_ftplugin_user_after = 1

#ファイルタイプ別のグローバル設定 {{{1
if !exists('g:vim_plugin_after')
	g:vim_plugin_after = 1
	augroup VimSetPack
		autocmd!
		# $MYVIMDIR/pack/ の設定 {{{
		autocmd BufRead *.vim nnoremap <buffer><silent>gf :TabEdit <C-R><C-P><CR>
		# }}}
	augroup END
endif

setlocal formatoptions-=c textwidth=0 iskeyword-=# iskeyword+=? # デフォルト設定から好みに変更
# ? は is?, isnot? の syntax highlight を効かせるため
# setlocal keywordprg=:VimHelp

# $MYVIMDIR/pack/ のファイルタイプ別ローカル設定 {{{1
nnoremap <buffer><silent>gf :TabEdit <C-R><C-P><CR>
