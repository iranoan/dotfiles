vim9script
# :TabEdit
# 指定されたバッファ/ファイルがあればそれをアクティブにし、無ければ開く
# 複数指定では、最初に見つかった分をアクティブに
# mimetype が text/* でない、圧縮ファイル (zip, tar.*) でもないときは関連付けで開く

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
				var app: string = systemlist('file --brief --mime-type "' .. subsubf .. '"')[0]
				if app[0 : 4] ==# 'text/'
						|| app =~# '^application/xhtml+xml$'
						|| app =~# '^image/svg+xml$'
						|| app =~# '^application/\(x-\)\?zip$'
						|| app =~# '^application/\(x-\)\?xz$'
						|| app =~# '^application/\(x-\)\?tar$'
						|| app =~# '^application/\(x-\)\?gzip$'
						|| app =~# '^application/\(x-\)\?bz2-compressed$'
					execute 'silent ' .. cmd .. ' ' .. subsubf
					return
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

		def OpenBuffer(subf: string): bool # バッファ番号の可能性を探り有れば開く
			var n: number = str2nr(subf)
			if n .. '' !=# subf || strlen(n .. '') != strlen(subf)  # 値/文字列としての幅のどちらか違うので数字ではない→バッファ場号の可能性なし
				return false
			endif
			for v in getbufinfo()
				if v.bufnr == n  # バッファ番号が見つかった
					if GotoWin(v.windows)
						return true
					endif
					# バッファは有ったが hidden
					execute 'silent tab sbuffer ' .. subf
					win_id = win_id ? win_id : winnr()
					return true
				endif
			endfor
			return false
		enddef

		var full: string = ToFullpath(f, pwd)
		var ftype: string = getftype(full)
		if ftype ==# 'file' || ftype ==# 'link'  # ファイルが存在するなら無条件で開く
			OpenFile(full)
		elseif ftype ==# 'dir'  # ディレクトリなら Fern で開く
			if has_key(pack_manage#GetPackLs(), 'fern.vim')
				execute 'tabedit | Fern ' .. full
			else
				AssociateCore(full)
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
		var fs: string = glob(files)
		if fs ==# ''
			Open(files, pwd)
		else
			for f in split(fs)
				Open(f, pwd)
			endfor
		endif
	endfor
	win_gotoid(win_id)
	redraw  # これが無いとタグが切り替わったように見えない
enddef
