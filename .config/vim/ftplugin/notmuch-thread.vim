vim9script
scriptencoding utf-8

# ファイルタイプ別のグローバル設定 {{{1
# if !exists('g:notmuch_thread_plugin')
# 	g:notmuch_thread_plugin = 1
# endif

# ファイルタイプ別ローカル設定 {{{1
# :NoMatchParen " 対応するカッコの ON/OFF {{{2
autocmd MatchParen WinLeave,TabLeave,BufWinLeave <buffer> execute('DoMatchParen')
autocmd MatchParen WinEnter,TabEnter,BufWinEnter <buffer> execute('NoMatchParen')
# Blink ON/OFF {{{2
# ↓CTRL-W_W などでウィンドウを移動すると、2度めのウィンドウでカーソルが消えるのを防ぐ (プラグインの関数内部でカレントウィンドウを切り替えないでカーソルを変える処理をしているため?)
# これだけにすると他のタブに移動した時に移動先もカーソルが消えたままになるので注意→notmuch-show 側で WinLeave がある
autocmd NotmuchFileType WinEnter,TabEnter <buffer> hlset(g:hi_cursor) | vimrc#BlinkTimerStop()
