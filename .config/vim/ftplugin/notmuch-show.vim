vim9script
scriptencoding utf-8
# ファイルタイプ別のグローバル設定 {{{1
if !exists('g:notmuch_show_plugin')
	g:notmuch_show_plugin = 1
	g:hi_cursor = hlget('Cursor', true)
	augroup CursorBlinkControl # 対応するカッコの ON/OFF ← グループの作成だけしておく
		autocmd!
		autocmd ColorScheme * g:hi_cursor = hlget('Cursor', true)
	augroup END
endif

# ファイルタイプ別ローカル設定 {{{1
# キーマップ {{{2
# nnoremap <buffer><silent><Leader>s :Notmuch mail-send<CR>
# に割り当てられているのが notmuch-show は Google 検索に割当し直し
nnoremap <buffer><silent><Leader>s <Cmd>call set_web_search#main('SearchByGoogle')<CR>
xnoremap <buffer><silent><Leader>s <Cmd>call set_web_search#main('SearchByGoogle')<CR>
# set {{{2
# setlocal keywordprg=:call\ set_eblook#searchWord()
setlocal tabstop=8
setlocal nolinebreak
setlocal nocursorline nocursorcolumn
# :NoMatchParen " 対応するカッコの ON/OFF {{{2
autocmd MatchParen WinLeave,TabLeave,BufWinLeave <buffer> execute('DoMatchParen')
autocmd MatchParen WinEnter,TabEnter,BufWinEnter <buffer> execute('NoMatchParen')
# Blink ON/OFF {{{2
# if has('gui_running')
# 	autocmd CursorBlinkControl CmdlineLeave,CmdwinLeave <buffer> vimrc#BlinkIdleTimer(
# 				\ () => hlset(g:hi_cursor),
# 				\ () => hlset([{name: 'Cursor', cleared: true}]))
# 	autocmd CursorBlinkControl CursorMoved <buffer> vimrc#BlinkIdleTimerCheckPOS(
# 				\ () => hlset(g:hi_cursor),
# 				\ () => hlset([{name: 'Cursor', cleared: true}]))
# 	autocmd CursorBlinkControl CmdlineEnter,CmdwinEnter <buffer> vimrc#BlinkTimerStop(() => hlset(g:hi_cursor))
# 	# autocmd CursorBlinkControl VimLeave <buffer> vimrc#BlinkTimerStop(() => hlset(g:hi_cursor))
# 	autocmd CursorBlinkControl WinLeave,TabLeave,BufWinLeave <buffer> vimrc#BlinkTimerStop(() => hlset(g:hi_cursor))
# 	# ↑が期待の動作にならない↓ (<buffer> と同じくカーソル点滅が OFF になる)
# 	autocmd CursorBlinkControl WinEnter * vimrc#BlinkTimerStop(() => hlset(g:hi_cursor))
# else
# 	autocmd CursorBlinkControl CmdlineLeave,CmdwinLeave <buffer> vimrc#BlinkIdleTimer(
# 				\ () => writefile(["\e[1 q"], '/dev/tty', 'b'),
# 				\ () => writefile(["\e[6 q"], '/dev/tty', 'b'))
# 	autocmd CursorBlinkControl CursorMoved <buffer> vimrc#BlinkIdleTimerCheckPOS(
# 				\ () => writefile(["\e[1 q"], '/dev/tty', 'b'),
# 				\ () => writefile(["\e[6 q"], '/dev/tty', 'b'))
# 	autocmd CursorBlinkControl CmdlineEnter,CmdwinEnter <buffer> vimrc#BlinkTimerStop(() => writefile(["\e[1 q"], '/dev/tty', 'b'))
# 	autocmd CursorBlinkControl VimLeave <buffer> writefile(["\e[1 q"], '/dev/tty', 'b')
# 	autocmd CursorBlinkControl WinLeave,TabLeave,BufWinLeave <buffer> vimrc#BlinkTimerStop(() => writefile(["\e[1 q"], '/dev/tty', 'b'))
# 	# ↑が期待の動作にならない↓ (<buffer> と同じくカーソル点滅が OFF になる)
# 	autocmd CursorBlinkControl WinEnter * vimrc#BlinkTimerStop(() => writefile(["\e[1 q"], '/dev/tty', 'b'))
# endif
# }}}2
# }}}1
