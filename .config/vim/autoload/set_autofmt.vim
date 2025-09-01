scriptencoding utf-8

function set_autofmt#main() abort
	packadd autofmt
	" :help autofmt-customize
	" Customize Line Break Property
	let s:unicode = autofmt#unicode#import()
	let s:orig_prop_line_break = s:unicode.prop_line_break
	function! s:unicode.prop_line_break(char)
		if     a:char == "\u201C" || a:char == "\u2018" || a:char == "\u300C" || a:char == "\u300E"
			" “‘「『
			return 'OP'   " Open Punctuation
		elseif a:char == "\u201D" || a:char == "\u2019" || a:char == "\u300D" || a:char == "\u300F" || a:char == "\u3001"
			" ”’」』、。
			return 'CL'   " Close Punctuation
		endif
		return call(s:orig_prop_line_break, [a:char], self)
	endfunction
	" let &formatlistpat='^\s*\d\+[:.\t ]\s*' " ←規定なので不要
	setlocal formatexpr=autofmt#uax14#formatexpr():
	" setlocal formatexpr=autofmt#japanese#formatexpr()

	augroup PlugAutofmtTEXT
		autocmd!
		" autocmd FileType text,mail,notmuch-edit setlocal formatexpr=autofmt#japanese#formatexpr()
		autocmd FileType text,mail,notmuch-edit setlocal formatexpr=autofmt#uax14#formatexpr()
	augroup END
	call timer_start(1, {->execute('delfunction set_autofmt#main')})
endfunction
