vim9script

export def Tabedit(...arg: list<string>): void
	var win_id: number = 0  # 終了後最初に見つかった/開いたアクティブにする候補の初期値 (有り得ない 0 としておく)
	def GotoWin(windows: list<number>): bool  # windows[] をアクティブ候補に
		if windows == []
			return false
		endif
		var tabnr: number = tabpagenr()
		# 現在のタブに有るか?
		for w in windows
			if win_id2tabwin(w)[0] == tabnr
				win_id = win_id != 0 ? win_id : w
				return true
			endif
		endfor
		# 他のタブも含めて開いているか?
		for w in windows
			win_id = win_id != 0 ? win_id : w
			return true
		endfor
		return false
	enddef

	def Open(f: any): void
		def OpenFile(subf: string): void  # ファイル subf を開く
			def SubOpenFile(subsubf: string): bool # 既に開いていれば移動、もしくは閉じたバッファを開き直す
				for v in getbufinfo()
					if subsubf != v.name
						continue
					endif
					if GotoWin(v.windows)
						return true
					endif
					execute 'silent tab sbuffer ' .. v.bufnr
					win_id = win_id != 0 ? win_id : winnr()
					return true
				endfor
				return false
			enddef

			def Associate(cmd: string, subsubf: string): void
				if general_function#IsBinary(subsubf)
					dist#vim9#Open(subsubf)
				else
					execute 'silent ' .. cmd .. ' ' .. subsubf
				endif
			enddef

			if SubOpenFile(subf)
				return
			endif
			if getftype(subf) ==# 'link' && SubOpenFile(resolve(subf))
				return
			endif
			if wordcount().bytes == 0 && &modified == false && len(tabpagebuflist()) == 1
				Associate('edit', subf)
			else
				Associate('tabedit', subf)
			endif
			win_id = win_id != 0 ? win_id : winnr()
		enddef

		var ftype: string = getftype(f)
		if ftype ==# 'file' || ftype ==# 'link'  # ファイルが存在するなら無条件で開く
			OpenFile(f)
		elseif ftype ==# 'dir'  # ディレクトリなら Fern で開く
			var cmd: list<any> = get(g:, 'tabedit_dir', [])
			if cmd == []
				dist#vim9#Open(f)
			else
				if cmd[1]
					call(function(cmd[0], [f]), [])
				else
					execute cmd[0] .. ' ' .. f
				endif
			endif
		elseif f =~# '^\(https\?\|ftp\|mailto\):\(//\)\?[a-zA-Z0-9._%+-]\+\%(:[0-9]\+\)\?\%(/[a-zA-Z0-9._%+-/?#&=~@!$''()*+,;:]*\)\?' # URL
			dist#vim9#Open(f)
		elseif wordcount().bytes == 0 && &modified == false && len(tabpagebuflist()) == 1 # 現在バッファ内容が空
			execute 'silent edit ' .. f
		else
			execute 'silent tabedit ' .. f
		endif
	enddef

	if arg == []
		tabedit
		return
	endif
	for f in mapnew(arg, (_, v) => expand(v, true, true))->flattennew(1)->map((_, v) => fnamemodify(v, ':p'))
		Open(f)
	endfor
	win_gotoid(win_id)
	redraw  # これが無いとタグが切り替わったように見えない
enddef

export def CompFile(arg: string, cmd: string, pos: number): list<string>
	# ファイル・パスの補完候補を返す
	# ただしカレント・ファイルは除外
	var c_f: string = expand('%:p')
	var args: string = matchstr(cmd[ : pos ], 'TabEdit\s\+\zs.*')
	if args =~# ' $' && args !~# '\\ $'
		args = ''
	elseif args !=# ''
		args = split(args, '[^\\]\zs ')[-1]
	endif
	var len_args: number = len(args)
	if args ==# '~'
		args ..= '/'
	endif
	var files: list<string> = getcompletion(expand(args->substitute('\\ ', ' ', 'g')), 'file')
	                          ->filter((_, v) => fnamemodify(v, ':p') !=# c_f)
	                          ->map((_, v) => substitute(v, ' ', '\\ ', ''))
	if args =~# '^\~/'
		map(files, (_, v) => substitute(v, $'^{$HOME}/', '\~/', ''))
	endif
	return files
enddef
