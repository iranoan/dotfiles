vim9script
scriptencoding utf-8

# カーソル下の単語をGoogleで検索する
def Search(url: string, mes: string, range: number): void
	var msgWord: string
	var searchWord: string
	if range > 0
		var s_l: number = getcharpos("'<")[1]
		var e_l: number = getcharpos("'>")[1]
		var s_c: number = getcharpos("'<")[2] - 1
		var e_c: number = getcharpos("'>")[2]
		if s_l == e_l
			msgWord = strcharpart(getline(s_l), s_c, e_c - s_c)
		else
			msgWord = strcharpart(getline(s_l), s_c)
			for s in getline(s_l + 1, e_l - 1)
				msgWord ..= s
			endfor
			msgWord ..= strcharpart(getline(e_l), 0, e_c)
		endif
	else
		msgWord = expand('<cword>')
	endif
	if msgWord  ==# ''
		return
	endif
	msgWord = substitute(msgWord, '[ \n\r]', '+', 'g')
	searchWord = substitute(msgWord, '+$', '', 'g')->escape('|&;(){}#$"''\<>')
	if has('unix')
		system('xdg-open ' .. url .. searchWord)
	elseif has('win32') || has('win32unix')
		system('start ' .. url .. searchWord)
	elseif has('mac')
		system('open ' .. url .. searchWord)
	endif
	echo mes .. ' search: ' .. msgWord

enddef

export def Google(range: number): void
	Search('https://www.google.co.jp/search?q=', 'Google', range)
enddef

export def Amazon(range: number): void
	Search('https://www.amazon.co.jp/s?k=', 'Amazon', range)
enddef

export def WikiPedia(range: number): void
	Search('https://ja.wikipedia.org/wiki/', 'WikiPedia', range)
enddef
