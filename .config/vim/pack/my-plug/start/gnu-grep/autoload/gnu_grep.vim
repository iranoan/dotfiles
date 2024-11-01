vim9script
scriptencoding utf-8

export def Grep(...args: list<string>): void
	GrepMain('grep', args)
enddef

export def Lgrep(...args: list<string>): void
	GrepMain('lgrep', args)
enddef

export def SetQfTitle(): void
	var i: dict<any>
	var title: string
	var win_id: number
	for b in tabpagebuflist()
		i = getbufinfo(b)[0]
		if getbufvar(i.bufnr, '&filetype') ==# 'qf'
			win_id = bufwinid(i.bufnr)
			title = getwinvar(win_id, 'quickfix_title')
			if title =~# '^:/usr/bin/grep'
				title = substitute(title, '\(cexpr system("\)\?/usr/bin/grep -nHsI --color=never -d skip --exclude-dir=\.git\( --exclude={[^}]\+}\)\? \(.*\) /dev/null\(")->substitute(''\\ze\\n'', ":1: ", "g")\)\?$', 'grep \3', '')->substitute('%', '%%', 'g')
				setwinvar(win_id, 'quickfix_title', title)
			endif
			return
		endif
	endfor
enddef

def GrepMain(cmd: string, args: list<string>): void
	def FileList(s: string): void
		var arg: string = substitute(s, "'", "''", 'g')
		if cmd ==# 'grep'
			execute 'cexpr system(''/usr/bin/grep' .. arg .. ''')->substitute(''\ze\n'', ":1: ", "g")'
		else
			execute 'lexpr system(''/usr/bin/grep' .. arg .. ''')->substitute(''\ze\n'', ":1: ", "g")'
		endif
		var qf_cmd: list<string> = execute('autocmd QuickFixCmdPost ' .. cmd)->split('\n')
		if len(qf_cmd) > 2
			execute qf_cmd[2]->substitute('["#].*', '', '')->split('\s\+')[1 : ]->join()
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
	if len(filter(copy(args_ls), 'v:val =~# "^--include="')) > 0
		opt = ' -nHsI --color=never -d skip --exclude-dir=.git '
	else
		opt = ' -nHsI --color=never -d skip --exclude-dir=.git --exclude={*.asf,*.aux,*.avi,*.bmc,*.bmp,*.cer,*.chm,*.chw,*.class,*.crt,*.cur,*.dll,*.doc,*.docx,*.dvi,*.emf,*.exe,*.fdb_latexmk,*.fls,*.flv,*.gpg,*.hlp,*.hmereg,*.icc,*.icm,*.ico,*.ics,*.jar,*.jp2,*.jpg,*.ltjruby,*.lzh,*.m4a,*.mkv,*.mov,*.mp3,*.mp4,*.mpg,*.nav,*.nvram,*.o,*.obj,*.odb,*.odg,*.odp,*.ods,*.odt,*.oll,*.opp,*.out,*.pdf,*.pfa,*.pl3,*.png,*.ppm,*.ppt,*.pptx,*.pyc,*.reg,*.rm,*.rtf,*.snm,*.sqlite,*.swf,*.gz,*.bz2,*.Z,*.lzma,*.xz,*.lz,*.tfm,*.toc,*.ttf,*.vbox,*.vbox-prev,*.vdi,*.vf,*.webm,*.wmf,*.wmv,*.xls,*.xlsm,*.xlsx,.*.sw?,.viminfo,viminfo,a.out,tags,tags-ja} '
	endif
	if (( index(args_ls, '-L') >= 0 || index(args_ls, '--files-without-match') >= 0 ) && ( index(args_ls, '-v') >= 0 || index(args_ls, '--invert-match') >= 0))
		|| (( index(args_ls, '-l') >= 0 || index(args_ls, '--files-with-match') >= 0 ) && ( index(args_ls, '-v') == -1 || index(args_ls, '--invert-match') == -1))
		execute 'silent ' .. cmd .. opt .. '-m 1 ' ..
			filter(args_ls, (i, v) => v !~# '^\m\C\(-l\|-L\|-v\|--files-with\(out\)\?-match\|--invert-match\)$')
				->join(' ')->escape('%#|')
	elseif ' ' .. arg_str .. ' ' =~# ' -[ABCDEFGHIPRTUVZabcdefhimnoqrsuvwxyz]*[lL][ABCDEFGHILPRTUVZabcdefhilmnoqrsuvwxyz]* '
		|| index(args_ls, '--files-without-match') >= 0
		|| index(args_ls, '--files-with-matches') >= 0
		FileList(opt .. arg_str)
	else
		execute 'silent ' .. cmd .. opt .. arg_str->escape('%#|')
	endif
enddef

export def GrepComp(ArgLead: string, CmdLine: string, CursorPos: number): list<string>
	def LS(s: string, isdir: bool): list<string>
		var ls: list<string>
		if s ==# ''
			ls = glob('{,.}*')->split('\n')
		elseif s ==# '~'
			ls = glob('~/{,.}*')->split('\n')
		elseif isdirectory(s) && s[-1] !=# '/'
			ls = glob(s .. '/{,.}*')->split('\n')
		else
			ls = glob(s .. '{,.}*')->split('\n')
		endif
		if isdir
			ls = filter(ls, 'isdirectory((resolve(v:val)))')
		endif
		if s[0] ==# '~'
			var home: string = expand('~')
			map(ls, (key, val) => substitute(val, home, '\~', ''))
			# map(ls, 'substitute(v:val, "' .. home .. '", "~", "")')
		endif
		return ls
	enddef
	var cmdline: string = substitute(CmdLine, '[\n\r]\+', ' ', 'g')->substitute('^Grep\s\+', '', '')
	var cmd_space_end: bool = cmdline =~# '\s$'
	var args: list<string>
	var match_s: list<any> = matchstrpos(cmdline, '^\(\(''[^'']\+''\|"\(\"\|[^"]\)\+"\)\|''\\''''\|''''\|""\|\\\\\|\\ \|[^ ]\)\+\s*', 0)
	var i: number
	var opt: list<string> = [
		'-E', '--extended-regexp',
		'-F', '--fixed-strings',
		'-G', '--basic-regexp',
		'-L', '--files-without-match',
		'-P', '--perl-regexp',
		'-R', '--dereference-recursive',
		'-T', '--initial-tab',
		'-e', '--regexp=',
		'-f', '--file=',
		'-i', '--ignore-case',
		'-l', '--files-with-matches',
		'-m',  '--max-count=',
		'-o', '--only-matching',
		'-r', '--recursive',
		'-s', '--no-messages',
		'-v', '--invert-match',
		'-w', '--word-regexp',
		'-x', '--line-regexp',
		'-A', '--after-context=',
		'-B', '--before-context=',
		'-C', '--context=',
		'--include='
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

	while match_s[1] != -1
		add(args, substitute(match_s[0], '\s\+$', '', ''))
		match_s = matchstrpos(cmdline, '^\(\(''[^'']\+''\|"\(\"\|[^"]\)\+"\)\|''\\''''\|''''\|""\|\\\\\|\\ \|[^ ]\)\+\s*', match_s[2])
	endwhile
	for arg in args # 既に使われているオプション削除
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
	for arg in args # 既に使われている --option= の形で使用するオプション削除
		for o in ['--include=', '--max-count=', '--after-context=', '--before-context=', '--context='] # '--regexp=', '--file=', は複数回が意味を持つので除外
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
	if cmd_space_end
		if args[-1] ==# '-f'
			return LS('', false)
		elseif index(['-r', '--recursive', '-R', '--dereference-recursive'], args[-1]) != -1
			return LS('', true)
		elseif index(['-e', '-m', '-A', '-B', '-C'], args[-1]) != -1 # ファイル/ディレクトリ+オプション以外の引数が直後に必要
			return []
		endif
		extend(opt, LS('', false))
		return opt
	else
		if args[-1] =~# '^--file='
			return map(LS(args[-1][7 : ], false), '"--file=" .. v:val')
		endif
		if len(args) >= 2
				&& (
					args[-2] ==# '-r' || args[-2] ==# '--recursive'
					|| args[-2] ==# '-R' || args[-2] ==# '--dereference-recursive'
				)
			return LS(args[-1], true)
		endif
	endif
	extend(opt, LS(args[-1], false))
	return filter(opt, 'v:val =~# ''^' .. escape(args[-1], '.$*~()\[]') .. '''')->map((key, val) => substitute(val, '[^=]\zs$', ' ', ''))
enddef
