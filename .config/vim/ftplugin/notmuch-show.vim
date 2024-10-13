vim9script
scriptencoding=utf-8
# ファイルタイプ別のグローバル設定 {{{1
if !exists('g:notmuch_show_plugin')
	g:notmuch_show_plugin = 1
	augroup Notmuch_Show # 対応するカッコの ON/OFF
		autocmd!
		autocmd WinLeave,TabLeave * if index(['notmuch-folders', 'notmuch-thread', 'notmuch-show'], &filetype) != -1
					\ | call execute('DoMatchParen') | endif
		autocmd WinEnter * if index(['notmuch-folders', 'notmuch-thread', 'notmuch-show'], &filetype) != -1 && getcmdwintype() ==# ''
					\ | execute 'NoMatchParen' | endif
		autocmd BufWinEnter * if index(['notmuch-folders', 'notmuch-thread', 'notmuch-show', 'qf'], &filetype) == -1 && getcmdwintype() ==# ''
					\ | execute 'DoMatchParen' | endif # ←同一条件 grep でエラー
	augroup END
endif

# ファイルタイプ別ローカル設定 {{{1 {{{1
# nnoremap <buffer><silent><Leader>s :Notmuch mail-send<CR>
# に割り当てられているのが notmuch-show は Google 検索に割当し直し
nnoremap <buffer><silent><Leader>s :SearchByGoogle<CR>
xnoremap <buffer><silent><Leader>s :SearchByGoogle<CR>
# setlocal keywordprg=:call\ set_eblook#searchWord()
setlocal tabstop=8
setlocal nolinebreak
# :NoMatchParen " 対応するカッコの ON/OFF
# 1}}}

# Undo {{{1
if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| setlocal linebreak< tabstop<'
else
	b:undo_ftplugin = 'setlocal linebreak< tabstop<'
endif
