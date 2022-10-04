scriptencoding utf-8

function hook_function#main(from_f, to_f, function)
	" from_f:   置き換え元の関数が書かれたパスの末尾
	" to_f:     置き換え先の関数が書かれたパスの末尾
	" funcname: 関数名
	call s:hook_func(s:get_func(a:from_f, a:function), s:get_func(a:to_f, a:function))
endfunction

function s:get_func(fname, funcname) " https://mattn.kaoriya.net/software/vim/20090826003359.htm を参考にした
	" fname:    関数が書かれたパスの末尾
	" funcname: 関数名
	let snlist = filter(split(execute('silent! scriptnames'), "\n"), 'v:val =~# "/' .. a:fname .. '$"' )[0]
	let snlist = substitute(snlist,  '^\s*\(\d\+\):\s*\(.*\)$', '\1', '')
	return function('<SNR>' .. snlist .. '_' .. a:funcname)
endfunction

function s:hook_func(funcA, funcB) " https://mattn.kaoriya.net/software/vim/20090826003359.htm を参考にした
	" funcA: 置き換え元の関数名
	" funcB: 置き換え先の関数名
	if type(a:funcA) == 2
		let funcA = substitute(string(a:funcA), "^function('\\(.*\\)')$", '\1', '')
	else
		let funcA = a:funcA
	endif
	if type(a:funcB) == 2
		let funcB = substitute(string(a:funcB), "^function('\\(.*\\)')$", '\1', '')
	else
		let funcB = a:funcB
	endif
	exec "function! " .. funcA .. "(...)\nreturn call('" .. funcB .. "', a:000)\nendfunction"
endfunction
