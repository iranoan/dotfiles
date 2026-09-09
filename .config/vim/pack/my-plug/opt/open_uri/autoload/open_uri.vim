vim9script
scriptencoding utf-8
# カーソル行に書かれたフォルダや関連付けられたアプリケーションで開く (URL またはフォルダは最後が/、ファイルは拡張子 (4文字まで) があること)

export def Open(): void
	var line_str: string = getline('.')
	var m_start: number
	var m_end: number
	var urls: list<list<any>>
	var only_urls: list<string>
	var url: string
	var i: number
	var column: number
	var item: number
	var msg: string

	while true
		[url, m_start, m_end] = matchstrpos(line_str, '\<\%(\%(\%(https\=\|ftp\|gopher\)://\|\%(mailto\|file\|news\):\)[^][{}()'' \t<>"]\+\|\%(www\|web\|w3\)[A-Za-z0-9_-]*\.[A-Za-z0-9._-]\+\.[^][{}()'' \t<>"]\+\)[A-Za-z0-9/]\|\%(\~\=/\)\=\%([-A-Za-z._0-9]\+/\)*[-A-Za-z._0-9]\+\%(\.\a\%([A-Za-z0-9]\{,4}\)\|/\)\=', m_end)
		if m_start == -1
			break
		endif
		if url !~# '^\%(\%(\%(https\=\|ftp\|gopher\)://\|\%(mailto\|file\|news\):\)[^][{}()'' \t<>"]\+\|\%(www\|web\|w3\)[a-z0-9_-]*\.[A-Za-z0-9._-]\+\.[^][{}()'' \t<>"]\+\)[A-Za-z0-9/]'
			if glob(url) == ''
				continue
			endif
		elseif url =~# '^\%(www\|web\|w3\)[a-z0-9_-]*\.[A-Za-z0-9._-]\+\.[^][{}()'' \t<>"]\+[A-Za-z0-9/]'
			url = $'https://{url}'
		endif
		if index(only_urls, url) == -1
			call add(only_urls, url)
			call add(urls, [url, m_end])
		endif
	endwhile
	i = len(urls)
	if i == 0
		echohl WarningMsg
		echo 'No URI found in line.'
		echohl None
		return
	endif
	column = col('.')
	if i == 1
		url = urls[0][0]
	elseif column != 1 && ( urls[len(urls) - 1][1] > column )
		# カーソルが先頭ではなく、最後の URL/ファイル名より前に有る
		# カーソル位置か、すぐ後ろを開く
		for urls_i in urls
			if urls_i[1] > column
				url = urls_i[0]
				break
			endif
		endfor
	else # メニュー表示で選択
		item = 1
		msg = ''
		for urls_i in urls
			msg = $"{msg}{item}. {urls_i[0]}\n"
			item += 1
		endfor
		item = input($'{msg}Select open URL/File [1-{item - 1}] ')->str2nr()
		if item == 0
			return
		endif
		url = urls[item - 1][0]
		redraw
	endif
	if url[0 : 1] ==? '~/'
		url = expand(url)
	endif
	if getftype(url) ==# ''
		if match(url, '^[A-Za-z0-9_.+-]\+@[A-Za-z0-9.-]\+[a-z]\{2,\}$') == 0
			url = $'mailto:{url}'
		endif
	endif
	dist#vim9#Open(url)
	return
enddef
