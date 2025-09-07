vim9script

def RemoveFunction(ls: list<dict<any>>): list<dict<any>> # ペアの関数削除
	def RemoveRange(l: list<dict<any>>): dict<number> # 関数の最初と最後のペアを返す
		# function, endfunction, def, enddef は行頭 (空白文字は除く) にあるを前提
		# function ...  endfunction / def ...  enddef と対応していなくとも OK としている
		var range_s: number

		for [i, v] in items(l)
			if v.kind == 1
				range_s = i
			elseif v.kind == -1
				return {start: range_s, end: i}
			endif
		endfor
		return {start: 0, end: -1}
	enddef

	var rm_range: dict<number> # 関数の最初と最後のペアのインデックス
	while true
		rm_range = RemoveRange(ls)
		if rm_range.end == -1
			break
		endif
		remove(ls, rm_range.start, rm_range.end)
	endwhile
	return ls
enddef

def IsVim9(): bool
	var ls: list<dict<any>> = map(getline(1, '.'), (i, v) => ({lnum: i, text: v}))
		->filter((_, v) =>
			v.text =~# '^\s*\%(\%(export\s\+\)\=\%(def\|fu\%[nction]\)!\=\s\+\%([sg]:\|\%(\w\+#\)\+\)\=\w\+(\|enddef\>\|endf\%[unction]\>\)') # 関数でフィルタリング
		->map((_, v) => v->extend({kind:  # 行ごとの種類
			v.text =~# '^\s*\%(export\s\+\)\=\%(def\|fu\%[nction]\)!\=' # 関数始まり
				? 1
				: -1}))
		->RemoveFunction()

	if ls == []
		return getline(1) =~# '^\s*vim9script\>'
	elseif line('.') == ls[-1].lnum + 1
		if len(ls) > 1
			return ls[-2].text =~# '^\s*\%(export\s\+\)\=def!\='
		else
			return getline(1) =~# '^\s*vim9script\>'
		endif
	endif
	return ls[-1].text =~# '^\s*\%(export\s\+\)\=def!\='
enddef

export def ChangeVim9VimL(): void # vim9script/def/function によって適切な commentstring を設定し iskeyword+-=: を切り替える
	if line('.') == 1
		# 1行目にvim9script にあっても、コメント・アウトすると vimL になるので、「"」を使う必要がある"
		setlocal commentstring="%s
	elseif IsVim9()
		setlocal commentstring=#%s iskeyword-=: # vim9script では変数宣言 var hoge: type があるので、: を単語の一部とすると邪魔 (そのため b:var, g:var は一単語にならない)
	else
		setlocal commentstring="%s iskeyword+=: # vimL では変数宣言 s:func, a:arg, が多くあるので、: を単語の一部としたほうが都合が良い
	endif
enddef

export def VimHelp(): void
	def Help(s: string): void
		try
			execute('help ' .. s)
		catch /^Vim\%((\a\+)\)\=:E149:/ # 綴り違いで ( が付いているなどヘルプに見つからないので、先頭の ':、最後の ( を削除してもう一度試す
			try
				if s =~# '($'
					execute('help ' .. s[ : -2 ])
				elseif s =~# '^['':]'
					execute('help ' .. s[ 1 : ])
				else
					echohl ErrorMsg | echo 'Not find keyword: ' .. s | echohl None
				endif
			catch /^Vim\%((\a\+)\)\=:E149:/ # ヘルプが存在しない
				echohl ErrorMsg | echo 'Not find keyword: ' .. s | echohl None
			endtry
			return
		endtry
		return
	enddef

	var line: string = getline('.')
	var column: number = col('.')
	var i: number = 0
	var keyword: string # = expand('<cword>')
	var m_start: number
	var m_end: number
	var name: string

	# if mode(1) =~# '^c'
	# 	Help(tmp)
	# 	return
	# endif
	[keyword, m_start, m_end] = matchstrpos(line, '^\c\v\s*\zs[a-z0-9]+')
	if m_start != -1 && column <= m_end && column >= m_start # 行頭→コマンド
		Help(':' .. keyword)
		return
	endif
	while true
		[keyword, m_start, m_end] = matchstrpos(line, '\v((<[bgv]:|\&)?[a-z0-9_]+(\(|\s*\=)?|\<[-0-9a-z_]+\>)', i)
		if m_start == -1
			Help('' .. "\<C-r>\<C-w>")
			break
		elseif column <= m_end && column >= m_start
			if keyword =~# '^\v\<[-a-z]+\>$' # 特殊キー
				Help('' .. keyword)
			elseif keyword =~# '^(\<bar\>|\|)' # コマンド
				Help('' .. matchstr(keyword, '[a-z0-9_]\+$'))
			elseif keyword =~# '^&' || keyword =~# '=$' # オプション
				Help('''' .. matchstr(keyword, '[a-z0-9_]\+'))
			elseif keyword =~# '($' # 関数
				# syntax だけで行おうとすると、
				# inoremap <expr><C-P> pumvisible() ? '<C-P>' : '<C-R>"'
				# といったマップ中の関数はうまくいかない
				Help('' .. keyword)
			else # 上記以外は syntax を考慮する→関数以外は option-list とそれ以外を区別すれば良い
				name = synIDattr(synID(line('.'), col('.'), 1), 'name')
				if name ==# 'vimOption'
					Help('''' .. keyword)
				elseif index(['vimType', 'vimVar', 'vim9Var', 'vimAutoEvent', 'vimUserFunc', 'vimOper', 'vimString', 'vim9Comment', 'vimComment', 'vimFuncSID', 'vimDef', 'vimFunction', 'vimFuncName'], name) == -1 # リストに含まれないものはコマンド扱い
					Help(':' .. keyword)
				else
					Help(keyword)
				endif
			endif
			break
		endif
		i = m_end + 1
	endwhile
	return
enddef

export def Goto(): void # 関数や変数の定義場所に移動
	var bufinfo: list<any> = getbufinfo()

	def GotoPos(p: string, n: list<number>): bool
		var l_bufinf: list<any> = bufinfo->filter((_, v) => resolve(v.name) == resolve(p))

		if n == []
			return false
		endif
		if l_bufinf == [] # not open
			execute('tabedit ' .. p)
		else
			if l_bufinf[0].hidden || l_bufinf[0].linecount == 1 || !(l_bufinf[0].listed) # hide
				execute('tab sbuffer ' .. l_bufinf[0].bufnr)
			elseif index(l_bufinf[0].windows, win_getid()) == -1 # not current window
				win_gotoid(l_bufinf[0].windows[0])
			endif
		endif
		normal m'
		cursor(n)
		return true
	enddef

	def GotoPos2(l: list<dict<any>>, f: string): bool
		if len(l) == 0
			return false
		elseif len(l) > 1
			setloclist(0, [], 'r', {title: 'Multiple Find', items: l})
			lwindow
		else
			GotoPos(l[0].filename, [l[0].lnum, match(l[0].text, '\s*\%(def\|fu\%[nction]\)!\=\s\+\zs\(g:\)\=' .. f .. '(' ) + 1])
		endif
		return true
	enddef

	def SplitGrep(str: string): dict<any>
		var p: string
		var n: string
		var m: string
		var lst: list<string>

		lst = matchlist(str, '\([^:]\+\):\(\d\+\):\(.\+\)')
		if lst == []
			return {}
		endif
		[p, n, m] = lst[ 1 : 3 ]
		return {filename: p, lnum: str2nr(n), text: m}
	enddef

	def Func(s: string): void
		def IsGlobalScript(info: dict<any>, prefix: string): bool
			if info.text =~# '^\s*\%(export\s\+\)\=\%(def\|fu\%[nction]\)!\=\s\+' .. prefix # プレフィックス付き
				return true
			else # g:, s: プレフィックス付きでない→ローカルか? 調べる必要がある
				var lines: list<dict<any>> = map(has_key(info, 'n') ? getbufline(info.n, 1, info.lnum - 1) : readfile(info.filename, '', info.lnum - 1),
					(i, v) => ({lnum: i, text: v}))
				->filter((_, v) => v.text =~# '^\s*\%(\%(export\s\+\)\=\%(def\|fu\%[nction]\)!\=\s\+\%([sg]:\|\%(\w\+#\)\+\)\=\w\+(\|enddef\>\|endf\%[unction]\>\)') # 関数でフィルタリング
				->map((_, v) => v->extend({kind:  # 行ごとの種類
				v.text =~# '^\s*\%(export\s\+\)\=\%(def\|fu\%[nction]\)!\=' # 関数始まり
					? 1
					: -1}))
				->RemoveFunction() # 関数の始まり/終りのペアを除く
				->filter((_, v) => v.text =~# '^\s*\%(export\s\+\)\=def!\=\s\+') # 除いてなお def が残っているか?
				if lines != []  # 残っていれば、調べている関数は関数内ローカル
					return false
				endif
				return true
			endif
		enddef

		def BufSearch(b: dict<any>, exp: bool, prefix: string, f_name: string, Filter_b: func(number, dict<any>): bool): list<dict<any>> # 開いているバッファを調べる
			return getbufline(b.n, 1, '$')
				->map((i, v) => ({n: b.n, lnum: i + 1, filename: b.filename, text: v}))
				->filter((_, v) =>
					v.text =~# '^\s*' .. (exp ? '\%(export\s\+\)\=' : '') .. '\%(def\|fu\%[nction]\)!\=\s\+\%(' .. prefix .. '\)\=' .. f_name .. '('
					&& Filter_b(b.n, v))
		enddef

		def BufGrepSearch(reg_f: string, exp: bool, prefix: string, f_name: string, Filter_b: func(number, dict<any>): bool, Filter_f: func(dict<any>): bool, grep_fs: list<string>): list<dict<any>> # 開いているバッファ+grep
			# reg_f: ファイル名の条件 (正規表現)
			# exp: export が付くか? 付く場合が true
			# prefix: s:, g: 等
			# f_name: 検索する関数
			# Filter_b: バッファの絞り込みで filter() の条件となる関数
			# Filter_f: grep の絞り込みで filter() の条件となる関数
			# grep_fs: grep 対象のファイルやディレクトリ
			var ls: list<dict<any>>
			var bufs: list<dict<any>> = getbufinfo()
				->filter((_, v) => v.linecount != 1 && v.name =~# reg_f && v.name !=# ':' && v.name !~# '%')
				->map((_, v) => ({filename: resolve(v.name), n: v.bufnr})) # 読み込み済みの *.vim ファイル
			var bufs_name: list<string> = map(copy(bufs), (_, v) => (v.filename))

			for b in bufs # 編集済みの可能性の有る開いているバッファを先に調べる
				for p in BufSearch(b, exp, prefix, f_name, Filter_b)
					add(ls, p)
				endfor
			endfor
			# grep_fs のファイルから GNU Grep を使って探す
			for f in grep_fs
				for p in systemlist('grep -nHE ''^\s*' .. (exp ? '(export\s+)?' : '') .. '(def|fu(n|nc|nct|ncti|nctio|nction)?)!?\s+(' .. prefix .. ')?' .. f_name .. '\('' ' .. f .. ' /dev/null')
					->map((_, v) => SplitGrep(v))
					->filter((_, v) => v != {} # 空の結果でない
							&& index(bufs_name, resolve(v.filename)) == -1 # バッファに読み込んでいない
							&& Filter_f(v))
				add(ls, p)
				endfor
			endfor
			return ls
		enddef

		def Global(ss: string): bool
			var func: string = matchlist(ss, '^\%(g:\)\=\([A-Z]\w*\)')[1]

			return BufGrepSearch('\(/\.\=g\=vimrc\|\.vim\)$', false, 'g:', func,
				(i: number, v: dict<any>): bool => (getbufline(i, 1, 1)[0] !=# 'vim9script'
					|| v.text =~# '\s*\%(def\|fu\%[nction]\)!\=\s\+g:' ), # 先頭行が vim9script でないか g: が付いている
				(v: dict<any>): bool => (readfile(v.filename, '', 1)[0] !=# 'vim9script'
					|| v.text =~# '\s*\%(def\|fu\%[nction]\)!\=\s\+g:' ),
					[$MYVIMRC .. ' ' .. $MYGVIMRC, ' -r ' .. $MYVIMDIR .. ' -r ' .. $VIMRUNTIME .. ' --include=*.vim'])
			->filter((_, v) => IsGlobalScript(v, 'g:'))
			->GotoPos2(func)
			# g:EditExisting()
			# EditExisting() ←Local() から辿って
			# g:EdiExisting() 存在しない
		enddef

		def Script(ss: string): bool
			return BufSearch(getbufinfo(bufnr())
				->map((_, v) => ({filename: resolve(v.name), n: v.bufnr}))[0],
				false, 's:\|<SID>', ss,
				(_, v: dict<any>): bool => (getline(1)[0] ==# 'vim9script'
						|| v.text =~# '^\s*\%(def\|fu\%[nction]\)!\=\s\+s:' .. ss .. '('))
			->filter((_, v) => IsGlobalScript(v, 's:'))
			->GotoPos2(ss)
			# RemoveFunction(ls) Vim9 ←Local() から辿って
		enddef

		def Local(ss: string): bool # 関数内ローカル→スクリプト・ローカル→グローバルの順で探す→関数内ローカル手つかず
			var func: string = ss[ : -2 ]
			var ls: list<dict<any>> = getline(1,)

			if Script(func)
				return true
			else
				return Global(func)
			endif
		enddef

		var match_ls: list<string>
		var match_s: string

		if s =~# '#' # autoload
			match_ls = matchlist(s, '\(\(\w\+#\)*\(\w\+#\)\)\(\w\+\)')
			var path: string = substitute(match_ls[1][ : -2 ], '#', '/', 'g') .. '.vim'
			var prefix: string = match_ls[1]
			var func: string = match_ls[4]
			var bufs: list<dict<any>> = getbufinfo()
				->filter((_, v) => v.linecount != 1 && v.name =~# $'/autoload/{path}$')
				->map((_, v) => ({filename: resolve( v.name ), n: v.bufnr})) # 読み込み済みの *.vim ファイル
			var bufs_name: list<string> = map(copy(bufs), (_, v) => (v.filename))

			BufGrepSearch($'/autoload/{path}$', true, prefix, func,
					(i: number, v: dict<any>): bool => (getbufline(i, 1, 1)[0] ==# 'vim9script'
							|| v.text =~# '^\s*\%(def\|fu\%[nction]\)!\=\s\+' .. prefix .. func .. '('), # 先頭行が vim9script か、\w\+# が付いている結果を残す
					(v: dict<any>): bool => (readfile(v.filename, '', 1)[0] ==# 'vim9script'
							|| v.text =~# '^\s*\%(def\|fu\%[nction]\)!\=\s\+' .. prefix .. func .. '('),
					(glob($MYVIMDIR .. '**/autoload/' .. path, 1, 1)
						+ glob($VIMRUNTIME .. '/autoload/' .. path, 1, 1))
						->map((_, v) => substitute(resolve(v), "'", "''", 'g')))
			->GotoPos2(func)
			# ftplugin#vim#VimHelp() カレントバッファ
			# asyncomplete#sources#mail#completor(opt, ctx) $MYVIMDIR
			# ftplugin#vim#VimHeop() 存在しない
			# vimgoto#Find() $VIMRUNTIME
		elseif s =~? '^\%(s:\|<SID>\)' || ( s !~# '^g:' && getline(1) !~# '^\s*vim9script\>') # script local
			if !Script(matchlist(s, '\%(s:\|<SID>\)\=\(\w\+\)')[1])
				echohl WarningMsg | echo "Don't Find script " .. matchlist(s, '\%(s:\|<SID>\)\=\(\w\+\)')[1] .. '()!' | echohl None
			endif
		elseif s =~? '^g:' || ( s !~# '^g:' && getline(1) !~# '^\s*vim9script\>') # global
			if !Global(s)
				echohl WarningMsg | echo "Don't Find global " .. matchlist(s, '\%(g:\)\=\(\w\+\)')[1] .. '()!' | echohl None
			endif
		else # prefix 無し
			if !Local(s)
				echohl WarningMsg | echo "Don't Find local " .. s[ : -2 ] .. '()!' | echohl None
			endif
		endif
	enddef

	def Var(s: string): void
		var varb: string = substitute(s, '\%(\["\%([^"]\|\"\)\+"\]\|\[''\%([^'']\|''''\)\+''\]\|\[\w\+\]\|\.\w\+\)$', '', '')
		var filter_s = varb =~# '^g:' # グローバル変数は VimL だと、プレフィックス無し/有り両方
					? '^\s*\%(\zs' .. varb .. '\s*=\|let\s\+' .. '\zs' .. varb .. '\s*=\|let\s\+' .. '\zs' .. varb[ 2 : ] .. '\s*='
					: '^\s*\%(\zs' .. varb .. '\s*=\|let\s\+' .. '\zs' .. varb .. '\s*=\|var\s\+' .. '\zs' .. varb .. '[ \t=:]'
		var last_f: number = -1

		var ls_all: list<dict<any>> = map(getline(1, '.'), (i, v) => ({lnum: i, text: v}))
					->filter((_, v) =>
						v.text =~# filter_s # 変数でフィルタリング
							.. '\|\%(export\s\+\)\=\%(def\|fu\%[nction]\)!\=\s\+\%([sg]:\|\%(\w\+#\)\+\)\=\w\+(\|enddef\>\|endf\%[unction]\>\)') # 関数でフィルタリング
					->map((_, v) => v->extend({kind:  # 行ごとの種類
						v.text =~# '^\s*\%(export\s\+\)\=\%(def\|fu\%[nction]\)!\=' # 関数始まり
						? 1
						: v.text =~# '^\s*\%(enddef\|endf\%[unction]\)\>' # 関数終り
						? -1
						: 0}))
		var ls: list<dict<any>> = copy(ls_all)

		if s !~# '^[gbws]:' # このプレフィックスはファイルを跨るまたはスクリプト・ローカル (ファイル内グローバル) 変数なので、直前の関数の始まり以降に絞り込む必要がない
			RemoveFunction(ls)
			for [i, v] in items(ls) # 最後の関数開始以降のみにする
				if v.kind == 1
					last_f = i
				endif
			endfor
			if last_f == -1 # 関数外なので、代わりの文字をダミーに追加
				insert(ls, {lnum: -1, text: getline(1) =~# '^\s*vim9script\>' ? 'def f(' : 'fu f(', kind: 1})
			elseif last_f != 0
				remove(ls, 0, last_f - 1)
			endif
		endif
		if s =~# '^[gbws]:' # ファイルを跨るまたはスクリプト・ローカル (ファイル内グローバル) 変数
			filter_s = filter_s .. '\)'
		elseif s =~# '^a:' # VimL function's argument
			filter_s = '^\s*\%(export\s\+\)\=fu\%[nction]!\=\s\+\%(s:\|g:\|\%(\w\+#\)\+\)\=\w\+(\%(\w\+\s*,\s*\)*\zs' .. varb[ 2 :  ] .. '\>'
		elseif ls[0].text =~# '^\s*\%(export\s\+\)\=fu\%[nction]!\=\s\+\%(s:\|g:\|\%(\w\+#\)\+\)\=\w\+('
			filter_s = filter_s .. '\)'
			if s !~# '^l:' # golobal in VimL function's
				ls = copy(ls_all)
			endif
		else
			filter_s = filter_s .. '\|\%(export\s\+\)\=def!\=\s\+\%(g:\|\%(\w\+#\)\+\)\=\w\+(\%(\w\+\%(\s*:\s*[A-Za-z<>]\+\)\s*,\s*\)*\zs' .. varb .. '\>\)'
		endif
		filter(ls, (_, v) => v.text =~# filter_s)
		if ls == []
			echohl WarningMsg | echo "Don't Find variable " .. varb .. '!' | echohl None
		else
			GotoPos(expand('%:p'), [ls[0].lnum + 1, match(ls[0].text, filter_s) + 1])
		endif
		return
	enddef

	def Plug(s: string): bool
		var plug: string = '^\s*\%(map\|map!\|[nvxoilc]m\%[ap]\|smap\|tma\%[p]\|snor\%[emap]\|[oict]\=no\%[remap]!\=\|[lnvx]n\%[oremap]\)\s\+\%(<\%(buffer\|nowait\|silent\|special\|script\|expr\|unique\)>\|\s\)*\s\+' .. s
		var ls: list<dict<any>>
		var bufs: list<dict<any>> = getbufinfo()
			->filter((_, v) => v.linecount != 1 && v.name =~# '\(/\.\=g\=vimrc\|\.vim\)$' && v.name !=# ':' && v.name !~# '%')
			->map((_, v) => ({filename: resolve(v.name), n: v.bufnr})) # 読み込み済みの *.vim ファイル
		var bufs_name: list<string> = map(copy(bufs), (_, v) => (v.filename))

		for b in bufs
			for p in getbufline(b.n, 1, '$')
			->map((i, v) => ({n: b.n, lnum: i + 1, filename: b.filename, text: v}))
			->filter((_, v) => v.text =~# plug)
			add(ls, p)
			endfor
		endfor
		for p in systemlist('grep -iEl ''map .+<plug>''' .. escape(plug, '()\') .. ' -r ' .. $MYVIMDIR .. ' --include=*.vim /dev/null')
					->filter((_, v) => v !~# '%')
					->map((_, v) => SplitGrep(v))
					->filter((_, v) => v != {} # 空の結果でない
						&& index(bufs_name, resolve(v.filename)) == -1) # バッファに読み込んでいない
			add(ls, p)
		endfor
		return GotoPos2(ls, s)
		# <Plug>(fern-action-yank:label)
		# <Plug>(fern-action-help)
	enddef

	var line_str: string = getline('.')
	var m_start: number
	var m_end: number = 0
	var m_str: string
	var column: number = col('.')

	while true
		[m_str, m_start, m_end] = matchstrpos(line_str, '\c\%(<Plug>[^ \t]\+\|function(\%("[^"]\+"\|''[^'']\+''\))\|\%([sg]:\|<SID>\|\%(\w\+#\)\+\)\=\w\+(\|\%([vawbgsl]:\|&\)\=\w\+\%(\["\%([^"]\|\"\)\+"\]\|\[''\%([^'']\|''''\)\+''\]\|\[\w\+\]\|\.\w\+\)*\)', m_end)
		if m_start == -1
			return
		endif
		if m_start <= column && m_end >= column
			break
		endif
	endwhile
	if m_str =~# '^&' # option
		execute ":help '" .. m_str[ 1 : ] .. "'"
	elseif m_str =~# '($' # '^function(' # 関数
		Func(m_str)
	elseif m_str =~# '^function(' # 関数
		Func(substitute(m_str, 'function([''"]\([^''"]\+\)[''"])', '\1', ''))
	elseif m_str =~? '^v:'
		execute ":help " .. m_str
	elseif m_str =~? '^[a-z_]' # 関数や変数の先頭は英字←数字だめ
		Var(m_str)
	elseif m_str =~? '^<Plug>'
		Plug(m_str)
	endif
enddef
