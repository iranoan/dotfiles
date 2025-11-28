vim9script

export def ShellMan(...args: list<string>)
	var err: list<string> = ManCore('topleft', true, args)
	if err != []
		if getline(1) != ''
			DisplayErr(err)
		else
			execute 'silent !echo ' .. join(err, "\n")
			quit
		endif
	else
		delcommand ShellMan
	endif
enddef

export def ColorMan(mod: string, ...args: list<string>)
	var err: list<string> = ManCore(mod, false, args)
	delcommand ShellMan
	if err != []
		DisplayErr(err)
	endif
enddef

def DisplayErr(err: list<string>): void
	if has('popupwin')
		popup_notification(err, {borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'], pos: 'center'})
	else
		echohl WarningMsg
		for s in err
			echomsg s
		endfor
		echohl None
	endif
enddef

def ManCore(mod: string, shell: bool, args: list<string>): list<string>
	def OpenWay(name: string): string # ウィンドウの開き方
		var bufnr: number
		var man_buf: number = (getbufinfo()->filter((_, v) => v.name == name) + [{bufnr: 0}])[0].bufnr
		var windows: list<number> = gettabinfo(tabpagenr())[0].windows
		# 開き方の指定有り
		if mod =~# '\<tab\>'
			return 'tabedit '
		elseif mod =~ '\<\(vert\%[ical]\|hor\%[izontal]\|lefta\%[bove]\|abo\%[veleft]\|rightb\%[elow]\|bel\%[owright]\|to\%[pleft]\)\>'
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
			elseif g:ft_man_open_mode == 'top'
				return 'topleft split '
			elseif g:ft_man_open_mode == 'left'
				return 'topleft vsplit '
			elseif g:ft_man_open_mode == 'bottom'
				return ':botright split '
			elseif g:ft_man_open_mode == 'right'
				return ':botright vsplit '
			elseif g:ft_man_open_mode == 'tab'
				return 'tabedit '
			else
				return 'split '
			endif
		else
			return 'split '
		endif
	enddef

	def GetOptPages(): list<any>
		def GetPages(arg: list<string>): list<dict<string>> # [section] page のペアにする
			def Parse(s: string): dict<string> # 'man(7)' man(7) "man(7)" man.7 をパース
				var cmd: string
				var sec: number = 0
				var sec_sb: string
				var sec_sp: string

				if matchlist(s, '^\([''"]\)\=\([][A-Za-z0-9_:.+@-]\+\)\%((\(\d\))\|\.\(\d\)\)\=\1') == []
					return {page: s}
				endif
				[cmd, sec_sb, sec_sp] = matchlist(s, '^\([''"]\)\=\([][A-Za-z0-9_:.+@-]\+\)\%((\(\d\))\|\.\(\d\)\)\=\1')[2 : 4]
				if cmd =~# '\.\d\+$'
					[cmd, sec_sb] = matchlist(cmd, '^\([][A-Za-z0-9_:.+@-]\{-}\)\.\(\d\+\)$')[1 : 2]
				endif
				return {page: cmd .. (sec_sb ==# '' ? sec_sp : '.' .. sec_sb)}
			enddef

			var pages: list<dict<string>>
			var page: dict<any>
			var argv: number = len(arg)
			var s: string
			var i: number
			var sec: number = 0

			while i < argv
				s = arg[i]
				sec = str2nr(s)
				if '' .. sec ==# s # 数値変換後も元の文字列と同じ→数値→[section] 部分
					if i < (argv - 1)
						s = arg[i + 1]
						page = Parse(s)
						if page.section == ''
							add(pages, {page: s, name: s .. '.'})
						else # sec は無視する
							add(pages, extend(page, {name: page.page .. '.' .. page.section .. '.'}))
						endif
					endif
					i += 1
				else
					page = Parse(s)
					if page.page !~# '\.\d\+$'
						add(pages, extend(page, {name: page.page .. '.'}))
					elseif i < (argv - 1)
						s = arg[i + 1]
						sec = str2nr(s)
						if '' .. sec ==# s
							add(pages, {page: page.page, section: s, name: page.page .. '.' .. s .. '.'})
							i += 1
						else
							add(pages, extend(page, {name: page.page .. '.'}))
						endif
					else
						add(pages, extend(page, {name: page.page .. '.'}))
					endif
				endif
				i += 1
			endwhile
			return sort(pages)->uniq()
		enddef

		var argv: number = len(args)
		var i: number
		var s: string
		var topic: list<string>
		var opt: list<string>

		while i < argv # オプションだけ取り出す
			s = args[i]
			# 無視するオプション
			if args[i] =~# '\(-H[^ ]*\|--html\(=[^ ]\+\)\=\|--pager\(=[^ ]\+\)\=\|-T[^ ]*\|--troff-device\(=[^ ]\+\)\=\|-X[^ ]*\|--gxdietview\(=[^ ]\+\)\=\|-[PW]\|--where-cat\|--location-cat-w\|--where\|--path\|--location-Z\|--ditroff\)'
			elseif s =~# '^-[CELMRSsempr]' # 引数有りのプション
				# -k, -f -l は一覧で、次に来るのがキーワードなのでオプション固有の引数ではない
				add(opt, s .. ' ' .. args[i + 1])
				i += 1
			elseif s =~# '^-' # オプション
				add(opt, s)
			else
				add(topic, s)
			endif
			i += 1
		endwhile
		if topic == []
			return [opt, [{page: 'man', name: 'man.'}]]
		endif
		return [opt, GetPages(topic)]
	enddef

	def GetName(o: list<string>, s: list<dict<string>>): string
		if index(o, '-k') != -1 || index(o, '--apropos') != -1
			|| index(o, '-f') != -1 || index(o, '--whatis') != -1
			|| index(o, '-l') != -1 || index(o, '--local-file') != -1
			return $HOME .. '/' .. (o + copy(s)->map((_, v) => v.page))->join('*') .. '.~'
		endif
		var all_page = systemlist('man -k .')
		               	->map((_, v) => substitute(v, ' .*', '', ''))

		return $HOME .. '/' .. (o == [] ? '' : join(o, '*') .. '*')
		       	.. copy(s)
		           	->filter((_, v) => index(all_page, v.page) != -1)
		           	->map((_, v) => v.name)
		           	->join('|')
		       	.. '~'
	enddef

	var opts: list<string> # オプション
	var exe: string
	var pages: list<dict<string>> # [section] page などを要素に持つ辞書リスト
	var width: number
	var max_width: number
	var name: string # 仮のバッファ名
	var open: string # 開き方
	var out: list<string> # man の出力
	var ret: list<string> # man の出力
	var err: list<string> # エラー出力

	[opts, pages] = GetOptPages()
	name = GetName(opts, pages)
	if shell
		open = 'silent file! '
	else
		open = OpenWay(name)
		if open ==# '' # 同じ page を既に開いている
			return []
		endif
	endif

	width = (&columns / (open =~# '\<\(vert\%[ical]\|vsplit\)\>' ? 2 : 1) - ( &number ? 3 : 0 ) - &foldcolumn - ( &signcolumn !=# 'no' ? 1 : 0 ) - 2)
	max_width = get(g:, 'ft_man_max_width', 100)
	if max_width > 0 && width > max_width
		width = max_width
	endif
	exe = 'MANWIDTH=' .. width .. ' MANPAGER=cat MAN_KEEP_FORMATTING=1 man ' .. join(opts) .. ' '
	if index(opts, '-k') != -1 || index(opts, '--apropos') != -1
		|| index(opts, '-f') != -1 || index(opts, '--whatis') != -1
		|| index(opts, '-l') != -1 || index(opts, '--local-file') != -1
		var tmp: string = tempname()
		out = systemlist(exe .. copy(pages)->map((_, v) => v.page)->join() .. ' 2> ' .. tmp)
		err = readfile(tmp)
		delete(tmp)
	else
		for p in pages
			ret = systemlist(exe .. p.page .. ' 2> /dev/null')
			if ret == []
				err += systemlist(exe .. p.page)
			else
				out += ret
			endif
		endfor
	endif
	if out != []
		execute open .. escape(name, '|')
		setlocal buftype=nofile noswapfile
		setlocal filetype=man
		setlocal modifiable
		append(0, out)
		keepjumps :$delete
		setpos('.', [0, 1, 1, 0])
		setlocal nomodifiable
	endif
	return err
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
