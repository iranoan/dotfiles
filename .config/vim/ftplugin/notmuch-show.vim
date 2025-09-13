vim9script
scriptencoding utf-8
# ファイルタイプ別のグローバル設定 {{{1
if !exists('g:notmuch_show_plugin')
	g:notmuch_show_plugin = 1
	g:hi_cursor = hlget('Cursor', true)
	augroup Notmuch_Show # 対応するカッコの ON/OFF
		autocmd!
		autocmd WinLeave,TabLeave * if index(['notmuch-folders', 'notmuch-thread', 'notmuch-show'], &filetype) != -1
					\ | call execute('DoMatchParen') | endif
		autocmd WinEnter * if index(['notmuch-folders', 'notmuch-thread', 'notmuch-show'], &filetype) != -1 && getcmdwintype() ==# ''
					\ | execute 'NoMatchParen' | endif
		autocmd BufWinEnter * if index(['notmuch-folders', 'notmuch-thread', 'notmuch-show', 'qf'], &filetype) == -1 && getcmdwintype() ==# ''
					\ | execute 'DoMatchParen' | endif # ←同一条件 grep でエラー
		autocmd ColorScheme * g:hi_cursor = hlget('Cursor', true)
	augroup END
endif

# Blink ON/OFF を環境全体に使うなら {{{1
# augroup CursorBlinkControl
# 	autocmd!
# 	if has('gui_running')
# 		autocmd VimEnter,InsertLeave,CmdlineLeave,CmdwinLeave * vimrc#BlinkIdleTimer(
# 					\ () => hlset(hi_cursor),
# 					\ () => hlset([{name: 'Cursor', cleared: true}]))
# 		autocmd CursorMoved * vimrc#BlinkIdleTimerCheckPOS(
# 					\ () => hlset(hi_cursor),
# 					\ () => hlset([{name: 'Cursor', cleared: true}]))
# 		autocmd InsertEnter,CmdlineEnter,CmdwinEnter * hlset(hi_cursor)
# 		autocmd VimLeave * hlset(hi_cursor)
# 	else
# 		autocmd VimEnter,InsertLeave,CmdlineLeave,CmdwinLeave * vimrc#BlinkIdleTimer(
# 					\ () => writefile(["\e[1 q"], '/dev/tty', 'b'),
# 					\ () => writefile(["\e[6 q"], '/dev/tty', 'b'))
# 		autocmd CursorMoved * vimrc#BlinkIdleTimerCheckPOS(
# 					\ () => writefile(["\e[1 q"], '/dev/tty', 'b'),
# 					\ () => writefile(["\e[6 q"], '/dev/tty', 'b'))
# 		autocmd InsertEnter,CmdlineEnter,CmdwinEnter * writefile(["\e[1 q"], '/dev/tty', 'b')
# 		autocmd VimLeave * writefile(["\e[1 q"], '/dev/tty', 'b')
# 	endif
# 	autocmd ColorScheme * hi_cursor = hlget('Cursor', true)
# augroup END

# ファイルタイプ別ローカル設定 {{{1
# nnoremap <buffer><silent><Leader>s :Notmuch mail-send<CR>
# に割り当てられているのが notmuch-show は Google 検索に割当し直し
nnoremap <buffer><silent><Leader>s <Cmd>call set_google_search#main() <Bar> delfunction set_google_search#main<CR>
xnoremap <buffer><silent><Leader>s <Cmd>call set_google_search#main() <Bar> delfunction set_google_search#main<CR>
# setlocal keywordprg=:call\ set_eblook#searchWord()
setlocal tabstop=8
setlocal nolinebreak
# :NoMatchParen " 対応するカッコの ON/OFF
# Blink ON/OFF {{{2
if has('gui_running')
	autocmd Notmuch_Show CmdlineLeave,CmdwinLeave <buffer> vimrc#BlinkIdleTimer(
				\ () => hlset(g:hi_cursor),
				\ () => hlset([{name: 'Cursor', cleared: true}]))
	autocmd Notmuch_Show CursorMoved <buffer> vimrc#BlinkIdleTimerCheckPOS(
				\ () => hlset(g:hi_cursor),
				\ () => hlset([{name: 'Cursor', cleared: true}]))
	autocmd CmdlineEnter,CmdwinEnter <buffer> hlset(g:hi_cursor)
	autocmd Notmuch_Show VimLeave <buffer> hlset([{name: 'Cursor', cleared: true}])
	# autocmd Notmuch_Show WinEnter <buffer> hlset([{name: 'Cursor', cleared: true}]) | vimrc#BlinkStop() # このあと CursorMove が働くので意味をなさない
	autocmd Notmuch_Show WinLeave <buffer> hlset(g:hi_cursor) | vimrc#BlinkStop()
else
	autocmd Notmuch_Show CmdlineLeave,CmdwinLeave <buffer> vimrc#BlinkIdleTimer(
				\ () => writefile(["\e[1 q"], '/dev/tty', 'b'),
				\ () => writefile(["\e[6 q"], '/dev/tty', 'b'))
	autocmd Notmuch_Show CursorMoved <buffer> vimrc#BlinkIdleTimerCheckPOS(
				\ () => writefile(["\e[1 q"], '/dev/tty', 'b'),
				\ () => writefile(["\e[6 q"], '/dev/tty', 'b'))
	autocmd Notmuch_Show CmdlineEnter,CmdwinEnter <buffer> writefile(["\e[1 q"], '/dev/tty', 'b')
	autocmd Notmuch_Show VimLeave <buffer> writefile(["\e[1 q"], '/dev/tty', 'b')
	# autocmd Notmuch_Show WinEnter <buffer> writefile(["\e[1 q"], '/dev/tty', 'b') # このあと CursorMove が働くので意味をなさない
	autocmd Notmuch_Show WinLeave <buffer> writefile(["\e[1 q"], '/dev/tty', 'b') | vimrc#BlinkStop()
endif
autocmd Notmuch_Show ColorScheme <buffer> g:hi_cursor = hlget('Cursor', true)

# }}}1
