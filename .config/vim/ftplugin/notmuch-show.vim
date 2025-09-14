vim9script
scriptencoding utf-8
# ファイルタイプ別のグローバル設定 {{{1
# if !exists('g:notmuch_show_plugin')
# 	g:notmuch_show_plugin = 1
# endif

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
# キーマップ {{{2
# nnoremap <buffer><silent><Leader>s :Notmuch mail-send<CR>
# に割り当てられているのが notmuch-show は Google 検索に割当し直し
nnoremap <buffer><silent><Leader>s <Cmd>call set_google_search#main() <Bar> delfunction set_google_search#main<CR>
xnoremap <buffer><silent><Leader>s <Cmd>call set_google_search#main() <Bar> delfunction set_google_search#main<CR>
# set {{{2
# setlocal keywordprg=:call\ set_eblook#searchWord()
setlocal tabstop=8
setlocal nolinebreak
# :NoMatchParen " 対応するカッコの ON/OFF {{{2
autocmd MatchParen WinLeave,TabLeave,BufWinLeave <buffer> execute('DoMatchParen')
autocmd MatchParen WinEnter,TabEnter,BufWinEnter <buffer> execute('NoMatchParen')
# Blink ON/OFF {{{2
if has('gui_running')
	autocmd NotmuchFileType CmdlineLeave,CmdwinLeave <buffer> vimrc#BlinkIdleTimer(
				\ () => hlset(g:hi_cursor),
				\ () => hlset([{name: 'Cursor', cleared: true}]))
	autocmd NotmuchFileType CursorMoved <buffer> vimrc#BlinkIdleTimerCheckPOS(
				\ () => hlset(g:hi_cursor),
				\ () => hlset([{name: 'Cursor', cleared: true}]))
	autocmd NotmuchFileType CmdlineEnter,CmdwinEnter <buffer> hlset(g:hi_cursor)
	# autocmd NotmuchFileType VimLeave <buffer> hlset(g:hi_cursor) | vimrc#BlinkTimerStop()
	autocmd NotmuchFileType WinLeave,TabLeave <buffer> hlset(g:hi_cursor) | vimrc#BlinkTimerStop()
	autocmd NotmuchFileType WinEnter,TabEnter <buffer> hlset(g:hi_cursor) | vimrc#BlinkTimerStop()
else
	autocmd NotmuchFileType CmdlineLeave,CmdwinLeave <buffer> vimrc#BlinkIdleTimer(
				\ () => writefile(["\e[1 q"], '/dev/tty', 'b'),
				\ () => writefile(["\e[6 q"], '/dev/tty', 'b'))
	autocmd NotmuchFileType CursorMoved <buffer> vimrc#BlinkIdleTimerCheckPOS(
				\ () => writefile(["\e[1 q"], '/dev/tty', 'b'),
				\ () => writefile(["\e[6 q"], '/dev/tty', 'b'))
	autocmd NotmuchFileType CmdlineEnter,CmdwinEnter <buffer> writefile(["\e[1 q"], '/dev/tty', 'b')
	autocmd NotmuchFileType VimLeave <buffer> writefile(["\e[1 q"], '/dev/tty', 'b')
	autocmd NotmuchFileType WinLeave,TabLeave <buffer> writefile(["\e[1 q"], '/dev/tty', 'b') | vimrc#BlinkTimerStop()
	autocmd NotmuchFileType WinEnter,TabEnter <buffer> writefile(["\e[1 q"], '/dev/tty', 'b') | vimrc#BlinkTimerStop()
endif
autocmd NotmuchFileType ColorScheme <buffer> g:hi_cursor = hlget('Cursor', true)

# }}}1
