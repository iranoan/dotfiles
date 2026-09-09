vim9script
scriptencoding utf-8
# カーソル行に書かれたフォルダや関連付けられたアプリケーションで開く (URL またはフォルダは最後が/、ファイルは拡張子 (4文字まで) があること)

def WarningMessage(): void
	popup_create('No URI found in line.', {
		col: 'cursor',
		line: 'cursor+1',
		time: 3000,
		zindex: 300,
		highlight: 'WarningMsg',
		padding: [0, 1, 0, 1],
		border: [1, 1, 1, 1],
		borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
		close: 'click',
		filter: (id, key) => {
			if key != ''
				popup_close(id)
			endif
			return true
		}
	})
enddef

# URL/パスを開く共通処理
def ExecuteOpen(raw_url: string): void
	var url = raw_url
	if url =~? '^\~/'
		url = expand(url)
	endif
	if match(url, '^[A-Za-z0-9_.+-]\+@[A-Za-z0-9.-]\+[a-z]\{2,}$') == 0
		url = $'mailto:{url}'
	endif
	dist#vim9#Open(url)
enddef

export def Open(): bool
	var line_str: string = getline('.')
	var m_start: number
	var m_end: number
	var urls: list<dict<any>>
	var url: string
	var count: number
	var cur_col: number
	var exact_matches: list<dict<any>>
	var msg: list<string>
	var idx: number = 1
	var link: string

	while true # 行内のすべての Candidate (URL/メール/パス) を抽出
		[url, m_start, m_end] = matchstrpos(line_str,
			'\%(<[Ii][Mm][Gg]\s\+[^>]*\s*[Ss][Rr][Cc]=["''][^"'']\+["''][^>]*>[^<]\+<\|<[Aa]\s\+[^>]*\s*[Hh][Rr][Ee][Ff]=["''][^"'']\+["''][^>]*>[^<]\+<\|\[[^]]\+]([^)]\+)\|\<\%(\%(\%(https\=\|ftp\|gopher\)://\|\%(mailto\|file\|news\):\)[^][{}()'' \t<>"]\+\|\%(www\|web\|w3\)[A-Za-z0-9_-]*\.[A-Za-z0-9._-]\+\.[^][{}()'' \t<>"]\+\)[A-Za-z0-9/]\|\%(\~\=/\)\=\%([-A-Za-z._0-9]\+/\)*[-A-Za-z._0-9]\+\%(\.\a\%([A-Za-z0-9]\{,4}\)\|/\)\=\)',
			m_end
		)
		if m_start == -1
			break
		elseif m_start == m_end
			m_end += 1
		endif
		link = url
		if url =~? '^<img'
			[url, link] = matchlist(url, '\c<img\s\+[^>]*\s*src=["'']\([^"'']\+\)["''][^>]*>\([^<]\+\)<')[1 : 2]
		elseif url =~? '^<a'
			[url, link] = matchlist(url, '\c<a\s\+[^>]*\s*href=["'']\([^"'']\+\)["''][^>]*>\([^<]\+\)<')[1 : 2]
		elseif url =~? '^\['
			[link, url] = matchlist(url, '\[\([^]]\+\)](\([^)]\+\))')[1 : 2]
		elseif url !~# '^\%(\%(\%(https\=\|ftp\|gopher\)://\|\%(mailto\|file\|news\):\)[^][{}()'' \t<>"]\+\|\%(www\|web\|w3\)[a-z0-9_-]*\.[A-Za-z0-9._-]\+\.[^][{}()'' \t<>"]\+\)[A-Za-z0-9/]' # URL でない
			&& glob(url) == '' # 存在するパスでもない
			continue
		elseif url =~# '^\%(www\|web\|w3\)[a-z0-9_-]*\.[A-Za-z0-9._-]\+\.[^][{}()'' \t<>"]\+[A-Za-z0-9/]'
			url = $'https://{url}'
		endif
		add(urls, {link: link, url: url, start: m_start + 1, end: m_end})
	endwhile
	sort(urls, (i, j) => i.url <= j.url ? -1 : 1)
		->uniq((i, j) => i.url ==# j.url ? 0 : 1)
		->sort((i, j) => i.start - j.start)
	count = len(urls)
	if count == 0
		WarningMessage()
		return false
	elseif count == 1 # URL が1つだけならそのまま開く
		ExecuteOpen(urls[0].url)
		return true
	endif
	cur_col = col('.')
	if cur_col != 1 # カーソル位置 (バイト単位) を取得して、カーソル直下にある URL を検索←ただし行頭では無条件で、次のリスト表示に移る
		exact_matches = filter(copy(urls), (_, v) => v.start <= cur_col && cur_col <= v.end)
		if len(exact_matches) > 0 # カーソル位置に直接重なっている URL があればそれを即座に開く
			ExecuteOpen(exact_matches[0].url)
			return true
		endif
	endif
	for u in urls # 複数ある場合のポップアップ要素を作成
		add(msg, $'[{idx}]. {u.link}')
		idx += 1
	endfor
	add(msg, $'[<Esc>/<C-c>/c/x] Cancel')
	popup_create(msg, {
		title: 'Select Open URL',
		col: 'cursor',
		line: 'cursor+1',
		zindex: 200,
		wrap: false,
		cursorline: true,
		padding: [0, 1, 0, 1],
		border: [1, 1, 1, 1],
		borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
		filter: (id, key) => {
			if key =~? '[qc]'
				popup_close(id, -1) # キャンセルは -1 を返す
				return true
			elseif key =~# '[1-9]' && str2nr(key) <= count
				popup_close(id, str2nr(key))
				return true
			elseif key =~# '0' && str2nr(key) <= count
				popup_close(id, 10)
				return true
			else
				return popup_filter_menu(id, key)
			endif
		},
		mapping: false,
		callback: (id, result) => {
			if type(result) != v:t_number || result <= 0 || result > count # キャンセル (-1 や Esc/0) の場合は何もしない
				return
			endif
			ExecuteOpen(urls[result - 1].url)
		}
	})
	return true
enddef
