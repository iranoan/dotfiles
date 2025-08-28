vim9script
scriptencoding utf-8
# Vim スクリプト用の設定
if exists('b:did_ftplugin_user')
	finish
endif
b:did_ftplugin_user = 1

# ファイルタイプ別のグローバル設定 {{{1
if !exists('g:vim_plugin')
	g:vim_plugin = 1

	augroup myVIM
		autocmd!
		autocmd CursorMoved,InsertLeave * if &filetype ==# 'vim' | call ftplugin#vim#ChangeVim9VimL() | endif
	augroup END
endif

# ファイルタイプ別のローカル設定 {{{1
# b:isVim9script = getline(1) =~# '^\s*vim9script\>'
ftplugin#vim#ChangeVim9VimL()
setlocal spelloptions=camel
nnoremap <silent><buffer>K <ScriptCmd>call ftplugin#vim#VimHelp()<CR>

# Undo {{{1
if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= ' | call undo_ftplugin#Reset("vim")'
else
	b:undo_ftplugin = 'call undo_ftplugin#Reset("vim")'
endif
