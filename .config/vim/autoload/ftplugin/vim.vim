vim9script

def IsVim9(): bool
	def TopLine(): bool
		if getline(1) =~# '^\s*vim9script\>'
			return true
		else
			return false
		endif
	enddef

	var defs = filter(getline(1, '.'), (_, v) => v =~# '^\s*\(\(export\s\+\)\=\(def\|fu\%[nction]!\=\)\s\+\([sg]:\|\(\w\+#\)\+\)\=\w\+(\|enddef\>\|endf\%[unction]\>\)')
						->map((_, v) => substitute(v, '^\s*\(export\s\+\)\=\(enddef\|def\|endf\|fu\).*', '\2', 'g'))
	if len(defs) == 0
		return TopLine()
	endif
	var f_kind0 = substitute(getline('.'), '\<\(enddef\|def\|endf\|fu\).*', '\1', 'g')
	if f_kind0 ==# 'fu' || f_kind0 ==# 'def'
		remove(defs, -1)
	endif
	var i = len(defs) - 1
	var f_kind1: string
	while i >= 1
		f_kind0 = defs[i]
		f_kind1 = defs[i - 1]
		if (f_kind0 ==# 'endf' || f_kind0 ==# 'enddef') && (f_kind1 ==# 'fu' || f_kind1 ==# 'def')
			i -= 2
		else
			break
		endif
	endwhile
	if i < 0
		return TopLine()
	else
		f_kind0 = defs[i]
		if f_kind0 ==# 'fu'
			return false
		elseif f_kind0 ==# 'def'
			return true
		else # endf%[unction] || enddef
			return TopLine()
		endif
	endif
enddef

export def ChangeVim9VimL(): void # vim9script/def/function によって適切な commentstring を設定し iskeyword+-=: を切り替える
	# function ... | ... | endfunction の様に | で連結した関数が有るとうまく判定できない
	# function ...  endfunction / def ...  enddef と対応していなくとも OK としている
	def SetVim9(): void
		setlocal commentstring=#%s iskeyword-=: # vim9script では変数宣言 var hoge: type があるので、: を単語の一部とすると邪魔 (そのため b:var, g:var は一単語にならない)
	enddef

	def SetVimL(): void
		setlocal commentstring="%s iskeyword+=: # vimL では変数宣言 s:func, a:arg, が多くあるので、: を単語の一部としたほうが都合が良い
	enddef

	if IsVim9()
		SetVim9()
	else
		SetVimL()
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

	def Func(s: string): void
		def GetPos(ls: list<string>, vim9: string, vimL: string): list<dict<number>>
			var ss: string = (ls[0] =~# '^\s*vim9script\>' ? vim9 : vimL) .. '('

			return map(copy(ls), (i, v) => ({lnum: i, lstr: v}))
			       	->filter((_, v) => v.lstr =~# ss)
			       	->map((_, v) => ({lnum: v.lnum + 1, cnum: match(v.lstr, ss) + 1}))
		enddef

		def SelectPos(ls: list<string>, p: string, vim9: string, vimL: string): list<number>
			var l: list<dict<number>>

			l = GetPos(ls, vim9, vimL)
			if l == []
				return []
			endif
			if len(l) == 1 || resolve(expand('%:p')) !=# resolve(p)
				return [l[0].lnum, l[0].cnum]
			endif
			var n: number = line('.')
			filter(l, (_, v) => v.lnum <= n)
			return [l[-1].lnum, l[-1].cnum]
		enddef

		def GotoPosFile(p: string, vim9: string, vimL: string): bool
			if !filereadable(p)
				return false
			endif
			return GotoPos(p, SelectPos(readfile(p), p, vim9, vimL))
		enddef

		def GotoPosBuffer(p: string, n: number, vim9: string, vimL: string): bool
			if !getbufinfo(n)[0].listed || getbufinfo(n)[0].linecount == 1 # grep などをした時に :ls! には有るが読み込まれていないときが有る
				return GotoPosFile(p, vim9, vimL)
			else
				return GotoPos(p, SelectPos(getbufline(n, 1, '$'), p, vim9, vimL))
			endif
		enddef

		var match_ls: list<string>
		var match_s: string
		var func: string

		if s =~# '#' # autoload
			match_ls = matchlist(s, '\(\(\w\+#\)\+\)\(\w\+\)')
			match_s = match_ls[0]
			var f: string = split(match_s, '#')[ : -2 ]->join('/') .. '.vim'
			func = match_ls[3]
			var line: number
			for p in bufinfo->filter((_, v) => v.name =~# $'/autoload/{f}$')
				if GotoPosBuffer(p.name, p.bufnr, '^\s*\(def\|fu\%[nction]!\=\)\s\+\zs' .. func, '^\s*\(def\|fu\%[nction]!\=\)\s\+\zss:' .. func)
					return
				endif
			endfor
			for p in glob($MYVIMDIR .. '**/autoload/' .. f, 1, 1)
				if !filereadable(p)
					continue
				endif
				if GotoPosFile(p, '^\s*export\s\+\(def\|fu\%[nction]!\=\)\s\+\zs' .. func, '^\s*\(def\|fu\%[nction]!\=\)\s\+\zs' .. func)
					return
				endif
			endfor
			for p in glob($VIMRUNTIME .. '/**/autoload/' .. f, 1, 1)
				if !filereadable(p)
					continue
				endif
				if GotoPosFile(p, '^\s*export\s\+\(def\|fu\%[nction]!\=\)\s\+\zs' .. func, '^\s*\(def\|fu\%[nction]!\=\)\s\+\zs' .. func)
					return
				endif
			endfor
			echohl WarningMsg | echo "Don't Find autoload " .. func .. '()!' | echohl None
			# ftplugin#vim#VimHelp()
			# asyncomplete#sources#mail#completor(opt, ctx) abort
			# ftplugin#vim#VimHeop()
			# vimgoto#Find()
		elseif s =~? '\(s:\|<SID>\)' || ( s !~# '^g:' && getline(1) =~# '^\s*vim9script\>') # script local
			match_ls = matchlist(s, '\(s:\|<SID>\)\=\(\w\+\)')
			func = match_ls[2]
			if !GotoPosBuffer(expand('%:p'), bufnr(), '^\s*\(def\|fu\%[nction]!\=\)\s\+\zs' .. func, '^\s*\(def\|fu\%[nction]!\=\)\s\+\zss:' .. func)
				echohl WarningMsg | echo "Don't Find local " .. func .. '()!' | echohl None
			endif
		else # global g:func()
			func = matchlist(s, '^\(g:\)\=\([A-Z]\w*\)')[2]
			for b in bufinfo
				if GotoPosBuffer(b.name, b.bufnr, '^\s*\(def\|fu\%[nction]!\=\)\s\+\zsg:' .. func, '^\s*\(def\|fu\%[nction]!\=\)\s\+\zs\(g:\)\=' .. func)
					return
				endif
			endfor
			for p in [$MYVIMRC, $MYGVIMRC] + glob($MYVIMDIR .. '**/*.vim', 1, 1)
				if !filereadable(p)
					continue
				endif
				if GotoPosFile(p, '^\s*\(def\|fu\%[nction]!\=\)\s\+\zsg:' .. func, '^\s*\(def\|fu\%[nction]!\=\)\s\+\zs\(g:\)\=' .. func)
					return
				endif
			endfor
			for p in glob($VIMRUNTIME .. '**/*.vim', 1, 1)
				if !filereadable(p)
					continue
				endif
				if GotoPosFile(p, '^\s*\(def\|fu\%[nction]!\=\)\s\+\zsg:' .. func, '^\s*\(def\|fu\%[nction]!\=\)\s\+\zs\(g:\)\=' .. func)
					return
				endif
			endfor
			echohl WarningMsg | echo "Don't Find global " .. func .. '()!' | echohl None
		endif
	enddef

	def Var(s: string): void
		def RemoveRange(l: list<dict<any>>): dict<number> # 関数の最初と最後のペアを返す
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

		var varb: string = substitute(s, '\(\["\([^"]\|\"\)\+"\]\|\[''\([^'']\|''''\)\+''\]\|\[\w\+\]\|\.\w\+\)$', '', '')
		var filter_s = varb =~# '^g:' # グローバル変数は VimL だと、プレフィックス無し/有り両方
					? '^\s*\(\zs' .. varb .. '\s*=\|let\s\+' .. '\zs' .. varb .. '\s*=\|let\s\+' .. '\zs' .. varb[ 2 : ] .. '\s*='
					: '^\s*\(\zs' .. varb .. '\s*=\|let\s\+' .. '\zs' .. varb .. '\s*=\|var\s\+' .. '\zs' .. varb .. '[ \t=:]'
		var rm_range: dict<number> # 関数の最初と最後のペアのインデックス
		var last_f: number = -1

		var ls_all: list<dict<any>> = map(getline(1, '.'), (i, v) => ({lnum: i, lstr: v}))
					->filter((_, v) =>
						v.lstr =~# filter_s # 変数でフィルタリング
							.. '\|\(export\s\+\)\=\(def\|fu\%[nction]!\=\)\s\+\([sg]:\|\(\w\+#\)\+\)\=\w\+(\|enddef\>\|endf\%[unction]\>\)') # 関数でフィルタリング
					->map((_, v) => ({lnum: v.lnum, lstr: v.lstr, kind:  # 行ごとの種類
						v.lstr =~# '^\s*\(export\s\+\)\=\(def\|fu\%[nction]!\=\)' # 関数始まり
						? 1
						: v.lstr =~# '^\s*\(enddef\|endf\%[unction]\)\>' # 関数終り
						? -1
						: 0}))
		var ls: list<dict<any>> = copy(ls_all)

		if s !~# '^[gbws]:' # このプレフィックスはファイルを跨るまたはスクリプト・ローカル (ファイル内グローバル) 変数なので、直前の関数の始まり以降に絞り込む必要がない
			while true # ペアの関数削除
				rm_range = RemoveRange(ls)
				if rm_range.end == -1
					break
				endif
				remove(ls, rm_range.start, rm_range.end)
			endwhile
			for [i, v] in items(ls) # 最後の関数開始以降のみにする
				if v.kind == 1
					last_f = i
				endif
			endfor
			if last_f == -1 # 関数外なので、代わりの文字をダミーに追加
				insert(ls, {lnum: -1, lstr: getline(1) =~# '^\s*vim9script\>' ? 'def f(' : 'fu f(', kind: 1})
			elseif last_f != 0
				remove(ls, 0, last_f - 1)
			endif
		endif
		if s =~# '^[gbws]:' # ファイルを跨るまたはスクリプト・ローカル (ファイル内グローバル) 変数
			filter_s = filter_s .. '\)'
		elseif s =~# '^a:' # VimL function's argument
			filter_s = '^\s*\(export\s\+\)\=fu\%[nction]!\=\s\+\(s:\|g:\|\(\w\+#\)\+\)\=\w\+(\(\w\+\s*,\s*\)*\zs' .. varb[ 2 :  ] .. '\>'
		elseif ls[0].lstr =~# '^\s*\(export\s\+\)\=fu\%[nction]!\=\s\+\(s:\|g:\|\(\w\+#\)\+\)\=\w\+('
			filter_s = filter_s .. '\)'
			if s !~# '^l:' # golobal in VimL function's
				ls = copy(ls_all)
			endif
		else
			filter_s = filter_s .. '\|\(export\s\+\)\=def\=\s\+\(g:\|\(\w\+#\)\+\)\=\w\+(\(\w\+\(\s*:\s*[A-Za-z<>]\+\)\s*,\s*\)*\zs' .. varb .. '\>\)'
		endif
		filter(ls, (_, v) => v.lstr =~# filter_s)
		if ls == []
			echohl WarningMsg | echo "Don't Find variable " .. varb .. '!' | echohl None
		else
			GotoPos(expand('%:p'), [ls[0].lnum + 1, match(ls[0].lstr, filter_s) + 1])
		endif
		return
	enddef

	def Plug(s: string): void
		def GetPos(ls: list<string>, ss: string): list<number>
			var l: number = indexof(ls, (_, v) => v =~# ss)

			if l == -1
				return []
			endif
			return [l + 1, match(ls[l], ss) + 1]
		enddef

		def GotoPosFile(p: string, ss: string): bool
			if filereadable(p)
				return GotoPos(p, GetPos(readfile(p), ss))
			else
				return false
			endif
		enddef

		def GotoPosBuffer(p: string, n: number, ss: string): bool
			if !getbufinfo(n)[0].listed || getbufinfo(n)[0].linecount == 1 # grep などをした時に :ls! には有るが読み込まれていないときが有る
				return GotoPosFile(p, ss)
			else
				return GotoPos(p, GetPos(getbufline(n, 1, '$'), ss))
			endif
		enddef

		var plug: string = '^\s*\(map\|map!\|[nvxoilc]m\%[ap]\|smap\|tma\%[p]\|snor\%[emap]\|[oict]\=no\%[remap]!\=\|[lnvx]n\%[oremap]\)\s\+\(<\(buffer\|nowait\|silent\|special\|script\|expr\|unique\)>\|\s\)*\s\+' .. s
		var ls: list<dict<any>>

		for p in getbufinfo()
				->filter((_, v) => resolve(v.name) =~# '^' .. resolve($MYVIMDIR) .. '.\+\.vim$')
				->map((_, v) => ({bufnr: v.bufnr, name: v.name}))
			if GotoPosBuffer(p.name, p.bufnr, plug)
				return
			endif
		endfor
		for p in systemlist('grep -iE ''map .+<plug>'' -r ' .. $MYVIMDIR .. ' --include=*.vim -l')->filter((_, v) => v !~# '%')
			if !filereadable(p)
				continue
			endif
			if GotoPosFile(p, plug)
				return
			endif
		endfor
		echohl WarningMsg | echo "Don't Find map " .. s .. '!' | echohl None
	enddef

	var line_str: string = getline('.')
	var m_start: number
	var m_end: number = 0
	var m_str: string
	var column: number = col('.')

	while true
		[m_str, m_start, m_end] = matchstrpos(line_str, '\c\(<Plug>[^ \t]\+\|function(\("[^"]\+"\|''[^'']\+''\))\|\([sg]:\|<SID>\|\(\w\+#\)\+\)\=\w\+(\|\([vawbgsl]:\|&\)\=\w\+\(\["\([^"]\|\"\)\+"\]\|\[''\([^'']\|''''\)\+''\]\|\[\w\+\]\|\.\w\+\)*\)', m_end)
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
