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
	# 規定と違う setlocal をリセット
	var localset: list<string> = split(execute('setlocal!'), '\n')[1 : ]
				->map((_, v) => substitute(v, '^\(  \|--\)\(\w\+\)\(=.*\)\?', '\2', ''))
				->filter((_, v) => index([
					'foldlevel',                 # foldlevelは既定値が 0 なので全て折りたたまれてしまう
					'filetype',                  # filetype はリセットすると空になり再度リセットされる
					'fileformat', 'fileencoding' # fileformat, fileencoding は filetype の設定とは必ずしも関係しない+modified も変化する
				], v) == -1)
	if localset != []
		execute 'setlocal' join(localset, '< ') .. '<'
	endif
	mapclear <buffer>
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
enddef
