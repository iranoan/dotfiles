vim9script
scriptencoding utf-8
# AWK 用の foldexpr
# {} の対応と連続する行頭から始まるコメントを折りたたみ対象にする

export def Level(): any
	def Calculate(bufnr: number): dict<any>
		var synid: string
		var i: number
		var match_b: number
		var s: string
		def PareBracket(line: string, l: number): number # ペアで存在しない {}
			var no_match: number = 0
			i = 0
			while true
				[s, match_b, i] = matchstrpos(line, '[{}]', i)
				if i == -1
					break
				endif
				synid = synIDattr(synIDtrans(synID(l + 1, i, 1)), 'name')
				if synid ==# 'Comment' || synid ==# 'Constant'
					continue
				elseif '{' ==# s
					no_match += 1
				else
					no_match -= 1
				endif
			endwhile
			return no_match
		enddef

		var lines: list<string> = getbufline(bufnr, 1, '$')
		var next_line: string = get(lines, 0, '')    # 次行の内容 (最初は先頭行)
		var c_lv: number = 0                         # 今の行の {} の非対応数
		var n_lv: number = PareBracket(next_line, 0) # 次の行の {} の非対応数 (最初は先頭行)
		var p_comment: bool                          # 前の行がコメントか?
		var c_comment: bool                          # 今の行がコメントか?
		var n_comment: bool = next_line =~# '^\s*#'  # 次の行がコメントか? (最初は先頭行)
		var levels: dict<any>
		var lv: number = 0
		var j: number

		for lnum in range(1, line('$', bufwinid(bufnr)))
			c_lv = n_lv
			p_comment = c_comment
			c_comment = n_comment
			next_line = get(lines, lnum, '')
			n_lv = PareBracket(next_line, lnum)
			n_comment = next_line =~# '^\s*#'
			if c_lv != 0 # 非対応の {} がある
				if c_lv > 0
					lv += c_lv
					j = lnum - 1
					while true # 連結行 (前行の行末が\) ならば遡る
						levels[j + 1] = lv
						i = 0
						[s, match_b, i] = matchstrpos(get(lines, j - 1, ''), '\\$', i)
						if i == -1
							break
						endif
						synid = synIDattr(synIDtrans(synID(j, i, 1)), 'name')
						if synid ==# 'Comment' || synid ==# 'Constant'
							break
						endif
						j -= 1
					endwhile
					levels[j + 1] = '>' .. lv
				else
					levels[lnum] = '<' .. lv
					lv += c_lv
				endif
			else
				if c_comment # 連続するコメントは折りたたみにするための判定
					if p_comment
						if n_comment
							levels[lnum] = lv + 1
						else
							levels[lnum] = '<' .. (lv + 1)
						endif
					else
						if n_comment
							levels[lnum] = '>' .. (lv + 1)
						else
							levels[lnum] = lv
						endif
					endif
				else
					levels[lnum] = lv
				endif
			endif
		endfor
		return levels
	enddef

	if b:changedtick != get(b:, 'awk_last_changedtick', -1)
		b:awk_last_changedtick = b:changedtick
		b:awk_levels = Calculate(bufnr('%'))
	endif
	return get(b:awk_levels, v:lnum, 0)
enddef
defcompile
