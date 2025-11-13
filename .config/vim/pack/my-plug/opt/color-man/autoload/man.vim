vim9script

export def ColorMan(mod: string, ...args: list<string>)
	var topic: list<string>
	var opt: list<string>

	def GetCmd(): list<any>
		var cmd: string
		var sec: number = 0

		def Parse(arg: string): void # 'man(7)' man(7) "man(7)" man.7 をパース
			var sec_sb: string
			var sec_sp: string

			if matchlist(arg, '^\([''"]\)\=\([][A-Za-z0-9_:.+@-]\+\)\%((\(\d\))\|\.\(\d\)\)\=\1') == []
				cmd = arg
				return
			endif
			[cmd, sec_sb, sec_sp] = matchlist(arg, '^\([''"]\)\=\([][A-Za-z0-9_:.+@-]\+\)\%((\(\d\))\|\.\(\d\)\)\=\1')[2 : 4]
			if sec_sb !=# ''
				sec = str2nr(sec_sb)
			elseif sec_sp !=# ''
				sec = str2nr(sec_sp)
			endif
			return
		enddef

		if len(topic) == 0
			cmd = 'man'
		elseif len(topic) == 1
			Parse(topic[0])
		elseif len(topic) == 2
			sec = str2nr(topic[1])
			if '' .. sec ==# topic[1] # 数値変換後も元の文字列と同じ
					&& (sec >= 1 && sec <= 9) # セクションとコマンドが逆扱いにする
				cmd = topic[0]
			else
				# sec = str2nr(topic[0])
				# if '' .. sec !=# topic[0] || sec < 1 || sec > 9
				cmd = topic[1]
			endif
		else
			return []
		endif

		if opt == []
			return [
				sec == 0 ? cmd : sec .. ' ' .. cmd,
				$HOME .. '/' .. cmd .. '.' .. (sec == 0 ? '' : sec) .. '~'
			]
		else
			return [
				join(opt) .. ' ' .. (sec == 0 ? cmd : sec .. ' ' .. cmd),
				$HOME .. '/' .. cmd .. ' ' .. join(opt) .. '.' .. (sec == 0 ? '' : sec) .. '~'
			]
		endif
	enddef

	def OpenWay(name: string): string # ウィンドウの開き方
		var bufnr: number
		var man_buf: number = (getbufinfo()->filter((_, v) => v.name == name) + [{bufnr: 0}])[0].bufnr
		var windows: list<number> = gettabinfo(tabpagenr())[0].windows
		# 開き方の指定有り
		if mod =~# '\<tab\>'
			return 'tabedit '
		elseif mod =~ '\<\(vert\%[ical]\|hor\%[izontal]\)\>'
			return mod .. ' split '
		endif
		# 開き方の指定無し
		if index(tabpagebuflist(), man_buf) != -1 # 指定した man のウィンドウがカレント・タブ・ページに有る→探して移動だけ
			for w in getbufinfo(man_buf)[0].windows
				if index(windows, w) != -1
					win_gotoid(w)
					return ''
				endif
			endfor
		endif
		for W in windows # &filetype == 'man' のウィンドウが有るか?
			bufnr = winbufnr(W)
			if getbufvar(bufnr, '&filetype') ==# 'man' # 見つかった
				for w in getbufinfo(bufnr)[0].windows
					if index(windows, w) != -1
						win_gotoid(w)
						if man_buf != 0 # 指定した man のバッファも有った
							execute 'buffer ' .. man_buf
							return ''
						else
							return 'edit '
						endif
					endif
				endfor
			endif
		endfor
		if exists("g:ft_man_open_mode")
			if g:ft_man_open_mode == 'vert'
				return 'vsplit '
			elseif g:ft_man_open_mode == 'tab'
				return 'tabedit '
			else
				return 'split '
			endif
		else
			return 'split '
		endif
	enddef

	def GetOpt(): void
		var argv: number = len(args)
		var i: number = -1
		var s: string

		while i < argv
			i += 1
			s = args[i]
			# 無視するオプション
			if args[i] =~# '\(-H[^ ]*\|--html\(=[^ ]\+\)\=\|--pager\(=[^ ]\+\)\=\|-T[^ ]*\|--troff-device\(=[^ ]\+\)\=\|-X[^ ]*\|--gxdietview\(=[^ ]\+\)\=\|-W\|--where-cat\|--location-cat-w\|--where\|--path\|--location-Z\|--ditroff\)'
				i += 1
			elseif args[i] ==# '-P' # P pager
				i += 2
			elseif s =~# '^-[CELMRSsempr]' # 引数有りのプション
				add(opt, s .. ' ' .. args[i + 1])
				i += 2
			elseif s =~# '^-' # オプション
				add(opt, s)
				i += 1
			else
				add(topic, s)
				i += 1
			endif
		endwhile
	enddef

	var cmd: string # man コマンドに渡す引数
	var name: string # 仮のバッファ名

	GetOpt()
	[cmd, name] = GetCmd()
	var open: string = OpenWay(name)
	if open ==# ''
		return
	endif
	var width: number = (&columns / (open =~# '\<\(vert\%[ical]\|vsplit\)\>' ? 2 : 1) - ( &number ? 3 : 0 ) - &foldcolumn - ( &signcolumn !=# 'no' ? 1 : 0 ) - 2)
	var max_width: number = get(g:, 'ft_man_max_width', 100)

	if max_width > 0 && width > max_width
		width = max_width
	endif

	var out: list<string> = systemlist('MANWIDTH=' .. width .. ' MANPAGER=cat MAN_KEEP_FORMATTING=1 man ' .. cmd .. ' 2> /dev/null')
		->map((_, v) => v->substitute('[\r \t]\+$', '', ''))
	if out == []
		var err: list<string> = systemlist('man ' .. cmd)->map((_, v) => v->substitute('[\r \t]\+$', '', ''))
		if has('popupwin')
			popup_notification(err, {borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'], pos: 'center'})
		else
			echohl WarningMsg
			for s in err
				echomsg s
			endfor
			echohl None
		endif
		return
	endif
	execute open .. name
	setlocal buftype=nofile noswapfile
	setlocal filetype=man
	setlocal modifiable

	append(0, out)
	keepjumps :$delete
	setpos('.', [0, 1, 1, 0])

	setlocal nomodifiable
enddef

export def Jump(): void
	var l: string = getline('.')
	var s: string
	var b: number
	var e: number
	var c: number = col('.')
	while true
		[s, b, e] = matchstrpos(l, '\%(\e\[\d\+m\)*\([-A-Za-z0-9_]\+\)\s*\%(\e\[\d\+m\)*\%((\(\e\[\d\+m\)*\d\(\e\[\d\+m\)*)\|\.\(\e\[\d\+m\)*\d\(\e\[\d\+m\)*\)*', e)
		e -= len(matchstr(s, '\e\[\dm\(\e\[\d\+m\)*')) # 末尾に \e[\dm (\d:1桁) が有れば、次のキーワードの始まり部分
		if b == -1 || b > c
			break
		elseif e >= c # && b <= c
			s = substitute(s, '\e\[\d\+m', '', 'g')->substitute('\s\+$', '', '')
			break
		endif
	endwhile
	if s !~# '-' && system('man ' .. s .. ' 2> /dev/null') != ''
		ColorMan('', s)
	else
		search('\C^\s*\%(\e\[1m\%(\w\+\|\%(-\w\|--[A-Za-z_-]\+\)\%(\%([ =]\|\e\[\d\+m\)\+\%([][,.A-Za-z_-]\|\e\[\d\+m\)\+\)\=\)\%(\e\[\d\+m\)\=, *\)*\e\[1m\zs' .. s, 'csw')
		# c = line('.')
		# b = search('\C^\s*\%(\e\[1m\%(\w\+\|\%(-\w\|--[A-Za-z_-]\+\)\%(\%([ =]\|\e\[\d\+m\)\+\%([][,.A-Za-z_-]\|\e\[\d\+m\)\+\)\=\)\%(\e\[\d\+m\)\=, *\)*\e\[1m\zs' .. s, 'csw')
		# if b == 0 # || b == c
		# 	ColorMan('', s)
		# endif
	endif
enddef

export def Tag(f: bool): void
	search('\C\e\[[14]m\%(\e\[\d\+m\)*\zs[/_.A-Za-z0-9-]', 'w' .. (f ? 'b' : 'cz'))
enddef

export def SearchWord(f: bool): void # ANCI escape code も含める形でカーソル位置の単語を見かけ上の表記で単語検索する
	# *, # と違い、カーソル位置が iskeyword による単語でない場合は、何もしない
	var l: string = getline('.')
	var s: string
	var b: number
	var e: number
	var pos: list<number> = getpos('.')
	var c: number = pos[2]
	while true
		[s, b, e] = matchstrpos(l, '\%(\e\[\d\+m\|\<\)\w\+\>', e)
		if b == -1 || b > c
			return
		elseif e >= c # && b <= c
			break
		endif
	endwhile
	s = substitute(s, '^\e\[\d\+m', '', '')
	if f # feedkeys() で nt mode を使わないと、n, N 使用時の方向を変えられない
		feedkeys('?\c\%(\e\[\d\+m\|\<\)\zs' .. s .. "\\>\<CR>", 'nt')
	else
		feedkeys('/\c\%(\e\[\d\+m\|\<\)\zs' .. s .. "\\>\<CR>", 'nt')
	endif
enddef

export def Fold(): string
	var s: string
	var b: number
	var ec: number
	var en: number
	var lc: string = getline(v:lnum)
	var ln: string = getline(v:lnum + 1)
	if match(lc, '^\e\[4m[A-Z0-9_:.+@-]\+\e\[24m(\d).\{-}\e\[4m[A-Z0-9_:.+@-]\+\e\[24m(\d)') == 0
		return '>1'
	endif
	[s, b, ec] = matchstrpos(lc, '^\s\{,7}\e\ze\[\dm')
	if ec == -1
		return '='
	elseif ec == 1
		return '>2'
	endif
	[s, b, en] = matchstrpos(ln, '^\s*.')
	if (ec != matchstrpos(getline(v:lnum - 1), '^\s*')[2] + 1) && (ec < en || ln ==# '')
		return '>' .. (ec / 4 + 2)
	endif
	return '='
enddef

export def FoldText(): string
	return substitute(getline(v:foldstart), '\e\[\d\+m', '', 'g')
enddef

export def Complete(argc: string, cmd: string, cur: number): list<string>
	var cur_words: list<string> = cmd ==# '' ? [] : split(cmd[ : cur])
	var argv: number = len(cur_words)
	var comp: list<string>
	if (argc ==# '' && cur_words[-1] ==# '-C') || (argv >= 2 && cur_words[-2] ==# '-C')
		return getcompletion(argc, 'file')
	elseif argc =~# '^--config-file='
		if argc ==# '--config-file='
			comp = getcompletion('', 'file')
		else
			comp = getcompletion(argc[14 : ], 'file')
		endif
		return comp->map((_, v) => '--config-file=' .. v)
	elseif (argc ==# '' && cur_words[-1] ==# '-M') || (argv >= 2 && cur_words[-2] ==# '-M')
		return getcompletion(argc, 'dir')
	elseif argc =~# '^--manpath='
		if argc ==# '--manpath='
			comp = getcompletion('', 'dir')
		else
			comp = getcompletion(argc[10 : ], 'dir')
		endif
		return comp->map((_, v) => '--manpath=' .. v)
	elseif argc =~# '^--\(warnings\|encoding=\|recode=\|sections=\|extension=\|locale=\|systems=\|preprocessor=\|prompt=\)' || (argc !=# '' && cur_words[-2] =~# '-[ERSseLmpr]')
		return []
	endif
	comp = systemlist('apropos .')
	       	->map((_, v) => v->substitute(' (\d.\+', '', ''))
	       	+ ['--names-only', '--no-hyphenation', '--nh', '--no-justification', '--nj', '--no-subpages', '--regex', '--usage', '--warnings', '--wildcard', '-7', '--ascii', '-?', '--help', '-C', '--config-file=', '-D', '--default', '-E', '--encoding=', '-I', '--match-case', '-K', '--global-apropos', '-L', '--locale=', '-M', '--manpath=', '-R', '--recode=', '-S', '-s', '--sections=', '-V', '--version', '-a', '--all', '-c', '--catman', '-d', '--debug', '-e sub-extension', '--extension=', '-f', '--whatis', '-i', '--ignore-case', '-k', '--apropos', '-l', '--local-file', '-m', '--systems', '-p', '--preprocessor=', '-r', '--prompt=', '-t', '--troff', '-u', '--update']
	return filter(comp, (_, v) => v =~? '^' .. argc)
	       	->sort('i')
	       	->uniq()
enddef
