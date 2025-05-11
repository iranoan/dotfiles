vim9script
# QuickFix 用の設定
scriptencoding utf-8

if exists('b:did_ftplugin_user')
	finish
endif
b:did_ftplugin_user = 1

# ファイルタイプ別のグローバル設定 {{{1
if !exists("g:qf_disable_statusline") # :help qf.vim にある statusline を変更するフラグをグローバル設定のフラグに流用
	g:qf_disable_statusline = 1
	augroup QuickFix
		autocmd!
		autocmd WinEnter *
					\ if winnr('$') == 1 && getbufvar(winbufnr(0), '&buftype') == 'quickfix'
					| 	if tabpagenr('$') == 1
					| 		quit
					| 	else
					| 		qfwin = bufnr('')
					| 		:normal! gt
					| 		execute 'bwipeout ' .. qfwin
					| 	endif
					| endif # QuickFix だけなら閉じる
	augroup END
endif

# ファイルタイプ別のローカル設定 {{{1
setlocal signcolumn=auto foldcolumn=0
nnoremap <buffer><nowait><silent>q <CMD>bwipeout!<CR>
nnoremap <buffer><C-O> <CMD>colder<CR>
nnoremap <buffer><C-I> <CMD>cnewer<CR>
