scriptencoding utf-8
scriptversion 4

function! foldtext#base(...) abort
	" use the argument for display if possible, otherwise the current line
	if a:0 > 0
		let line = a:1
	else
		let line = getline(v:foldstart)
	endif
	" remove the marker that caused this fold from the display
	let foldmarkers = split(&foldmarker, ',')
	let line = substitute(line, '\V' .. foldmarkers[0] .. '\%(\d\+\)\?', ' ', '')
	let comment = &commentstring
	if comment !=# ''
		let comment = escape(comment, '.$*~\')->substitute('%s', '\\(.\\{-}\\)', '')
		let line = substitute(line, comment, '\1', '')
	endif
	" remove any remaining leading or trailing whitespace
	let line = substitute(line, '^\s*\(.\{-}\)\s*$', '\1', '')

	let cnt = printf('[%' .. len(line('$')) .. 's] ', (v:foldend - v:foldstart + 1))
	let line_width = winwidth(0) - &foldcolumn

	if &number
		let line_width -= max([&numberwidth, len(line('$'))])
	" sing の表示非表示でずれる分の補正
	elseif &signcolumn ==# 'number'
		let cnt = cnt .. '  '
	endif
	if &signcolumn ==# 'auto'
		let cnt = cnt .. '  '
	endif
	let line_width -= 2 * (&signcolumn ==# 'yes')

	let line = strcharpart(printf('%-' .. ( &shiftwidth * (v:foldlevel-1)+2) .. 's%s', '▸', line), 0, line_width-len(cnt))
	" 全角文字を使っていると、幅でカットすると広すぎる
	" だからといって strcharpart() の代わりに strpart() を使うと、逆に余分にカットするケースが出てくる
	" ↓末尾を 1 文字づつカットしていく
	while strdisplaywidth(line) > line_width-len(cnt)
		let line = slice(line, 0, -1)
	endwhile
	return printf('%s%' .. (line_width-strdisplaywidth(line)) .. 'S', line, cnt)
endfunction

" Latex {{{
let s:latex_types = {'thm': 'Theorem', 'cor': 'Corollary',
			\ 'lem': 'Lemma', 'defn': 'Definition'}

function! s:lower_letter(i) " {{{
	return tolower(s:upper_letter(a:i))
endfunction " }}}

function! s:roman_numeral(i)
	let numeral = ''
	let chars = 'ivxlcdm'
	let i = a:i
	for base in [0, 2, 4]
		let c1 = strpart(chars, base, 1)
		let c5 = strpart(chars, base + 1, 1)
		let c10 = strpart(chars, base + 2, 1)
		let digit = i % 10
		if digit == 1
			let numeral = c1 .. numeral
		elseif digit == 2
			let numeral = c1 .. c1 .. numeral
		elseif digit == 3
			let numeral = c1 .. c1 .. c1 .. numeral
		elseif digit == 4
			let numeral = c1 .. c5 .. numeral
		elseif digit == 5
			let numeral = c5 .. numeral
		elseif digit == 6
			let numeral = c5 .. c1 .. numeral
		elseif digit == 7
			let numeral = c5 .. c1 .. c1 .. numeral
		elseif digit == 8
			let numeral = c5 .. c1 .. c1 .. c1 .. numeral
		elseif digit == 9
			let numeral = c1 .. c10 .. numeral
		endif
		let i = i / 10
		if i == 0
			break
		end
	endfor
	return repeat('m', i) .. numeral
endfunction

function! s:upper_letter(i)
	if a:i <= 26
		return nr2char(char2nr('A') + a:i - 1)
	else
		return 'ERROR'
	endif
endfunction

function! s:enumeration(depth, index)
	if a:depth == 0
		return a:index + 1
	elseif a:depth == 1
		return '(' .. s:lower_letter(a:index + 1) .. ')'
	elseif a:depth == 2
		return s:roman_numeral(a:index + 1)
	elseif a:depth == 3
		return s:upper_letter(a:index + 1)
	else
		return 'Error: invalid depth'
	endif
endfunction

function! foldtext#latex()
	let line = getline(v:foldstart)
	" format theorems/etc nicely {{{
	let matches = matchlist(line, '\m\C\\begin{\([^}]*\)}')
	if !empty(matches) && has_key(s:latex_types, matches[1])
		let type = s:latex_types[matches[1]]
		let label = ''
		let linenum = v:foldstart - 1
		while linenum <= v:foldend
			let linenum += 1
			let line = getline(linenum)
			let matches = matchlist(line, '\m\C\\label{\([^}]*\)}')
			if !empty(matches)
				let label = matches[1]
				break
			endif
		endwhile
		if label !=# ''
			let label = ': ' .. label
		endif
		return foldtext#base(type .. label)
	endif
	" }}}
	" format list items nicely {{{
	" XXX: nesting different types of lists doesn't give quite the correct
	" result - an enumerate inside an itemize inside an enumerate should use
	" (a), but here it will go back to using 1.
	if line =~# '\\item'
		let item_name = []
		let item_depth = 0
		let nesting = 0
		let type = ''
		for linenum in range(v:foldstart, 0, -1)
			let line = getline(linenum)
			if line =~# '\\item'
				if nesting == 0
					let label = matchstr(line, '\m\C\\item\[\zs[^]]*\ze\]')
					if len(item_name) == item_depth
						if label !=# ''
							let item_name += [label]
						else
							let item_name += [0]
						endif
					else
						if type(item_name[item_depth]) == type(0) && label ==# ''
							let item_name[item_depth] += 1
						endif
					endif
				endif
			elseif line =~# '\\begin{document}'
				break
			elseif line =~# '\\begin'
				if nesting > 0
					let nesting -= 1
				else
					let new_type = matchstr(line, '\m\C\\begin{\zs[^}]*\ze}')
					if type ==# ''
						let type = new_type
					elseif type != new_type
						let item_name = item_name[0:-2]
						break
					endif
					let item_depth += 1
				endif
			elseif line =~# '\\end'
				let nesting += 1
			endif
		endfor
		" XXX: vim crashes if i just reverse the actual list
		" should be fixed in patch 7.1.287
		"let item_name = reverse(item_name)
		let item_name = reverse(deepcopy(item_name))
		for i in range(len(item_name))
			if type(item_name[i]) != type('')
				let item_name[i] = s:enumeration(i, item_name[i])
			endif
		endfor
		let type = toupper(strpart(type, 0, 1)) .. strpart(type, 1)
		let line = type .. ': ' .. join(item_name, '.')
		return foldtext#base(line)
	endif
	" }}}
	return foldtext#base(line)
endfunction
" }}}

function! foldtext#cpp() " C++
	let line = getline(v:foldstart)
	" strip out // comments {{{
	let block_open = stridx(line, '/*')
	let line_open = stridx(line, '//')
	if block_open == -1 || line_open < block_open
		return foldtext#base(substitute(line, '//', ' ', ''))
	endif
	" }}}
	return foldtext#base(line)
endfunction

function! foldtext#perl() " Perl
	let line = getline(v:foldstart)
	" format sub names with their arguments {{{
	let matches = matchlist(line, '\m\C^\s*\(sub\|around\|before\|after\|guard\)\s*\(\w\+\)')
	if !empty(matches)
		let linenum = v:foldstart - 1
		let sub_type = matches[1]
		let params = []
		while linenum <= v:foldend
			let linenum += 1
			let next_line = getline(linenum)
			" skip the opening brace and comment lines and blank lines
			if next_line =~# '\s*{\s*' || next_line =~# '^\s*#' || next_line ==# ''
				continue
			endif

			" handle 'my $var = shift;' type lines
			let var = '\%(\$\|@\|%\|\*\)\w\+'
			let shift_line = matchlist(next_line, '\m\cmy\s*\(' .. var .. '\)\s*=\s*shift\%(\s*||\s*\(.\{-}\)\)\?;')
			if !empty(shift_line)
				if shift_line[1] ==# '$self' && empty(params)
					if sub_type ==# 'sub'
						let sub_type = ''
					endif
					let sub_type .= ' method'
				elseif shift_line[1] ==# '$class' && empty(params)
					if sub_type ==# 'sub'
						let sub_type = ''
					endif
					let sub_type .= ' static method'
				elseif shift_line[1] !=# '$orig'
					let arg = shift_line[1]
					" also catch default arguments
					if shift_line[2] !=# ''
						let arg .= ' = ' .. shift_line[2]
					endif
					let params += [l:arg]
				endif
				continue
			endif

			" handle 'my ($a, $b) = @_;' type lines
			let rest_line = matchlist(next_line, '\m\cmy\s*(\(.*\))\s*=\s*@_;')
			if !empty(rest_line)
				let rest_params = split(rest_line[1], ',\s*')
				let params += rest_params
				continue
			endif

			" handle 'my @args = @_;' type lines
			let array_line = matchlist(next_line, '\m\cmy\s*\(@\w\+\)\s*=\s*@_;')
			if !empty(array_line)
				let params += [array_line[1]]
				continue
			endif

			" handle 'my %args = @_;' type lines
			let hash_line = matchlist(next_line, '\m\cmy\s*%\w\+\s*=\s*@_;')
			if !empty(hash_line)
				let params += ['paramhash']
				continue
			endif

			" handle unknown uses of shift
			if next_line =~# '\%(\<shift\>\%(\s*@\)\@!\)'
				let params += ['$unknown']
				continue
			endif

			" handle unknown uses of @_
			if next_line =~# '@_\>'
				let params += ['@unknown']
				continue
			endif
		endwhile

		let params = filter(params[0:-2], 'strpart(v:val, 0, 1) !=# "@"') + [params[-1]]

		return foldtext#base(sub_type .. ' ' .. matches[2] .. '(' .. join(params, ', ') .. ')')
	endif
	" }}}
	return foldtext#base(line)
endfunction
