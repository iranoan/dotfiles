vim9script

export def IsTextFile(f: string): bool
	if !has('unix')
		return false
	endif
	var mime: string = systemlist('file --mime-type --brief ''' .. substitute(resolve(f), "'", '''\\''''', 'g') .. '''')[0]
	if mime ==# 'text/plain'
		mime = systemlist('mimetype --brief ''' .. substitute(resolve(f), "'", '''\\''''', 'g') .. '''')[0]
	endif
	if index(['application/xhtml+xml', 'image/svg+xml', 'application/json'], mime) != -1
		return true
	elseif mime =~# '^text/'
			|| mime =~# '^[A-Za-z_-]\+/[A-Za-z_-]\++xml$'
		return true
	elseif mime =~# '^application/\(x-\)\=zip$'
		unlet! g:loaded_zip g:loaded_zipPlugin
		source $VIMRUNTIME/plugin/zipPlugin.vim
		return true
	elseif mime =~# '^application/\(x-\)\=\(xz\|tar\|gzip\|bz2-compressed\)$'
		unlet! g:loaded_tar g:loaded_tarPlugin g:loaded_gzip
		source $VIMRUNTIME/plugin/tarPlugin.vim
		source $VIMRUNTIME/plugin/gzip.vim
		return true
	elseif mime ==# 'application/x-pie-executable'
		return false
	endif
	# 関連付けで判定
	var app: list<string> = systemlist('xdg-mime query default ' .. mime)
	if app == [] # 関連付けられたアプリがない
		return true
	endif
	mime = app[0]
	for p in [$HOME .. '/.local/share/applications/', '/usr/local/share/applications/', '/usr/share/applications/']
		if filereadable(p .. mime)
			if index(readfile(p .. mime)
					->filter((_, v) => v =~? '^Categories')
					->map((_, v) => substitute(v, '^Categories=', '', '')
						->split(';'))
					->flattennew(),
					'TextEditor', 0, true) != -1
				return true
			endif
			break
		endif
	endfor
	return false
enddef

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
		def AssociateCore(subf: string): void
			if has('unix')
				system('xdg-open "' .. subf .. '" &')
			elseif has('win32') || has('win32unix')
				system('start "' .. subf .. '"')
			elseif has('mac')
				system('open "' .. subf .. '" &')
			endif
		enddef

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
				if tabedit#IsTextFile(subsubf)
					execute 'silent ' .. cmd .. ' ' .. subsubf
				else
					AssociateCore(subsubf)
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
				AssociateCore(f)
			else
				if cmd[1]
					call(function(cmd[0], [f]), [])
				else
					execute cmd[0] .. ' ' .. f
				endif
			endif
		else
			if wordcount().bytes == 0 && &modified == false && len(tabpagebuflist()) == 1
				execute 'silent edit ' .. f
			else
				execute 'silent tabedit ' .. f
			endif
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
