vim9script
# ファイルタイプ別のグローバル設定 {{{1
# --------------------------------
if !exists('g:notmuch_show_plugin')
	g:notmuch_show_plugin = 1
	augroup Notmuch_Show # 対応するカッコの ON/OFF
		autocmd!
		autocmd WinLeave,TabLeave * if &filetype ==# 'notmuch-folders' || &filetype ==# 'notmuch-thread' || &filetype ==# 'notmuch-show'
					\ | call execute('DoMatchParen') | endif
		autocmd WinEnter * if &filetype ==# 'notmuch-folders' || &filetype ==# 'notmuch-thread' || &filetype ==# 'notmuch-show'
					\ | call execute('NoMatchParen') | endif
		autocmd BufWinEnter * if &filetype !=# 'notmuch-folders' && &filetype !=# 'notmuch-thread' && &filetype !=# 'notmuch-show'
					\ && &filetype !=# 'qf' # ←同一条件 grep でエラー
					\ | call execute('DoMatchParen') | endif
	augroup END
endif
# --------------------------------
# ファイルタイプ別ローカル設定 {{{1
# --------------------------------
# nnoremap <buffer><silent><Leader>s :Notmuch mail-send<CR>
# に割り当てられているのが notmuch-show は Google 検索に割当し直し
nnoremap <buffer><silent><Leader>s :SearchByGoogle<CR>
xnoremap <buffer><silent><Leader>s :SearchByGoogle<CR>
# setlocal keywordprg=:call\ set_eblook#searchWord()
setlocal tabstop=8
setlocal nolinebreak
# :NoMatchParen " 対応するカッコの ON/OFF
# 1}}}
