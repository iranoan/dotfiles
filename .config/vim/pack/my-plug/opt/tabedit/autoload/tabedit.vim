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
				win_id = win_id ? win_id : w
				return true
			endif
		endfor
		# 他のタブも含めて開いているか?
		for w in windows
			win_id = win_id ? win_id : w
			return true
		endfor
		return false
	enddef

	def Open(f: any, pwd: string): void  # f (バッファ番号、もしくはファイル名) を開く
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
					win_id = win_id ? win_id : winnr()
					return true
				endfor
				return false
			enddef

			def Associate(cmd: string, subsubf: string): void # mimetype が text/*, XML 圧縮ファイルでないときは関連付けで開く
				var mime: string = systemlist('file --mime-type --brief ''' .. substitute(subsubf, "'", '''\\''''', 'g') .. '''')[0]
				if index(['application/xhtml+xml', 'image/svg+xml', 'application/json', 'application/x-awk', 'application/x-shellscript', 'application/x-desktop'], mime) != -1
						|| mime[0 : 4] ==# 'text/'
						|| mime =~# '^application/\(x-\)\?zip$'
						|| mime =~# '^application/\(x-\)\?xz$'
						|| mime =~# '^application/\(x-\)\?tar$'
						|| mime =~# '^application/\(x-\)\?gzip$'
						|| mime =~# '^application/\(x-\)\?bz2-compressed$'
						|| index(['aux', 'bash', 'bat', 'bib', 'c', 'cfg', 'cls', 'cpp', 'css', 'csv', 'desktop', 'go', 'h', 'htm', 'html', 'idx', 'ilg', 'ind', 'java', 'json', 'log', 'lua', 'mac', 'plt', 'py', 'rb', 'sh', 'sty', 'tex', 'toc', 'tsv', 'txt', 'vim', 'xhtml', 'yaml', 'yml', 'zsh'], split(subsubf, '/')[-1]->split('\.')[-1] ) != -1 # mimetype で誤判定が有るので、特定の拡張子は Vim で開く
					execute 'silent ' .. cmd .. ' ' .. subsubf
					return
				elseif has('unix') # 関連付けで判定
					var app: list<string> = systemlist('xdg-mime query default ' .. mime)
					if app == [] # 関連付けられたアプリがない
						execute 'silent ' .. cmd .. ' ' .. subsubf
						return
					endif
					mime = systemlist('xdg-mime query default ' .. mime)[0]
					for p in [$HOME .. '/.local/share/applications/', '/usr/local/share/applications/', '/usr/share/applications/' ]
						app = readfile(p .. mime)->filter( (_, v ) => v =~? '^TryExec=' )
						if app != []
							mime = app[0][8 : ]
							break
						endif
					endfor
					if mime =~? '^g\?vim$'
						execute 'silent ' .. cmd .. ' ' .. subsubf
						return
					endif
				endif
				AssociateCore(subsubf)
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
			win_id = win_id ? win_id : winnr()
		enddef

		def ToFullpath(subf: string, dir: string): string # フルパスに変換
			# 単純に full = fnamemodify(subf, ':p') だと、複数ファイルを開くときに先に開いたファイルに左右される
			if has('win32') || has('win32unix')
				if match(subf, '^\w:') == 0
					return subf
				endif
				return dir .. '/' .. subf
			else
				if match(subf, '^/') == 0
					return subf
				endif
				if match(subf, '^\~/') == 0
					return getenv('HOME') .. strpart(subf, 1)
				else
					return dir .. '/' .. subf
				endif
			endif
		enddef

		var full: string = ToFullpath(f, pwd)
		var ftype: string = getftype(full)
		if ftype ==# 'file' || ftype ==# 'link'  # ファイルが存在するなら無条件で開く
			OpenFile(full)
		elseif ftype ==# 'dir'  # ディレクトリなら Fern で開く
			var cmd: list<any> = get(g:, 'tabedit_dir', [])
			if cmd == []
				AssociateCore(full)
			else
				if cmd[1]
					var Func = function(cmd[0], [full])
					Func()
				else
					execute cmd[0] .. ' ' .. full
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
	var pwd: string = getcwd()
	for files in arg
		var fs: list<string> = glob(files, true, true, true)
		if fs ==# [] # 存在しないファイル
			Open(files, pwd)
		else
			for f in fs
				Open(f, pwd)
			endfor
		endif
	endfor
	win_gotoid(win_id)
	redraw  # これが無いとタグが切り替わったように見えない
enddef
defcompile
