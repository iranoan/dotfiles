vim9script
scriptencoding utf-8

export def Base(...arg: list<any>): string
	# use the argument for display if possible, otherwise the current line
	var line: string
	var foldmarkers: list<string> = split(&foldmarker, ',')
	var comment: string = escape(&commentstring, '.$*~\')->substitute('%s', '\\(.\\{-}\\)', '')
	var line_width: number
	var cnt = printf('[%' .. len(line('$')) .. 's] ', (v:foldend - v:foldstart + 1))
	if len(arg) > 0
		line = arg[0]
	else
		line = getline(v:foldstart)
	endif
	# remove the marker that caused this fold from the display
	line = substitute(line, '\V' .. foldmarkers[0] .. '\%(\d\+\)\?', ' ', '')
	if &filetype ==# 'vim'
		line = substitute(line, '\(^\s*\zs#\|\s\+#\|"\)\s*', ' ', '')
	elseif comment !=# ''
		while match(line, comment) != -1
			line = substitute(line, comment, '\1', '')
		endwhile
	endif
	# remove any remaining leading or trailing whitespace
	line = substitute(line, '^\s*\(.\{-}\)\s*$', '\1', '')

	line_width = winwidth(0) - &foldcolumn

	if &number
		line_width -= max([&numberwidth, len(line('$'))])
	# sing の表示非表示でずれる分の補正
	elseif &signcolumn ==# 'number'
		cnt = cnt .. '  '
	endif
	if &signcolumn ==# 'auto'
		cnt = cnt .. '  '
	endif
	line_width -= 2 * (&signcolumn ==# 'yes' ? 1 : 0)

	line = strcharpart(printf('%-' .. ( &shiftwidth * (v:foldlevel - 1) + 2) .. 's%s', '▶', line), 0, line_width - len(cnt))
	# 全角文字を使っていると、幅でカットすると広すぎる
	# だからといって strcharpart() の代わりに strpart() を使うと、逆に余分にカットするケースが出てくる
	# ↓末尾を 1 文字づつカットしていく
	while strdisplaywidth(line) > line_width - len(cnt)
		line = slice(line, 0, -1)
	endwhile
	return printf('%s%' .. (line_width - strdisplaywidth(line)) .. 'S', line, cnt)
enddef

export def LaTeX(): string
	var latex_types: dict<string> = {'thm': 'Theorem', 'cor': 'Corollary', 'lem': 'Lemma', 'defn': 'Definition'}
	var line: string = getline(v:foldstart)
	var matches: list<string>
	var env: string
	def Enumeration(depth: number, index: any): any
		def Upper_letter(i: number): string
			if i <= 26
				return nr2char(char2nr('A') + i - 1)
			else
				return nr2char(i)
			endif
		enddef

		def Lower_letter(i: number): string
			return tolower(Upper_letter(i))
		enddef

		def Roman_numeral(j: number): string
			var numeral: string = ''
			var chars: string = 'ivxlcdm'
			var i: number = j
			var c1: string
			var c5: string
			var c10: string
			var digit: number
			for base in [0, 2, 4]
				c1 = strpart(chars, base, 1)
				c5 = strpart(chars, base + 1, 1)
				c10 = strpart(chars, base + 2, 1)
				digit = i % 10
				if digit == 1
					numeral = c1 .. numeral
				elseif digit == 2
					numeral = c1 .. c1 .. numeral
				elseif digit == 3
					numeral = c1 .. c1 .. c1 .. numeral
				elseif digit == 4
					numeral = c1 .. c5 .. numeral
				elseif digit == 5
					numeral = c5 .. numeral
				elseif digit == 6
					numeral = c5 .. c1 .. numeral
				elseif digit == 7
					numeral = c5 .. c1 .. c1 .. numeral
				elseif digit == 8
					numeral = c5 .. c1 .. c1 .. c1 .. numeral
				elseif digit == 9
					numeral = c1 .. c10 .. numeral
				endif
				i = i / 10
				if i == 0
					break
				endif
			endfor
			return repeat('m', i) .. numeral
		enddef

		if depth == 0
			return index + 1
		elseif depth == 1
			return '(' .. Lower_letter(index + 1) .. ')'
		elseif depth == 2
			return Roman_numeral(index + 1)
		elseif depth == 3
			return Upper_letter(index + 1)
		else
			return 'Error: invalid depth'
		endif
	enddef
	def GetLabel(): string
		var label: string
		var linenum: number
		linenum = v:foldstart - 1
		while linenum <= v:foldend
			linenum += 1
			line = getline(linenum)
			matches = matchlist(line, '\C\\label{\([^}]*\)}')
			if !empty(matches)
				label = matches[1]
				break
			endif
		endwhile
		if label !=# ''
			label = ': ' .. label
		endif
		return label
	enddef

	# format theorems/etc nicely {{{
	matches = matchlist(line, '\C\\begin{\([^}]*\)}\({\([^}]*\)}\)\?')
	if !empty(matches)
		if has_key(latex_types, matches[1])
			env = latex_types[matches[1]]
		else
			env = matches[1]
			if env ==# 'frame'
				env = '[' .. matches[3] .. ']'
			endif
		endif
		return foldtext#Base(env .. GetLabel())
	endif
	# }}}
	# format list items nicely {{{
	# XXX: nesting different types of lists doesn't give quite the correct
	# result - an enumerate inside an itemize inside an enumerate should use
	# (a), but here it will go back to using 1.
	if line =~# '\\item'
		var items: string
		var item_name: list<any>
		var item_depth: number
		var nesting: number
		var new_type: string
		for l in range(v:foldstart, 0, -1)
			line = getline(l)
			if line =~# '\\item'
				if nesting == 0
					items = matchstr(line, '\m\C\\item\[\zs[^]]*\ze\]')
					if len(item_name) == item_depth
						if items !=# ''
							item_name += [items]
						else
							item_name += [0]
						endif
					else
						if type(item_name[item_depth]) == 0 && items ==# ''
							item_name[item_depth] += 1
						endif
					endif
				endif
			elseif line =~# '\\begin{document}'
				break
			elseif line =~# '\\begin'
				if nesting > 0
					nesting -= 1
				else
					new_type = matchstr(line, '\m\C\\begin{\zs[^}]*\ze}')
					if env ==# ''
						env = new_type
					elseif env != new_type
						item_name = item_name[0 : -2]
						break
					endif
					item_depth += 1
				endif
			elseif line =~# '\\end'
				nesting += 1
			endif
		endfor
		# XXX: vim crashes if i just reverse the actual list
		# should be fixed in patch 7.1.287
		# let item_name = reverse(item_name)
		item_name = reverse(deepcopy(item_name))
		for i in range(len(item_name))
			if type(item_name[i]) != 1
				item_name[i] = Enumeration(i, item_name[i])
			endif
		endfor
		env = toupper(strpart(env, 0, 1)) .. strpart(env, 1)
		line = env .. ': ' .. join(item_name, '.')
		return foldtext#Base(line)
	endif
	# }}}
	# foormat section etc. {{{
	matches = matchlist(line, '\C\\\(\(sub\)\{0,2}\)section{\([^}]*\)}\({\([^}]*\)}\)\?')
	if !empty(matches)
		env = matches[1]
		if env == ''
			env = '§' .. matches[3]
		elseif env == 'sub'
			env = '§§' .. matches[3]
		elseif env == 'subsub'
			env = '§§§' .. matches[3]
		endif
		return foldtext#Base(env .. GetLabel())
	endif
	# }}}
	return foldtext#Base(line)
enddef

export def Cpp(): string # C++
	var line: string = getline(v:foldstart)
	# strip out // comments {{{
	var block_open: number = stridx(line, '/*')
	var line_open: number = stridx(line, '//')
	if block_open == -1 || line_open < block_open
		return foldtext#Base(substitute(line, '//', ' ', ''))
	endif
	# }}}
	return foldtext#Base(line)
enddef

export def Perl(): string # Perl
	var line: string = getline(v:foldstart)
	# format sub names with their arguments {{{
	var matches: list<string> = matchlist(line, '\m\C^\s*\(sub\|around\|before\|after\|guard\)\s*\(\w\+\)')
	var linenum: number
	var sub_type: string
	var params: list<string>
	var shift_line: list<string>
	var rest_line: list<string>
	var rest_params: list<string>
	var array_line: list<string>
	var hash_line: list<string>
	var next_line: string
	var Var: string
	var arg: string

	if !empty(matches)
		linenum = v:foldstart - 1
		sub_type = matches[1]
		params = []
		while linenum <= v:foldend
			linenum += 1
			next_line = getline(linenum)
			# skip the opening brace and comment lines and blank lines
			if next_line =~# '\s*{\s*' || next_line =~# '^\s*#' || next_line ==# ''
				continue
			endif

			# handle 'my $var = shift;' type lines
			Var = '\%(\$\|@\|%\|\*\)\w\+'
			shift_line = matchlist(next_line, '\m\cmy\s*\(' .. Var .. '\)\s*=\s*shift\%(\s*||\s*\(.\{-}\)\)\?;')
			if !empty(shift_line)
				if shift_line[1] ==# '$self' && empty(params)
					if sub_type ==# 'sub'
						sub_type = ''
					endif
					sub_type .= ' method'
				elseif shift_line[1] ==# '$class' && empty(params)
					if sub_type ==# 'sub'
						sub_type = ''
					endif
					sub_type .= ' static method'
				elseif shift_line[1] !=# '$orig'
					arg = shift_line[1]
					# also catch default arguments
					if shift_line[2] !=# ''
						arg .= ' = ' .. shift_line[2]
					endif
					params += [arg]
				endif
				continue
			endif

			# handle 'my ($a, $b) = @_;' type lines
			rest_line = matchlist(next_line, '\m\cmy\s*(\(.*\))\s*=\s*@_;')
			if !empty(rest_line)
				rest_params = split(rest_line[1], ',\s*')
				params += rest_params
				continue
			endif

			# handle 'my @args = @_;' type lines
			array_line = matchlist(next_line, '\m\cmy\s*\(@\w\+\)\s*=\s*@_;')
			if !empty(array_line)
				params += [array_line[1]]
				continue
			endif

			# handle 'my %args = @_;' type lines
			hash_line = matchlist(next_line, '\m\cmy\s*%\w\+\s*=\s*@_;')
			if !empty(hash_line)
				params += ['paramhash']
				continue
			endif

			# handle unknown uses of shift
			if next_line =~# '\%(\<shift\>\%(\s*@\)\@!\)'
				params += ['$unknown']
				continue
			endif

			# handle unknown uses of @_
			if next_line =~# '@_\>'
				params += ['@unknown']
				continue
			endif
		endwhile

		params = filter(params[0 : -2], 'strpart(v:val, 0, 1) !=# "@"') + [params[-1]]

		return foldtext#Base(sub_type .. ' ' .. matches[2] .. '(' .. join(params, ', ') .. ')')
	endif
	# }}}
	return foldtext#Base(line)
enddef
