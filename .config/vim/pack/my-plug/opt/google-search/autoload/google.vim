scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

" カーソル下の単語をGoogleで検索する
function google#search_by_google(range) range abort
	if a:range > 0
		let l:s_l = getcharpos("'<")[1]
		let l:e_l = getcharpos("'>")[1]
		let l:s_c = getcharpos("'<")[2] - 1
		let l:e_c = getcharpos("'>")[2]
		if l:s_l == l:e_l
			let l:msgWord = strcharpart(getline(l:s_l), l:s_c, l:e_c - l:s_c)
		else
			let l:msgWord = strcharpart(getline(l:s_l), l:s_c)
			for l:s in getline(l:s_l + 1, l:e_l - 1)
				let l:msgWord ..= l:s
			endfor
			let l:msgWord ..= strcharpart(getline(l:e_l), 0, l:e_c)
		endif
	else
		let l:msgWord = expand('<cword>')
	endif
	if l:msgWord  ==# ''
		return
	endif
	let l:searchWord = substitute(l:msgWord, '[ \n\r]', '+', 'g')->substitute('+$', '', 'g')->escape('|&;(){}#$"''\')
	if has('unix')
		let l:result = system('xdg-open https://www.google.co.jp/search?q=' .. l:searchWord)
	elseif has('win32') || has('win32unix')
		let l:result = system('start https://www.google.co.jp/search?q=' .. l:searchWord)
	elseif has('mac')
		let l:result = system('open https://www.google.co.jp/search?q=' .. l:searchWord)
	endif
	echo 'Google search: ' .. l:msgWord
endfunction

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
