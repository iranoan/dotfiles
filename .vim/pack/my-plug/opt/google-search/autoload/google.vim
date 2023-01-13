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
			let l:searchWord = strcharpart(getline(l:s_l), l:s_c, l:e_c - l:s_c)
		else
			let l:searchWord = strcharpart(getline(l:s_l), l:s_c)
			for l:s in getline(l:s_l + 1, l:e_l - 1)
				let l:searchWord ..= l:s
			endfor
			let l:searchWord ..= strcharpart(getline(l:e_l), 0, l:e_c)
		endif
		let l:searchWord = substitute(l:searchWord, '[ \t\n\r]\+', '+', 'g')
	else
		let l:searchWord = expand('<cword>')
	endif
	if l:searchWord  ==# ''
		return
	endif
	if has('unix')
		let l:result = system('xdg-open https://www.google.co.jp/search?q=' .. l:searchWord)
	elseif has('win32') || has('win32unix')
		let l:result = system('start https://www.google.co.jp/search?q=' .. l:searchWord)
	elseif has('mac')
		let l:result = system('open https://www.google.co.jp/search?q=' .. l:searchWord)
	endif
	echo 'Google search: ' .. l:searchWord
endfunction

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
