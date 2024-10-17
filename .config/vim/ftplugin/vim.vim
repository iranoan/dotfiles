vim9script
scriptencoding utf-8
# Vim スクリプト用の設定
if exists('b:did_ftplugin_user')
	finish
endif
b:did_ftplugin_user = 1

# ファイルタイプ別のグローバル設定 {{{1
if !exists('g:vim_plugin')
	g:vim_plugin = 1

	def g:ChangeVim9VimL(): void # vim9script/def/function によって適切な commentstring を設定し iskeyword+-=: を切り替える
		# function ... | ... | endfunction の様に | で連結した関数が有るとうまく判定できない
		# function ...  endfunction / def ...  enddef と対応していなくとも OK としている
		def SetVim9(): void
			setlocal commentstring=#%s iskeyword-=: # vim9script では変数宣言 var hoge: type があるので、: を単語の一部とすると邪魔 (そのため b:var, g:var は一単語にならない)
		enddef

		def SetVimL(): void
			setlocal commentstring="%s iskeyword+=: # vimL では変数宣言 s:func, a:arg, が多くあるので、: を単語の一部としたほうが都合が良い
		enddef

		def TopLine(): void
			if getline(1) =~# '^\s*vim9script\>'
				SetVim9()
			else
				SetVimL()
			endif
		enddef

		# if getline(1) =~# '^\s*vim9script\>' vim9script を開いてから追加すると、syntax がおかしくなるが、自動化すると上手く反映しきられない
		# 	if !b:isVim9script
		# 		b:isVim9script = true
		# 		syntax on
		# 	endif
		# elseif b:isVim9script
		# 	b:isVim9script = false
		# 	syntax on
		# endif

		var defs = filter(getline(1, '.'), 'v:val =~# ''^\s*\(\(export\s\+\|end\)\?def\|endf\%[unction]\|\(export\s\+\)\?fu\%[nction]\)\>''')
		map(defs, 'substitute(v:val, ''\v^\s*(export\s+)?(enddef|def|endf|fu).*'', ''\2'', ''g'')')
		if len(defs) == 0
			TopLine()
			return
		endif
		var f_kind0 = substitute(getline('.'), '\v\<(enddef|def|endf|fu).*', '\1', 'g')
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
			TopLine()
			return
		else
			f_kind0 = defs[i]
			if f_kind0 ==# 'fu'
				SetVimL()
				return
			elseif f_kind0 ==# 'def'
				SetVim9()
				return
			else # endf%[unction] || enddef
				TopLine()
				return
			endif
		endif
	enddef

	def g:Help(tmp: string): void # keywordprg 専用で tmp は無視される
		# keywordprg=:call\ g:Help() ではカーソル一の単語が引数扱いで無駄なエラーになるため、コマンドにして使う
		def Help(s: string): void
			try
			execute('help ' .. s)
			catch /^Vim\%((\a\+)\)\=:E149:/ # 綴り違いで ( が付いているなどヘルプが損じしない
				echohl ErrorMsg | echo 'Not find keyword: ' .. s | echohl None
				return
			endtry
			return
		enddef

		var line: string = getline('.')
		var col: number = col('.')
		var i: number = 0
		var keyword: string # = expand('<cword>')
		var start: number
		var end: number
		var name: string

		# if mode(1) =~# '^c'
		# 	Help(tmp)
		# 	return
		# endif
		[keyword, start, end] = matchstrpos(line, '^\c\v\s*\zs[a-z]+')
		if start != -1 && col <= end && col >= start # 行頭→コマンド
			Help(':' .. keyword)
			return
		endif
		while true
			[keyword, start, end] = matchstrpos(line, '\c\v(\s*\zs((\<bar\>|\|)\s*|<[bgv]:|\&)?[a-z0-9_]+(\(|\=)?|\<[-0-9a-z]+\>)', i)
			if start == -1
				Help('' .. "\<C-r>\<C-w>")
				break
			elseif (col <= end && col >= start)
				if keyword =~# '^\v\<[-a-z]+\>$' # 特殊キー
					Help('' .. keyword)
				elseif keyword =~# '^(\<bar\>|\|)' # コマンド
					Help('' .. matchstr(keyword, '[a-z0-9_]\+$'))
				elseif keyword =~# '^&' || keyword =~# '=$' # オプション
					Help('''' .. matchstr(keyword, '[a-z0-9_]\+'))
				else # 後に(が付く場合も含めて上記以外は syntax を考慮する→関数以外は option-list とそれ以外を区別すれば良い
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
			i = end + 1
		endwhile
		return
	enddef

	augroup myVIM
		autocmd!
		autocmd CursorMoved,InsertLeave * if &filetype ==# 'vim' | call g:ChangeVim9VimL() | endif
	augroup END

	command -nargs=1 -complete=help VimHelp call g:Help(<q-args>)
endif

# ファイルタイプ別のローカル設定 {{{1
# b:isVim9script = getline(1) =~# '^\s*vim9script\>'
g:ChangeVim9VimL()
setlocal spelloptions=camel
