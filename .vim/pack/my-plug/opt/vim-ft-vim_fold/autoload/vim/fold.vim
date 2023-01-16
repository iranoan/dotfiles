vim9script
scriptencoding utf-8
# https://github.com/thinca/vim-ft-vim_fold がオリジナル
# if/endif, for/endfor, while/endwhile, try/endtry を追加

export def Level(): any
	if b:changedtick != get(b:, 'vim_fold_last_changedtick', -1)
		b:vim_fold_last_changedtick = b:changedtick
		b:vim_fold_levels = Calculate(bufnr('%'))
	endif
	return get(b:vim_fold_levels, v:lnum, 0)
enddef

def Text(): string
	var line: string = getline(v:foldstart)
	var linenr: number = v:foldstart + 1
	while getline(linenr) =~# '^\s*\\'
		line ..= matchstr(getline(linenr), '\m^\s*\\\s\{-}\zs\s\?\S.*$')
		linenr += 1
	endwhile
	if linenr == v:foldstart + 1
		return foldtext()
	endif
	return line
enddef

def Calculate(bufnr: number): dict<any>
	var foldmarker: string = getbufvar(bufnr, '&foldmarker')
	var levels: dict<any>
	var lines: list<string> = getbufline(bufnr, 1, '$')
	var lnum: number
	var next_line: string = lines[lnum]
	var cur_line: string
	var cur_lv: number
	var ch_lv: number
	var here_lv: number
	var endl: number = line('$')
	var open_marker: string
	var close_marker: string
	var om_pos: number
	var cm_pos: number
	var om_len: number
	var cm_len: number
	var end_marker: string
	var is_open: bool
	var col: number
	var marker_lv: number
	var s_marker_lv: string

	var open_pat: string = '^\s*:\?\s*\%(\(export\s\+\)\?fu\%[nction]\s\|\(exe\%[cute]\s\+["'']\|execute(["'']\)\?aug\%[roup]\s\|if\>\|for\>\|wh\%[ile]\>\|\(export\s\+\)\?def\>\|try\>\)'
	var close_pat: string = '^\s*:\?\s*\%(endf\%[unction]\>\|aug\%[roup]\s\+END\|endfo\%[r]\|endw\%[hile]\|enddef\|en\%[dif]\|endt\%[ry]\)\>'

	def PareBracket(): number # ペアで存在しない (), [], {}
		var i: number
		var no_match: number
		var synid: string
		var regex: string
		for s in '[({'
			regex = '^\("\([^"]\|\"\)*"\|''\([^'']\|''''\)*''\|[^' .. s .. '"'']\)*' .. s
			i = 0
			while true
				i = matchend(cur_line, regex, i)
				synid = synIDattr(synIDtrans(synID(lnum, i, 1)), 'name')
				if i == -1 || synid ==# 'Comment'
					break
				endif
				if synid !=# 'Constant'
					no_match += 1
				endif
			endwhile
		endfor
		for s in '})]'
			regex = '^\("\([^"]\|\"\)*"\|''\([^'']\|''''\)*''\|[^' .. s .. '"'']\)*' .. s
			i = 0
			while true
				i = matchend(cur_line, regex, i)
				synid = synIDattr(synIDtrans(synID(lnum, i, 1)), 'name')
				if i == -1 || synid ==# 'Comment'
					break
				endif
				if synid !=# 'Constant'
					no_match -= 1
				endif
			endwhile
		endfor
		return no_match
	enddef

	[open_marker, close_marker] = split(foldmarker, ',')
	om_len = len(open_marker)
	cm_len = len(close_marker)
	while lnum < endl
		lnum += 1
		cur_line = next_line
		next_line = get(lines, lnum, '')
		ch_lv = 0
		# empty line
		if cur_line ==# '' && type(levels[lnum - 1]) == 1
			levels[lnum] = levels[lnum - 1]
			levels[lnum - 1] = levels[lnum - 1][1 : ]
		endif
		# here document
		if cur_line =~# '\<\(py\%[thon]\|py3\|python3\|rub\%[y]\|lua\|mz\%[scheme]\|pe\%[rl]\|tcl\)\s*<<\s*\(trim\)\?\s*\zs\(\w\+\)'
			here_lv = cur_lv + 1
			levels[lnum] = '>' .. here_lv
			end_marker = substitute(cur_line,
						\ '.*\<\(py\%[thon]\|py3\|python3\|rub\%[y]\|lua\|mz\%[scheme]\|pe\%[rl]\|tcl\)\s*<<\s*\(trim\)\?\s*\(\w\+\)/*', '\3', '')
			while lnum < endl
				lnum += 1
				levels[lnum] = here_lv
				next_line = get(lines, lnum, '')
				if next_line =~# '^' .. end_marker .. '$'
					levels[lnum] = here_lv
					levels[lnum + 1] = '<' .. here_lv
					break
				endif
			endwhile
			continue
		endif
		# marker
		col = 0
		while true
			om_pos = stridx(cur_line, open_marker, col)
			cm_pos = stridx(cur_line, close_marker, col)
			if om_pos >= 0
				if synIDattr(synIDtrans(synID(lnum, om_pos, 1)), 'name') !=# 'Comment'
					break
				endif
			elseif cm_pos >= 0
				if synIDattr(synIDtrans(synID(lnum, om_pos, 1)), 'name') !=# 'Comment'
					break
				endif
			else
				break
			endif
			is_open = (cm_pos < 0 || (0 <= om_pos && om_pos < cm_pos))
			col = is_open ? om_pos + om_len : cm_pos + cm_len
			s_marker_lv = matchstr(cur_line, '\m^\d\+', col)
			col += len(s_marker_lv)
			marker_lv = str2nr(s_marker_lv)
			if is_open
				if marker_lv == 0
					ch_lv += 1
				else
					levels[lnum] = '>' .. marker_lv
					cur_lv = marker_lv
				endif
			else
				if marker_lv == 0
					ch_lv -= 1
				else
					levels[lnum] = '<' .. marker_lv
					cur_lv = marker_lv - 1
				endif
			endif
		endwhile

		if has_key(levels, lnum)
			cur_lv = max([cur_lv + ch_lv, 0])
			continue
		endif
		if cur_line =~# close_pat # if/end など対になる文字列
			ch_lv -= 1
		elseif cur_line =~# open_pat
			ch_lv += 1
		endif
		ch_lv += PareBracket()

		if ch_lv < 0
			if next_line =~# '\<el\%[se]\|elseif\=\>' && cur_line =~# close_pat
				levels[lnum] = '<' .. (cur_lv - 1)
			elseif next_line =~# '\<cat\%[ch]\|fina\%[lly]\|th\[row]\>'
				levels[lnum] = '<' .. (cur_lv - 1)
			else
				levels[lnum] = '<' .. cur_lv
			endif
		elseif 0 < ch_lv
			levels[lnum] = '>' .. (cur_lv + ch_lv)
		elseif next_line =~# '\<el\%[se]\|elseif\=\>'
			if cur_line =~# close_pat
				levels[lnum] = '<' .. (cur_lv - 1)
			else
				levels[lnum] = '<' .. cur_lv
			endif
		elseif next_line =~# '\<cat\%[ch]\|fina\%[lly]\|th\[row]\>'
			levels[lnum] = '<' .. cur_lv
		else
			levels[lnum] = cur_lv + ch_lv
		endif
		cur_lv = max([cur_lv + ch_lv, 0])
	endwhile
	return levels
enddef
defcompile
