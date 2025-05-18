vim9script
scriptencoding utf-8
# b:undo_ftplugin 関数

export def Reset(ft: string): void
	if &filetype ==# ft
		unlet! b:did_ftplugin_user_after
		# ↑がなく直ちに終わらせると b:undo_ftplugin に
		# setloval {option}<
		# があると、$MYVIMDIR/after/ftplugin の設定も元に戻される
		return
	endif
	# 規定と違う setlocl をリセット
	execute 'setlocal '
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
