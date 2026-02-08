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
	def ViewMes(s: list<string>): void
			if has('popupwin')
				popup_notification(s, {borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'], col: "cursor", line: "cursor"})
			else
				echohl WarningMsg | echomsg s | echohl None
			endif
	enddef
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
			if !filereadable(str)
				ViewMes(['<' .. str .. '>が存在しない/読み込み不可'])
				return
			endif
		execute('TabEdit ' .. str)
	else
		var id: string = str[hash + 1 :]
		var path: string = str[0 : hash - 1]
		var f_path: string = resolve(expand('%:p:h') .. '/' .. path)
		if hash != 0 && f_path !=# resolve(expand('%:p'))
			if !filereadable(f_path)
				ViewMes(['<' .. path .. '>が存在しない/読み込み不可'])
				return
			endif
			execute('TabEdit ' .. f_path)
		endif
		var pos: list<dict<any>> = matchbufline(bufnr('%'),
			'\C<[A-Za-z]\+[^>]*\s[Ii][Dd]=\(\zs' .. id .. '\>\|"\zs' .. id .. '"\|''\zs' .. id .. '''\)', 1, line('$'))
		if pos == []
			# 大文字小文字区別なしで探し直す
			pos = matchbufline(bufnr('%'), '<[A-Za-z]\+[^>]*\s[Ii][Dd]=\(\zs' .. id .. '\>\|"\zs' .. id .. '"\|''\zs' .. id .. '''\)', 1, line('$'))
			if pos == []
				ViewMes(['<id=' .. id .. '>が存在しない/読み込み不可'])
				return
			endif
			ViewMes(['<id=' .. id .. '>が存在しない/読み込み不可', '大文字/小文字区別なしが存在する'])
		endif
		setpos('.', [0, pos[0].lnum, pos[0].byteidx, 0])
	endif
	return
enddef
