vim9script


export def CloseTag(): void # completeopt 次第で候補が一つでも確定しない
	var cmpop: string = &completeopt
	var tmpop: string = substitute(cmpop, '\(menuone\|noinsert\|noselect\),', '', 'g')
		->substitute('\(menuone\|noinsert\|noselect\)$', '', 'g')
	# var ls: list<string>
	# ↓上手くいかない
	# set completeopt&vim
	# feedkeys("</\<C-X>\<C-O>", 'n')
	# &completeopt = cmpop
	# ↓も上手くいかない
	# feedkeys("</", 'n')
	# htmlcomplete#CompleteTags(1, '')
	# ls = htmlcomplete#CompleteTags(0, '')
	# if len(ls) == 1
	# 	return ls[0]
	# else
	# 	return "\<C-X>\<C-O>"
	# endif
	feedkeys("\<C-\>\<C-o>:set completeopt=" .. tmpop .. "\<Enter></\<C-X>\<C-O>\<C-\>\<C-o>:set completeopt=" .. cmpop .. "\<Enter>", 'n')
enddef

export def GF(): void # path#id の記述があった時、path を開いた後 id の位置にカーソル移動 (path が存在しなくても開く)
	# 内部で TaEdit コマンドを使っている
	var str: string
	var start: number = 0
	var end: number
	var col: number = col('.')
	while true
		[str, start, end] = matchstrpos(getline('.'), '\(\(\~/\)\=[A-Za-z0-9/_.-]\+#\w\+\|\(\~/\)\=[A-Za-z0-9/_.-]\+\|#\w\+\)', start)
		if start == -1 || start > col
			return
		elseif start <= col && end >= col
			break
		endif
		start = end + 1
	endwhile
	var hash: number = match(str, '#')
	if hash == -1
		execute('TabEdit ' .. str)
	else
		var id: string = str[hash + 1 :]
		if hash != 0
			execute('TabEdit ' .. expand('%:p:h') .. '/' .. str[0 : hash - 1])
		endif
		str = '<[A-Za-z]\+[^>]*\sid=\(\zs' .. id .. '\>\|"\zs' .. id .. '"\|''\zs' .. id .. '''\)'
		var pos: list<dict<any>> = matchbufline(bufnr('%'), str, 1, line('$'))
		if pos == []
			return
		endif
		setpos('.', [0, pos[0].lnum, pos[0].byteidx, 0])
	endif
	return
enddef
