scriptencoding utf-8
" カーソル行に書かれたフォルダや関連付けられたアプリケーションで開く (URL またはフォルダは最後が/、ファイルは拡張子があること)

let s:save_cpo = &cpoptions
set cpoptions&vim

function open_uri#main()
	let line_str = getline('.')
	let m_end = 0
	let urls = []
	let only_urls = []
	while 1
		let [url, m_start, m_end] = matchstrpos(line_str, '\v<(((https?|ftp|gopher)://|(mailto|file|news):)[^][{}()'' \t<>"]+|(www|web|w3)[a-z0-9_-]*\.[a-z0-9._-]+\.[^][{}()'' \t<>"]+)[a-z0-9/]|(\~?/)?([-A-Za-z._0-9]+/)*[-A-Za-z._0-9]+(\.\a([A-Za-z0-9]{,3})|/)?', m_end)
		if m_start == -1
			break
		endif
		if url !~# '\v^(((https?|ftp|gopher)://|(mailto|file|news):)[^][{}()'' \t<>"]+|(www|web|w3)[a-z0-9_-]*\.[a-z0-9._-]+\.[^][{}()'' \t<>"]+)[a-z0-9/]'
			if glob(url) == ''
				continue
			endif
		elseif url =~# '\v^(www|web|w3)[a-z0-9_-]*\.[a-z0-9._-]+\.[^][{}()'' \t<>"]+[a-z0-9/]'
			let url = 'https://' .. url
		endif
		if index(only_urls, url) == -1
			call add(only_urls, url)
			call add(urls, [url, m_end])
		endif
	endwhile
	let i = len(urls)
	if i == 0
		echohl WarningMsg
		echo 'No URI found in line.'
		echohl None
		return
	endif
	let column = col('.')
	if i == 1
		let url = urls[0][0]
	elseif column != 1 && ( urls[len(urls)-1][1] > column )
		" カーソルが先頭ではなく、最後の URL/ファイル名より前に有る
		" カーソル位置か、すぐ後ろを開く
		for urls_i in urls
			if urls_i[1] > column
				let url = urls_i[0]
				break
			endif
		endfor
	else " メニュー表示で選択
		let item = 1
		let msg = ''
		for urls_i in urls
			let msg = msg .  item . ' ' . urls_i[0]. "\n"
			let item += 1
		endfor
		let item = input(msg . 'Select open URL/File [1-' . (item-1) . '] ')
		if item ==? ''
			return
		endif
		let url = urls[item - 1][0]
		redraw
	endif
	if url[0:1] ==? '~/'
		let url = expand(url)
	endif
	if getftype(url) ==# ''
		if match(url, '^[A-Za-z0-9_.+-]\+@[A-Za-z0-9.-]\+[a-z]\{2,\}$') == 0
			let url = 'mailto:' . url
		endif
	endif
	if has('unix')
		let result = system('xdg-open "' . url . '"')
	elseif has('win32') || has('win32unix')
		let result = system('start "' . url . '"')
	elseif has('mac')
		let result = system('open "' . url . '"')
	endif
	if result !=? ''
		echo result
	else
		echo 'open ' . url
	endif
	return
endfunction

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
