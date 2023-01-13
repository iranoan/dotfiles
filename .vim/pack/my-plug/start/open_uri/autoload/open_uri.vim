scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

function open_uri#main()
	let l:line_str = getline('.')
	let l:end = 0
	let l:urls = []
	let l:only_urls = []
	while 1
		let [l:url, l:start, l:end] = matchstrpos(l:line_str, '\m\C\([a-z]*://[^][ <>,;"''(){}]*\|\(mailto:\)\=[A-Za-z0-9_.+-]\+@[A-Za-z0-9.-]\+[a-z]\{2,\}\|\(\~\=/\)\=\([A-Za-z\.\-_0-9]\+/\)*[A-Za-z\.\-_0-9]\+\(\.\([A-Za-z]\{1,4\}\)\|/\)\)', l:end)
		if l:start == -1
			break
		endif
		if count(l:only_urls, l:url) == 0
			call add(l:only_urls, l:url)
			call add(l:urls, [l:url, l:end])
		endif
	endwhile
	let l:i = len(l:urls)
	if l:i == 0
		echohl WarningMsg
		echo 'No URI found in line.'
		echohl None
		return
	endif
	let l:col = col('.')
	if l:i == 1
		let l:url = l:urls[0][0]
	elseif l:col != 1 && ( l:urls[len(l:urls)-1][1] > l:col )
		" カーソルが先頭ではなく、最後の URL/ファイル名より前に有る
		" カーソル位置か、すぐ後ろを開く
		for l:url in l:urls
			if l:url[1] > l:col
				let l:url = l:url[0]
				break
			endif
		endfor
	else " メニュー表示で選択
		let l:index = 1
		let l:msg = ''
		for l:url in l:urls
			let l:msg = l:msg .  l:index . ' ' . l:url[0]. "\n"
			let l:index += 1
		endfor
		let l:index = input(l:msg . 'Select open URL/File [1-' . (l:index-1) . '] ')
		if l:index ==? ''
			return
		endif
		let l:url = l:urls[l:index - 1][0]
		redraw
	endif
	if l:url[0:1] ==? '~/'
		let l:url = expand(l:url)
	endif
	if getftype(l:url) ==# ''
		if match(l:url, '^[A-Za-z0-9_.+-]\+@[A-Za-z0-9.-]\+[a-z]\{2,\}$') == 0
			let l:url = 'mailto:' . l:url
		endif
	endif
	if has('unix')
		let l:result = system('xdg-open "' . l:url . '"')
	elseif has('win32') || has('win32unix')
		let l:result = system('start "' . l:url . '"')
	elseif has('mac')
		let l:result = system('open "' . l:url . '"')
	endif
	if l:result !=? ''
		echo l:result
	else
		echo 'open ' . l:url
	endif
	return
endfunction

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
