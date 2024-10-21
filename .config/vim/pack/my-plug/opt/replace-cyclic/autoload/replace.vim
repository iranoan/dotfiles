vim9script
scriptencoding utf-8

export def Escape_search(s: string): string
	return escape(replace#Escape_search_core(s), getcmdtype())
enddef

export def Escape_search_core(s: string): string
	return escape(s, '\~[.*$^')
enddef

export def Escape_replace(s: string): string
	return escape(s, '\~&')
enddef

export def Cyclic(args: string, word: number = 0): string
	# , 区切り文字列をリストに変換
	var s_ls: list<string>
	var s_while: string
	var m_start: number
	var m_end = -1
	while 1
		[s_while, m_start, m_end] = matchstrpos(args, '\m\(\\\\\|\\,\|[^,]\)\+', m_end + 1)
		if m_start == -1
			break
		endif
		add(s_ls, substitute(s_while, '\\\(\\\|,\)', '\1', 'g'))
	endwhile
	if s_ls == [] # 空なら空文字を返す
		return ''
	endif
	# 置換時の区切り文字 (デフォルト /) を探す
	var i = 0
	var sep_match: bool
	for s in '/?!#%-+,_]``"'
		sep_match = true
		for ls_s in s_ls
			if match(ls_s, s) != -1
				i += 1
				sep_match = false
				break
			endif
		endfor
		if sep_match
			break
		endif
	endfor
	var sep: string
	if i < len('/?!#%-+,_[]``"')
		sep = '/?!#%-+,_[]``"'[i]
	else
		echohl WarningMsg
		echo "search word include all of '/?!#%-+,_]``'"
		echohl None
		return ''
	endif
	# 文字列を \(dog\|cat\) といった正規表現文字列に変換
	var ret_s = 's' .. sep .. ( and(word, 1) ? '\<' : '' ) .. '\('
	for s in s_ls
		ret_s ..= replace#Escape_search_core(s) .. '\|'
	endfor
	ret_s = ret_s[ : -2] .. ')' .. ( !and(word, 2) ? '' : '\>' ) .. sep .. '\={'''
	# 文字列を {'dog':'cat', 'cat':'dog'} といった辞書に変換
	i = 1
	for s in s_ls[ : -2]
		ret_s ..= substitute(s, "'", "''", 'g') .. "':'" .. substitute(replace#Escape_replace(s_ls[i]), "'", "''", 'g') .. "', '"
		i += 1
	endfor
	ret_s ..= substitute(s_ls[-1], "'", "''", 'g') .. "':'" .. substitute(replace#Escape_replace(s_ls[0]), "'", "''", 'g') .. "'}[submatch(1)]" .. sep .. "g"
	return ret_s
enddef
