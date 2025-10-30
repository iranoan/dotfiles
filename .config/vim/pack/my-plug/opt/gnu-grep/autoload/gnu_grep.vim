vim9script
scriptencoding utf-8

export def SetQfTitle(): void
	var i: dict<any>
	var title: string
	var win_id: number
	var exclude_dir: string = '{.git,.svn,.cvs,.cache,.thumbnail}'
	var exclude: string = '{*.asf,*.aux,*.avi,*.bmc,*.bmp,*.cer,*.chm,*.chw,*.class,*.crt,*.cur,*.db,*.db-*,*..db:encryptable,*.dll,*.doc,*.docx,*.dvi,*.emf,*.epub,*.exe,*.fdb_latexmk,*.fls,*.flv,*.gpg,*.hlp,*.hmereg,*.icc,*.icm,*.ico,*.ics,*.jar,*.jp2,*.jpg,*.kbx,*.ltjruby,*.lz4,*.lzh,*.m4a,*.mkv,*.mov,*.mozlz4,*.mp3,*.mp4,*.mpg,*.nav,*.nvram,*.o,*.obj,*.odb,*.odg,*.odp,*.ods,*.odt,*.oll,*.opp,*.out,*.pdf,*.pfa,*.pl3,*.png,*.ppm,*.ppt,*.pptx,*.pyc,*.reg,*.rm,*.rtf,*.snm,*.sqlite,*.sqlite-*,*.sqlite3,*.sqlite3-*,*.swf,*.gz,*.bz2,*.Z,*.lzma,*.xz,*.lz,*.tfm,*.toc,*.ttf,*.vbox,*.vbox-prev,*.vdi,*.vf,*.webm,*.wmf,*.wmv,*.xls,*.xlsm,*.xlsx,.*.sw?,.viminfo,viminfo,a.out,tags,tags-ja}'
	var grepprg: string = split(&grepprg)[0]
	exclude_dir = get(g:, 'gnu_grep', {'exclude-dir': exclude_dir})->get('exclude-dir', exclude_dir)->escape('.*$~[]')
	if exclude_dir !=# ''
		exclude_dir = '--exclude-dir=' .. exclude_dir
	endif
	exclude = get(g:, 'gnu_grep', {'exclude': exclude})->get('exclude', exclude)->escape('.*$~[]')
	if exclude !=# ''
		exclude = '\%( --exclude=' .. exclude .. '\)\? '
	endif
	for b in tabpagebuflist()
		i = getbufinfo(b)[0]
		if getbufvar(i.bufnr, '&filetype') ==# 'qf'
			win_id = bufwinid(i.bufnr)
			title = getwinvar(win_id, 'quickfix_title')
			if title =~# '^:' .. grepprg .. ' -nHsI --color=never -d skip ' .. exclude_dir
				title = substitute(title, '^:' .. grepprg .. ' -nHsI --color=never -d skip '
					.. exclude_dir
					.. exclude .. '\(.*\) \+/dev/null$', 'grep \1', '')
					->substitute('%', '%%', 'g')
				setwinvar(win_id, 'quickfix_title', ' ' .. title)
			endif
		endif
	endfor
enddef

export def Grep(kind: bool, add: bool, bang: string, ...args: list<string>): void
	def FileList(s: string): void
		def GrepAutoCmd(k: string): void
			for c in autocmd_get({event: 'QuickFixCmdPost', pattern: k})
				execute c.cmd
			endfor
		enddef
		var action: string = 'r'
		if add
			action = 'a'
		endif
		var exe_cmd: string = split(&grepprg)[0] .. s .. ' /dev/null'
		if kind
			setqflist([], action, {title: ':' .. exe_cmd, lines: systemlist(exe_cmd), efm: '%f'})
			GrepAutoCmd('grep')
		else
			setloclist(0, [], action, {title: ':' .. exe_cmd, lines: systemlist(exe_cmd), efm: '%f'})
			GrepAutoCmd('lgrep')
		endif
		if !add || bang !=# '!'
			if kind
				:cc 1
			else
				:ll 1
			endif
		endif
	enddef

	def Str2ls(str: string): list<string>
		var args_ls: list<string>
		var s: string = str
		var sep: list<any>

		while true
			sep = matchstrpos(s, ' *\zs\(''\(\\''\|[^'']\)\+''\|"\(\\"\|[^"]\)\+"\|[^ ]\+\)')
			add(args_ls, sep[0])
			s = strpart(s, sep[2])
			if s ==# '' || s =~# '^\s\+$'
				break
			endif
		endwhile
		return args_ls
	enddef

	var arg_str: string = args[0]
	var args_ls: list<string> = Str2ls(arg_str)
	var opt: string
	var exe_cmd: string
	var exclude_dir: string = '{.git,.svn,.cvs,.cache,.thumbnail}'
	exclude_dir = get(g:, 'gnu_grep', {'exclude-dir': exclude_dir})->get('exclude-dir', exclude_dir)
	if exclude_dir !=# ''
		exclude_dir = '--exclude-dir=' .. exclude_dir
	endif
	if len(filter(copy(args_ls), (_, v) => v =~# '^--include=')) > 0
		opt = ' -nHsI --color=never -d skip ' .. exclude_dir .. ' '
	else
		var exclude: string = '{*.asf,*.aux,*.avi,*.bmc,*.bmp,*.cer,*.chm,*.chw,*.class,*.crt,*.cur,*.db,*.db-*,*..db:encryptable,*.dll,*.doc,*.docx,*.dvi,*.emf,*.epub,*.exe,*.fdb_latexmk,*.fls,*.flv,*.gpg,*.hlp,*.hmereg,*.icc,*.icm,*.ico,*.ics,*.jar,*.jp2,*.jpg,*.kbx,*.ltjruby,*.lz4,*.lzh,*.m4a,*.mkv,*.mov,*.mozlz4,*.mp3,*.mp4,*.mpg,*.nav,*.nvram,*.o,*.obj,*.odb,*.odg,*.odp,*.ods,*.odt,*.oll,*.opp,*.out,*.pdf,*.pfa,*.pl3,*.png,*.ppm,*.ppt,*.pptx,*.pyc,*.reg,*.rm,*.rtf,*.snm,*.sqlite,*.sqlite-*,*.sqlite3,*.sqlite3-*,*.swf,*.gz,*.bz2,*.Z,*.lzma,*.xz,*.lz,*.tfm,*.toc,*.ttf,*.vbox,*.vbox-prev,*.vdi,*.vf,*.webm,*.wmf,*.wmv,*.xls,*.xlsm,*.xlsx,.*.sw?,.viminfo,viminfo,a.out,tags,tags-ja}'
		exclude = get(g:, 'gnu_grep', {'exclude': exclude})->get('exclude', exclude)
		if exclude !=# ''
			exclude = ' --exclude=' .. exclude
		endif
		opt = ' -nHsI --color=never -d skip ' .. exclude_dir .. exclude .. ' '
	endif
	if kind
		if add
			exe_cmd = 'grepadd' .. bang
		else
			exe_cmd = 'grep' .. bang
		endif
	elseif add
		exe_cmd = 'lgrepadd' .. bang
	else
		exe_cmd = 'lgrep' .. bang
	endif
	if (( index(args_ls, '-L') >= 0 || index(args_ls, '--files-without-match') >= 0 ) && ( index(args_ls, '-v') >= 0 || index(args_ls, '--invert-match') >= 0))
		|| (( index(args_ls, '-l') >= 0 || index(args_ls, '--files-with-match') >= 0 ) && ( index(args_ls, '-v') == -1 || index(args_ls, '--invert-match') == -1))
		execute 'silent ' .. exe_cmd .. opt .. '-m 1 ' ..
			filter(args_ls, (i, v) => v !~# '^\m\C\(-l\|-L\|-v\|--files-with\(out\)\?-match\|--invert-match\)$')
				->join(' ')->escape('%#|')
	elseif ' ' .. arg_str .. ' ' =~# ' -[ABCDEFGHIPRTUVZabcdefhimnoqrsuvwxyz]*[lL][ABCDEFGHILPRTUVZabcdefhilmnoqrsuvwxyz]* '
		|| index(args_ls, '--files-without-match') >= 0
		|| index(args_ls, '--files-with-matches') >= 0
		FileList(opt .. arg_str)
	else
		execute 'silent ' .. exe_cmd .. opt .. arg_str->escape('%#|')
	endif
enddef

export def GrepComp(ArgLead: string, CmdLine: string, CursorPos: number): list<string>
	def LS(s: string, isdir: bool): list<string> # パス・リストを取得
		var ls: list<string>
		if s ==# ''
			ls = glob('{,.}*', false, true, true)
		elseif s ==# '~'
			ls = glob('~/{,.}*', false, true, true)
		elseif isdirectory(s) && s[-1] !=# '/'
			ls = glob(s .. '/{,.}*', false, true, true)
		else
			ls = glob(s .. '{,.}*', false, true, true)
		endif
		if isdir
			filter(ls, (_, v) => isdirectory((resolve(v))))
		endif
		if s[0] ==# '~'
			var home: string = expand('~')
			map(ls, (_, v) => substitute(v, home, '\~', ''))
		endif
		return ls->sort('i')
	enddef
	def SplitArg(s: string): list<string> # 引数をリストに変換
		var match_s: list<any> = matchstrpos(s, '^\(\(''[^'']\+''\|"\(\"\|[^"]\)\+"\)\|''\\''''\|''''\|""\|\\\\\|\\ \|[^ ]\)\+\s*', 0)
		var args: list<string>
		while match_s[1] != -1
			add(args, substitute(match_s[0], '\s\+$', '', ''))
			match_s = matchstrpos(s, '^\(\(''[^'']\+''\|"\(\"\|[^"]\)\+"\)\|''\\''''\|''''\|""\|\\\\\|\\ \|[^ ]\)\+\s*', match_s[2])
		endwhile
		return args
	enddef
	def SetedPattern(args: list<string>): number # 検索文字列が設定されているか?
		var kind_option: number = 0
		for arg in args
			if arg =~# '^--regexp=.' # 検索パターンがある
				return 2
			elseif kind_option == 1 # 直前が -e オプション
				return 2
			elseif kind_option != -1 && arg =~# '^[^-]' # 直前が引数必須のオプションでもなくオプションそのものでもない
				return 1
			elseif arg ==# '-e' || arg =~# '^--regexp=' # 検索パターン指定予定
				kind_option = 1
				continue
			elseif index(['-m', '-A', '-B', '-C'], arg) != -1
				kind_option = -1
			else
				kind_option = 0
			endif
		endfor
		return kind_option
	enddef
	var cmd_space_end: bool = CmdLine[ : CursorPos - 1] =~# '\s$'
	var args_all: list<string> = SplitArg(substitute(CmdLine, '[\n\r]\+', ' ', 'g')
		->substitute('^Grep\s\+', '', '')) # コマンドライン全体の引数
	var args_cursor: list<string> = SplitArg(substitute(CmdLine[ : CursorPos - 1], '[\n\r]\+', ' ', 'g')
		->substitute('^Grep\s\+', '', '')) # コマンドラインのカーソルまでの引数
	var i: number
	var opt: list<string> = [
		'-A', '--after-context=',     '-B',         '--before-context=',
		'-C', '--context=',           '-E',         '--extended-regexp',
		'-e', '--regexp=',            '-f',         '--file=',
		'-F', '--fixed-strings',      '-G',         '--basic-regexp',
		'-i', '--ignore-case',        '--include=',
		'-l', '--files-with-matches', '-L',         '--files-without-match',
		'-m', '--max-count=',         '-o',         '--only-matching',
		'-P', '--perl-regexp',        '-R',         '--dereference-recursive',
		'-r', '--recursive',          '-s',         '--no-messages',
		'-T', '--initial-tab',        '-v',         '--invert-match',
		'-w', '--word-regexp',        '-x',         '--line-regexp',
	]
	var opt_pair: dict<string> = {
		'-E': '--extended-regexp',       '--extended-regexp':       '-E',
		'-F': '--fixed-strings',         '--fixed-strings':         '-F',
		'-G': '--basic-regexp',          '--basic-regexp':          '-G',
		'-L': '--files-without-match',   '--files-without-match':   '-L',
		'-P': '--perl-regexp',           '--perl-regexp':           '-P',
		'-R': '--dereference-recursive', '--dereference-recursive': '-R',
		'-T': '--initial-tab',           '--initial-tab':           '-T',
		'-e': '--regexp=',               '--regexp=':               '-e',
		'-f': '--file=',                 '--file=':                 '-f',
		'-i': '--ignore-case',           '--ignore-case':           '-i',
		'-l': '--files-with-matches',    '--files-with-matches':    '-l',
		'-m': '--max-count=',            '--max-count=':            '-m',
		'-o': '--only-matching',         '--only-matching':         '-o',
		'-r': '--recursive',             '--recursive':             '-r',
		'-s': '--no-messages',           '--no-messages':           '-s',
		'-v': '--invert-match',          '--invert-match':          '-v',
		'-w': '--word-regexp',           '--word-regexp':           '-w',
		'-x': '--line-regexp',           '--line-regexp':           '-x',
		'-A': '--after-context=',        '--after-context=':        '-A',
		'-B': '--before-context=',       '--before-context=':       '-B',
		'-C': '--context=',              '--context=':              '-C',
	}
	def AddLS(cmd: string): void # 検索文字列未指定、ディレクトリ指定オプション未指定ならパスを補完候補に加える
		for o in ['-r', '--recursive', '-R', '--dereference-recursive']
			if index(args_all, o) != -1
				return
			endif
		endfor
		if SetedPattern(args_cursor) > 0
			extend(opt, LS(cmd, false))
		elseif SetedPattern(args_cursor) == 2
			extend(opt, LS(cmd, false))
		endif
	enddef
	for arg in args_all # 既に使われているオプション削除
		if index(['-e', '--regexp=', '-f', '--file='], arg) != -1 # 複数回の使用が意味を持つ
			continue
		endif
		i = index(opt, arg)
		if i != -1
			remove(opt, i)
			if has_key(opt_pair, arg)
				remove(opt, index(opt, opt_pair[arg]))
			endif
		endif
	endfor
	for arg in args_all # 既に使われている --option= の形で使用するオプション削除 (--include は複数指定があり得るので除外対象から外す)
		for o in ['--max-count=', '--after-context=', '--before-context=', '--context='] # '--regexp=', '--file=', は複数回が意味を持つので除外
			if arg =~# '^' .. o
				i = index(opt, o)
				if i != -1
					remove(opt, i)
					if has_key(opt_pair, o)
						remove(opt, index(opt, opt_pair[o]))
					endif
				endif
			endif
		endfor
	endfor
	if !(!!args_cursor) # 引数なしなので、オプションのみ
		return map(opt, (key, val) => substitute(val, '^-[-A-Za-z]\+[^=]\zs$', ' ', ''))
	elseif cmd_space_end
		if args_cursor[-1] ==# '-f'
			return LS('', false)
		elseif index(['-r', '--recursive', '-R', '--dereference-recursive'], args_cursor[-1]) != -1
			return LS('', true)
		elseif index(['-e', '-m', '-A', '-B', '-C'], args_cursor[-1]) != -1 # ファイル/ディレクトリ+オプション以外の引数が直後に必要
			return []
		endif
		AddLS('')
		return opt
	else
		if args_cursor[-1] =~# '^--file='
			return map(LS(args_cursor[-1][7 : ], false), (_, v) => '--file=' .. v)
		elseif len(args_cursor) >= 2
			if args_cursor[-2] ==# '-r' || args_cursor[-2] ==# '--recursive'
				|| args_cursor[-2] ==# '-R' || args_cursor[-2] ==# '--dereference-recursive'
				return LS(args_cursor[-1], true)
			endif
		endif
		AddLS(args_cursor[-1])
		return filter(opt, (_, v) => v =~# '^' .. escape(args_cursor[-1], '.$*~()\[]'))
			->map((_, v) => substitute(v, '^-[-A-Za-z]\+[^=]\zs$', ' ', ''))
	endif
enddef
