vim9script
# Help 折りたたみ関数
scriptencoding utf-8

export def Level(): string
	if v:lnum == 1
		return '>1'
	endif
	var c_line: string = getline(v:lnum)
	var p_line1: string
	var p_line2: string
	if match(c_line, '^=\+$') == 0
		return '>1'
	elseif match(c_line, '^-\+$') == 0
		return '>2'
	elseif match(c_line, '^[^\t ].\+\~$') == 0
		p_line1 = getline(v:lnum - 1)
		p_line2 = getline(v:lnum - 2)
		if match(p_line1, '^=\+$') == 0 || match(p_line1, '^-\+$') == 0
					|| ( match(p_line1, '^[^\s]\+') == 0 && ( match(p_line2, '^=\+$') == 0 || match(p_line2, '^-\+$') == 0 ) )
			return '='
		else
				return '>3'
		endif
	else
		return '='
	endif
enddef

export def Text(): string # 折りたたみテキスト
	var line: string = getline(v:foldstart)
	var i: number = v:foldstart + 1
	if match(line, '^[-=]\+$') == 0
		while i <= line('$')
			line = getline(i)
			if match(line, '^[ \t]') == -1
				break
			endif
			i += 1
		endwhile
	endif
	var line_width: number = winwidth(0) - &foldcolumn
	var cnt: string = printf('[%' .. len(line('$')) .. 's] ', (v:foldend - v:foldstart + 1))
	if &number
		line_width -= max([&numberwidth, len(line('$'))])
	# sing の表示非表示でずれる分の補正
	elseif &signcolumn ==# 'number'
		cnt ..= '  '
	endif
	if &signcolumn ==# 'auto'
		cnt ..= '  '
	endif
	line_width -= 2 * (&signcolumn ==# 'yes' ? 1 : 0)
	line = strcharpart(printf('%-' .. ( &shiftwidth * (v:foldlevel - 1) + 2) .. 's%s', '▸',
		substitute(line, '\*\(.+\)\*', '\1', 'g')->substitute('|\(.+\)|', '\1', 'g')
		), 0, line_width - len(cnt))
	# 全角文字を使っていると、幅でカットすると広すぎる
	# だからといって strcharpart() の代わりに strpart() を使うと、逆に余分にカットするケースが出てくる
	# ↓末尾を 1 文字づつカットしていく
	while strdisplaywidth(line) > line_width - len(cnt)
		line = slice(line, 0, -1)
	endwhile
	return printf('%s%' .. (line_width - strdisplaywidth(line)) .. 'S', line, cnt)
enddef
