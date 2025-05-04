vim9script
scriptencoding utf-8

var output: string = expand('<sfile>:p:h') .. '/'

export def Convert(dir: string): void
	var msg: list<any> = ['vim9script', 'export var msg: dict<string> = {']
	var err_msg: list<any>
	var lc_all: string = output2qf#GetLang()
	var lang_f: list<string> = globpath(dir .. '/src/po', lc_all[0 : 1] .. "*.po")->split("\n")
	var key: string
	var value: string
	var f: string = matchstr(lang_f, lc_all .. '.po\c')
	if f ==# ''
		f = matchstr(lang_f, split(lc_all, '\.')[0] .. '.po\c')
	endif
	if f ==# ''
		f = matchstr(lang_f, split(lc_all, '_')[0] .. '.po\c')
	endif
	if !filereadable(f)
		return
	endif
	err_msg = readfile(f)
	for s in ['"Error detected while processing %s:"', '"Error detected while compiling %s:"', '"line %4ld:"', '"\\tLast set from "', '"%s line %ld"', '"E123: Undefined function: %s"']
		# msgid のキーワードで検索し、その後の行頭改行の前の行に書かれた言語ごとのメッセージ書式を取得
		# ただし msgid は複数行に渡って書かれているので、先頭に msgid をつけて検索は出来ない
		key = substitute(s, '\\\\', '\', 'g')[1 : -2]
		value = err_msg[match(err_msg, '^$', match(err_msg, s)) - 1]->substitute('^msgstr ', '', 'g')
		if s ==#  '"E123: Undefined function: %s"'
			value = '^' .. substitute(value, '%s', '', 'g')[1 : -2]
		else
			value = '^' .. substitute(value, '%\dl\?d', '\\s*\\(\\d\\+\\)', 'g')
				->substitute('%l\?d', '\\(\\d\\+\\)', 'g')
				->substitute('%s', '\\(.\\{-}\\)', 'g')[1 : -2] .. '$'
		endif
		add(msg, "\t'" .. key .. ''': ''' .. value .. ''',')
	endfor
	add(msg, '}')
	writefile(msg, output .. f[-5 : -3] .. 'vim')
	return
enddef
