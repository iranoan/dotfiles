vim9script
scriptencoding utf-8
# b:undo_ftplugin に使う関数を纏めてある
#
# 同じファイルタイプに設定されたとき
# 	if &filetype ==# 'tex'
# 		return
# 	endif
# と直ちに終わらせると b:undo_ftplugin に
# setloval {option}<
# があると、$MYVIMDIR/after/ftplugin の設定も元に戻されるので
# unlet! b:did_ftplugin_user_after
# は行う必要がある

def Reset(): void
	# 規定と違う setlocl をリセット
	execute 'setlocal! '
				.. split(execute('setlocal!'), '\n')[1 : ]
				->map((_, v) => substitute(v, '^\(  \|--\)\(\w\+\)\(=.*\)\?', '\2', ''))
				->filter((_, v) => v !=# 'foldlevel') # foldlevelは既定値が 0 なので全て折りたたまれてしまう
				->join('< ')
				.. '<'
	# <buffer> ローカルの map 削除
	for m in split(execute('map <buffer>'), '\n')
				->filter((_, v) => v =~# '^[ cilnostvx] ')
				->map((_, v) => substitute(v, '^\([ cilnostvx]\)  \([^ ]\+\) .*', '\1unmap <buffer>\2', ''))
		execute m
	endfor
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
enddef

export def AWK(): void
	if &filetype ==# 'awk'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef

export def Sh(): void
	if &filetype ==# 'sh' || &filetype ==# 'bash'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef

export def HTML(): void # XHTML と共用
	if &filetype ==# 'html'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef

export def Vim(): void
	if &filetype ==# 'vim'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef

export def C(): void
	if &filetype ==# 'c'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef

export def CSS(): void
	if &filetype ==# 'css'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef

export def Gnuplot(): void
	if &filetype ==# 'gnuplot'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef

export def Help(): void
	if &filetype ==# 'help'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef

export def JSON(): void
	if &filetype ==# 'json'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef

export def Mail(): void
	if &filetype ==# 'mail' || &filetype ==# 'notmuch-draft'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef

export def Man(): void
	if &filetype ==# 'man'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef

export def Markdown(): void
	if &filetype ==# 'markdown'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef

export def MSMTP(): void
	if &filetype ==# 'msmtp'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef

export def Python(): void
	if &filetype ==# 'python'
		unlet! b:did_ftplugin_user_after
		return
	endif
	nunmap p
	Reset()
enddef

export def Qf(): void
	if &filetype ==# 'qf'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef

export def TeX(): void
	if &filetype ==# 'tex'
		unlet! b:did_ftplugin_user_after
		return
	endif
	Reset()
enddef
