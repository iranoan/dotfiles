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
	gnu_grep#SetQfTitle() # 2度めからは autocmd
	augroup QuickFix
		autocmd!
		autocmd WinEnter *
					\ if winnr('$') == 1 && getbufvar(winbufnr(0), '&buftype') == 'quickfix'
					| 	if tabpagenr('$') == 1
					| 		quit
					| 	else
					| 		var qfwin: number = bufnr('')
					| 		tabnext
					| 		execute 'bwipeout ' .. qfwin
					| 	endif
					| endif # QuickFix だけなら閉じる
		# ↑複数のタブ・ページがあり、複数回 :grep したときなどでエラーになるが、改善方法不明
		# $MYVIMDIR/pack/ のファイルタイプ別グローバル設定 {{{2
		autocmd QuickFixCmdPost * gnu_grep#SetQfTitle()
	augroup END
endif

# ファイルタイプ別のローカル設定 {{{1
setlocal signcolumn=auto foldcolumn=0
nnoremap <buffer><nowait><silent>q <CMD>bwipeout!<CR>
nnoremap <buffer><C-O> <CMD>colder<CR>
nnoremap <buffer><C-I> <CMD>cnewer<CR>
# :NoMatchParen " 対応するカッコの ON/OFF {{{2
# ↓qf を開いた状態で、grep するとエラーになる
# NoMatchParen
# autocmd MatchParen WinLeave,TabLeave,BufWinLeave <buffer> execute('DoMatchParen')
# autocmd MatchParen WinEnter,TabEnter,BufWinEnter <buffer> execute('NoMatchParen')
