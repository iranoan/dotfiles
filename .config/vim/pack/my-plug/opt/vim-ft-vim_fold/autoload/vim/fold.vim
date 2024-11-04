vim9script
scriptencoding utf-8
# https://github.com/thinca/vim-ft-vim_fold がオリジナル
# if/endif, for/endfor, while/endwhile, try/endtry を追加
# 対応していないカッコを追加←syntax on が前提

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
	var o_pos: number
	var c_pos: number
	var oe_pos: number
	var ce_pos: number
	var om_len: number
	var cm_len: number
	var end_marker: string
	var is_open: bool
	var col: number
	var marker_lv: number
	var s_marker_lv: string
	var synid: string

	var open_pat: string = '\<\%(\(export\s\+\)\?fu\%[nction][! \t]\|aug\%[roup]\>\|if\>\|for\>\|wh\%[ile]\>\|\(export\s\+\)\?def\>\|try\>\)'
	var close_pat: string = '\<\%(endf\%[unction]\|aug\%[roup]\s\+END\|endfo\%[r]\|endw\%[hile]\|enddef\|en\%[dif]\|endt\%[ry]\)\>'

	def PareBracket(): number # ペアで存在しない (), [], {}
		var i: number = 0
		var no_match: number
		var match_b: number
		var s: string
		while true
			[s, match_b, i] = matchstrpos(cur_line, '[][{}()]', i)
			if i == -1
				break
			endif
			synid = synIDattr(synIDtrans(synID(lnum, i, 1)), 'name')
			if synid ==# 'Comment' || synid ==# 'Constant'
				continue
			elseif index(['{', '[', '('], s) != -1
				no_match += 1
			else
				no_match -= 1
			endif
		endwhile
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
			o_pos = stridx(cur_line, open_marker, col)
			c_pos = stridx(cur_line, close_marker, col)
			if o_pos >= 0
				if synIDattr(synIDtrans(synID(lnum, o_pos, 1)), 'name') !=# 'Comment'
					break
				endif
			elseif c_pos >= 0
				if synIDattr(synIDtrans(synID(lnum, c_pos, 1)), 'name') !=# 'Comment'
					break
				endif
			else
				break
			endif
			is_open = (c_pos < 0 || (0 <= o_pos && o_pos < c_pos))
			col = is_open ? o_pos + om_len : c_pos + cm_len
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
		col = 0
		while true # if/endif など対になる文字列
			[o_pos, oe_pos] = matchstrpos(cur_line, open_pat, col)[1 : ]
			[c_pos, ce_pos] = matchstrpos(cur_line, close_pat, col)[1 : ]
			if o_pos < 0 && c_pos < 0
				break
			endif
			if o_pos >= 0 && ( c_pos < 0 || o_pos < c_pos )
				if synIDattr(synIDtrans(synID(lnum, o_pos + 1, 1)), 'name') ==# 'vimCommand'
					ch_lv += 1
				endif
				col = oe_pos + 1
			elseif c_pos >= 0
				if synIDattr(synIDtrans(synID(lnum, c_pos + 1, 1)), 'name') ==# 'vimCommand'
					ch_lv -= 1
				endif
				col = ce_pos + 1
			endif
		endwhile
		ch_lv += PareBracket()

		if ch_lv < 0
			if next_line =~# '^\s*:\?\s*\%(el\%[se]\|elseif\=\>\)' && cur_line =~# close_pat
				levels[lnum] = '<' .. (cur_lv - 1)
			elseif next_line =~# '^\s*:\?\s*\%(cat\%[ch]\|fina\%[lly]\|th\[row]\>\)'
				levels[lnum] = '<' .. (cur_lv - 1)
			else
				levels[lnum] = '<' .. cur_lv
			endif
		elseif 0 < ch_lv
			levels[lnum] = '>' .. (cur_lv + ch_lv)
		elseif next_line =~# '^\s*:\?\s*\%(el\%[se]\|elseif\=\>\)'
			if cur_line =~# close_pat
				levels[lnum] = '<' .. (cur_lv - 1)
			else
				levels[lnum] = '<' .. cur_lv
			endif
		elseif next_line =~# '^\s*:\?\s*\%(cat\%[ch]\|fina\%[lly]\|th\[row]\>\)'
			levels[lnum] = '<' .. cur_lv
		else
			levels[lnum] = cur_lv + ch_lv
		endif
		cur_lv = max([cur_lv + ch_lv, 0])
	endwhile
	return levels
enddef
