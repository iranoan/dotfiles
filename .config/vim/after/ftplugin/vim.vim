vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
b:did_ftplugin_user_after = 1

##ファイルタイプ別のグローバル設定 {{{1
#if !exists('g:vim_plugin_after')
#	g:vim_plugin_after = 1
#endif

setlocal formatoptions-=c textwidth=0 iskeyword-=# iskeyword+=? # デフォルト設定から好みに変更
# ? は is?, isnot? の syntax highlight を効かせるため

# $MYVIMDIR/pack/ のファイルタイプ別ローカル設定 {{{1
nnoremap <buffer><C-]>      <Cmd>call ftplugin#vim#Goto()<CR>
# $VIMRUNTIME/ftplugin/vim.vim で置き換えられるので
nnoremap <buffer><silent>gf :TabEdit <C-R><C-P><CR>

# Undo {{{1
if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= ' | call undo_ftplugin#Reset("vim")'
else
	b:undo_ftplugin = 'call undo_ftplugin#Reset("vim")'
endif
