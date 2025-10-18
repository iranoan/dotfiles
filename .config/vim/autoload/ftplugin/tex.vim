vim9script

export def XBB(): void # カーソル位置のパスの ebb -x -O の出力の一部 (ファイル名と HiResBoundingBox) を書き込む
	var line_str = getline('.')
	var m_end = 0
	var urls: list<any>
	var url: string
	var m_start: number
	while 1
		[url, m_start, m_end] = matchstrpos(line_str, '\m\C\(\~\=/\)\=\([A-Za-z\.\-_0-9]\+/\)*[A-Za-z\.\-_0-9]\+\.[A-Za-z]\{1,4\}', m_end)
		if m_start == -1
			break
		endif
		add(urls, [url, m_start, m_end])
	endwhile
	var col = col('.')
	for i in urls
		if i[1] < col + 1 && i[2] >= col - 1
			# カーソル位置は開始位置は一つ前、終了位置は一つ後でも許容範囲とする
			# TeX で画像を扱う時は、\includegraphics{graphic-path} と {} で挟むことが多いから
			url = i[0]
			if getftype(url) ==# ''
				echohl WarningMsg
				echo 'Not exist: ' .. url
				echohl None
				return
			elseif !filereadable(url)
				echohl WarningMsg
				echo 'Not readable ' .. url
				echohl None
				return
			endif
			var l = line('.')
			append(l, matchstr(getline(l), '^\s*') .. systemlist('ebb -x -O ' .. url)[3])
			return
		endif
	endfor
	echohl WarningMsg
	echo 'cursor postion do not write path.'
	echohl None
enddef
