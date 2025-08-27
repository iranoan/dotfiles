vim9script
scriptencoding utf-8

export def PackManage(...arg: list<string>): void
	if len(arg) < 1
		help pack_manage-sub_help
		echohl WarningMsg | echomsg 'Requires argument (subcommand).' | echomsg 'open help.' | echohl None
	else
		var sub_cmd: string = remove(arg, 0)
		if index(['help', 'list', 'reinstall', 'setup', 'tags'], sub_cmd) == -1
			help pack_manage-sub_help
			echohl WarningMsg | echomsg 'Not exist ' .. sub_cmd .. ' subcommand.' | echomsg 'open help.' | echohl None
		elseif sub_cmd ==# 'help'
			help pack_manage-sub_help
		elseif sub_cmd ==# 'list'
			List()
		elseif sub_cmd ==# 'reinstall'
			Reinstall(arg)
		elseif sub_cmd ==# 'tags'
			if len(arg) == 0
				Helptags(0)
			else
				Helptags(str2nr(arg[0]))
			endif
		elseif sub_cmd ==# 'setup'
			Setup()
		endif
	endif
enddef

export def CompPack(arg: string, cmd: string, pos: number): list<string>
	var cmd_ls: list<string> = split(cmd)
	if len(cmd_ls) >= 2 && cmd_ls[1] == 'reinstall'
		return keys(Get_pack_ls()->filter((_, v) => v.info[0].url =~# '^https://github\.com/'))
					->sort('i')
					->filter((_, v) => v =~# '^' .. arg)
	elseif len(cmd_ls) == 2 && cmd_ls[1] == 'tags'
		return ['0', '1']
	elseif len(cmd_ls) == 1 || (len(cmd_ls) <= 2 && count(['help', 'list', 'reinstall ', 'setup', 'tags'], cmd_ls[1]) == 0)
		return filter(['help', 'list', 'reinstall ', 'setup', 'tags '], (_, v) => v =~# '^' .. arg)
	endif
	return []
enddef

def Helptags(remake: number): void
	# $MYVIMDIR/pack/*/{stat,opt}/*/doc に有るヘルプのタグを $MYVIMDIR/doc/tags{,??x} に出力 (packadd しなくても、help が開けるようになる)
	# $MYVIMDIR/pack/*/{stat,opt}/*/doc に有る tags{,-??} が古ければ再作成
	# コンパイル済みの Python スクリプトにしても大して速度は変わらない
	var docdir: string = $MYVIMDIR .. '/doc'

	def MkHelpTags(): void
		var dir: string
		var existfile: bool
		var tags: string
		var tags_dic: dict<list<string>>

		if len(glob(docdir .. '/*.{txt,??x}', 1, 1))
			execute 'helptags ' .. docdir
		else
			for f in glob(docdir .. '/tags{,-??}', 1, 1)
				delete(f)
			endfor
		endif
		for d in glob($MYVIMDIR .. '/pack/*/{start,opt}/*/doc', 1, 1)
			dir = fnamemodify(d, ':p:h:h:s?.\+/??')
			if isdirectory(d)
				existfile = glob(d .. 'tags{,-??}', 1, 1) == []
				if existfile
					execute 'helptags ' .. d
				endif
				for f in glob(d .. 'tags{,-??}', 1, 1)
					tags = substitute(f, '[-_/A-Za-z0-9.]\+\/\zetags\(-..\)\?$', '', '')
					dir = substitute(substitute(f, 'tags\(-..\)\?$', '', ''), $MYVIMDIR, '..', '')
					tags_dic[tags] = get(tags_dic, tags, []) + readfile(f)
						->map((_, v) => substitute(v, '^[^\t]\+\t', '&' .. dir, ''))
					if existfile
						delete(f)
					endif
				endfor
			endif
		endfor
		var l: list<string>
		for [k, v] in items(tags_dic)
			l = filter(v, (_, i) => i !~# '^!_TAG_FILE_ENCODING\t')
				->sort()
				->uniq()
			if k !=# 'tags'
				l = ["!_TAG_FILE_ENCODING\tutf-8\t//"] + l
			endif
			writefile(l, docdir .. '/' .. k)
		endfor
	enddef

	if !isdirectory(docdir)
		mkdir(docdir, 'p', 0o700)
	endif
	if remake != 0
		MkHelpTags()
		return
	endif
	var max_tags_time: number = 0 # tags, tags-?? 最終更新日時取得
	for tags in glob($MYVIMDIR .. '/doc/tags{,-??}', 1, 1)
		var tags_time: number = getftime(tags)
		if tags_time > max_tags_time
			max_tags_time = tags_time
		endif
	endfor
	for f in glob($MYVIMDIR .. '/pack/*/{start,opt}/*/doc/*.{txt,??x}', 1, 1)->filter((_, v) => v !~# '/vimdoc-ja/doc/[^/]\+\.jax$')
	# for f in glob($MYVIMDIR .. '/pack/github/{start,opt}/*/doc/*.{txt,??x}', 1, 1)->filter((_, v) => v !~# '/vimdoc-ja/doc/[^/]\+\.jax$')
		if max_tags_time < getftime(f)
			MkHelpTags()
			return
		endif
	endfor
enddef

export def IsInstalled(plugin: string): bool
	return (match(split(&runtimepath, ','), '/' .. plugin .. '$') != -1)
enddef

def GrepList(s: string, file: string, nosuf: bool): list<string> # 外部プログラム無しの grep もどき
	var ret: list<string>
	for f in glob(file, false, true, true)
		extend(ret, readfile(f))
			->filter((_, v) => v =~? s)
	endfor
	return ret
enddef

def List(): void
	var packs: dict<any> = Get_pack_ls()
	var ls: list<string>
	var pkg: dict<any>
	var out: list<dict<any>>
	var github: string = '^' .. resolve($MYVIMDIR) .. '/pack/github/'
	var format: string = printf("%%s %%s %%-%ds %%s",
		keys(packs)
		->map((_, v) => len(v))
		->max()
	)

	for k in keys(packs)->sort('i')
		pkg = packs[k]
		add(ls, printf(format,
			pkg.dir !~# github ? 'L ' : (isdirectory(pkg.dir) ? 'I ' : '  '),
			pkg.dir =~# '/start/' .. k ? '  ' : 'O ',
			k,
			pkg.info[0].url
		))
		IsMulti(k, packs[k], out, false)
	endfor
	if has('popupwin')
		popup_menu(ls, {
			border: [1, 1, 1, 1],
			borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
			close: 'click',
			cursorline: true,
			maxheight: &lines - 2,
			moved: 'any',
			padding: [0, 1, 0, 1],
			pos: 'center',
			scrollbar: true,
			wrap: false,
			zindex: 1000,
			filter: (id, key) => {
				if key ==? 'x' || key ==? 'q' || key ==? 'c' || key ==? "\<Esc>"
					popup_close(id, 1)
					return true
				# elseif key ==? 'j'
				# 	normal! ("\<ScrollWheelUp>")
				# 	normal! "\<ScrollWheelUp>"
				else
					return popup_filter_menu(id, key)
				endif
			}
		})
	else
		echo join(ls, "\n")
	endif
	OutMulti(out)
enddef

def Get_pack_ls(): dict<any> # プラグインの名称、リポジトリ、インストール先取得
	var Packadd_ls: func(string): list<any> = (f: string) => # packadd plugin で書かれたプラグイン読み込みを探す
		GrepList('\<packadd\>', f, false)
			->filter((_, v) => v !~# '^[\t ]*["#]') # 行頭コメント削除
			->map((_, v) => substitute(v, '\("\(\"\|[^"]\)*"\|''\(''\|[^'']\)*''\)', '', '')) # 文字列削除
			->map((_, v) => substitute(v, '\("\| #\).*', '', '')) # コメント削除
			->filter((_, v) => v =~# '\<packadd\>')
			->map((_, v) => substitute(v, '\c^.*\<packadd[ \t]\+\([a-z0-9_.-]\+\).*', '\1', ''))

	def Get_packages(f: string, p: list<string>): dict<any> # ファイル f に書かれたプラグインの名称、リポジトリ、インストール先取得
		def GetPack(file: string): list<dict<any>> # 外部プログラム無しの grep もどき
			var ret: list<dict<any>>
			var d: dict<any>
			var lines: list<string>
			for i in glob(file, false, true, true)
				lines = readfile(resolve(i))
				for j in lines
						->matchstrlist('^["#\t ]\+.*\zs\(https://github\.com/[a-z0-9._/-]\+\|\$MYVIMDIR/pack/[a-z0-9._/-]\+\)/\([a-z0-9._-]\+\)\ze/\? *{{{[0-9]*', {submatches: true})
					d = {
						file: i,
						line: j.idx + 1,
						url: substitute(j.text, '^\$MYVIMDIR/pack/', '', ''),
						pack: j.submatches[1],
						setup: []
					}
					for k in lines[j.idx + 1 : ]
						if k !~# '^[\t ]*["#]'
							break
						elseif k =~# '^["#\t ]\+[\t ]*do-setup:'
							add(d.setup, substitute(k,  '^["#\t ]\+\<do-setup:[\t ]*', '', ''))
						endif
					endfor
					add(ret, d)
				endfor
			endfor
			return ret
		enddef

		var pkgs: dict<any>
		var pack: string
		var pack_dir: string = resolve($MYVIMDIR .. 'pack/') .. '/'
		var path: string

		for i in GetPack(f)
			pack = i.pack
			if i.url =~# 'https://github\.com/'
				path = pack_dir .. 'github'
			else
				path = pack_dir .. substitute(i.url, '/.\+', '', '')
			endif
			if !has_key(pkgs, pack)
				pkgs[pack] = {
					info: [],
					dir: path .. ( index(p, pack) == -1 ? '/start' : '/opt' ) .. '/' .. pack
				}
			endif
			add(pkgs[pack].info, {
				url:  i.url,
				file: i.file,
				line: i.line,
				setup: i.setup
			})
		endfor
		return pkgs
	enddef

	var Map_ls: func(string): list<string> = (f: string) => # pack_manage#SetMAP(plugin, ...) で書かれたプラグイン読み込みを探す
		GrepList('^[^#"]*\<pack_manage#SetMAP([ \t]*[''"]', f, false)
			->map((_, v) => substitute(v, '\c^[^#"]*\<pack_manage#SetMAP([ \t]*["'']\([^"'']\+\).*', '\1', ''))

	def ExtendDic(p: dict<any>, ls: dict<any>): void
		for [k, v] in items(ls)
			if has_key(p, k)
				p[k].info += v.info
			else
				p[k] = {
					info: v.info,
					dir: v.dir
				}
			endif
		endfor
	enddef

	var packages: dict<any>

	var packadds: list<string> = Packadd_ls($MYVIMDIR .. 'plugin/*.vim')
	extend(packadds, Packadd_ls($MYVIMDIR .. 'autoload/*.vim'))
		->extend(Map_ls($MYVIMDIR .. 'plugin/*.vim'))
		->extend(Map_ls($MYVIMDIR .. 'autoload/*.vim'))
		->uniq()
	ExtendDic(packages, Get_packages($MYVIMDIR .. 'vimrc', packadds))
	ExtendDic(packages, Get_packages($MYVIMDIR .. 'gvimrc', packadds))
	ExtendDic(packages, Get_packages($MYVIMDIR .. 'autoload/*.vim', packadds))
	ExtendDic(packages, Get_packages($MYVIMDIR .. 'plugin/*.vim', packadds))
	return packages
enddef

def IsMulti(k: string, info: dict<any>, out: list<dict<any>>, msg: bool): bool # 多重設定があり、リポジトリ URL も複数の時 ture を返す
	var urls: list<string>
	if len(info.info) == 1
		return false
	endif
	for i in info.info
		add(urls, i.url)
		if len(uniq(urls)) > 1
			add(out, {filename: i.file, lnum: i.line, text: 'Do not install ' .. k .. "\nmulti url: " .. join(urls)})
			if msg
				echohl ErrorMsg
				echo 'Do not install ' .. k .. "\nmulti url: " .. join(urls)
				echohl None
				return true
			endif
		else
			add(out, {filename: i.file, lnum: i.line, text: 'multi defin: ' .. k})
			if msg
				echohl WarningMsg
				echo 'multi defin: ' .. k
				echohl None
			endif
		endif
	endfor
	return false
enddef

def OutMulti(org: list<dict<any>>): void # 多重設定を QuickFix に出力して開く
	var out: list<dict<any>>
	var qf_nr: number = getqflist({nr: '$'}).nr
	var qf_info: dict<any>
	if len(org) > 0
		out = sort(copy(org), (i0, i1) => i0.filename > i1.filename ? 1 : ( i0.filename < i1.filename ? -1 : ( i0.lnum - i1.lnum )))
		if qf_nr != 0
			for i in range(1, qf_nr)
				qf_info = getqflist({nr: i, title: 0, id: 0})
				if qf_info.title ==# 'pack-manage: Multiple define plug-in'
					setqflist([], 'r', {title: 'pack-manage: Multiple define plug-in', items: out, id: qf_info.id})
					copen
					return
				endif
			endfor
		endif
		setqflist([], ' ', {title: 'pack-manage: Multiple define plug-in', items: out})
		copen
	elseif qf_nr != 0 # 多重設定が既に無くても、もし多重定義の Quickfix が有ればクリア
		for i in range(1, qf_nr)
			qf_info = getqflist({nr: i, title: 0, id: 0})
			if qf_info.title ==# 'pack-manage: Multiple define plug-in'
				if qf_nr == 1
					setqflist([], 'f')
					close
				else
					setqflist([], 'r', {title: 'pack-manage: Multiple define plug-in', items: [], id: qf_info.id})
					colder
				endif
				return
			endif
		endfor
	endif
enddef

def Make(ls: list<dict<any>>): void # make や別途インストールが必要時の処理
	def Executable(s: string): bool # 最大 2 秒ファイルが実行可能か? 存在するかを確認 (git clone を & 付きで実行するのでダウンロード完了済みとは限らない)
		var cmd: list<string> = split(s)
		for i in range(20)
			if cmd[0] !=# 'make'
				if index(['cd', 'set', 'export'], cmd[0]) != -1
					return true
				elseif executable(cmd[0])
					return true
				endif
			elseif len(cmd) == 1
				if filereadable('Makefile')
					return true
				endif
			elseif cmd[1] ==# '-f'
				if filereadable(cmd[2])
					return true
				endif
			elseif cmd[1] =~# '--\(make\)\?file='
				if filereadable(matchstr(cmd[1], '--\(make\)\?file=\zs.\+'))
					return true
				endif
			endif
			sleep 100m
		endfor
		return false
	enddef
	def Isdirectory(d: string): bool # 最大 2 秒ディレクトリができているか確認
		for i in range(20)
			if isdirectory(d)
				return true
			endif
			sleep 100m
		endfor
		return false
	enddef
	var wd: string = getcwd()
	var d: string
	for l in ls
		d = l.dir
		if !Isdirectory(d)
			echohl WarningMsg | echomsg 'do not exist ' .. d | echohl None
			continue
		endif
		chdir(d)
		for c in l.setup
			if !Executable(c)
				echohl WarningMsg | echomsg 'do not rum ' .. c | echohl None
				continue
			endif
			# execute('terminal ++shell ' .. c)
			# execute 'silent file! run: ' .. c
			echohl MatchParen | echo c | echohl None
			echo system(c)
		endfor
	endfor
	chdir(wd)
enddef

def LsMake(p: dict<any>, ls_make: list<dict<any>>): void # make や別途インストールが必要時の処理を list で保存
	if len(p.info[0].setup) != 0
		add(ls_make, {
			dir: p.dir,
			setup: p.info[0].setup
		})
	endif
enddef

def Update(d: string): void
	var wd: string = getcwd()
	if d =~# '^' .. resolve($MYVIMDIR) .. '/pack/github/' && filereadable(d .. '/.git/config')
		chdir(d)
		echohl MatchParen
		echo system('git pull --ff --ff-only && git submodule update --init --recursive &')
		echohl None
		chdir(wd)
	endif
enddef

def Setup(): void # プラグインのインストール、設定のないものの削除
	var swap_dir: string
	var pack_info: dict<any> = Get_pack_ls()
	var packs: list<string>
	var dirs: list<string>
	var info_i: dict<any>
	var more: bool = &more
	var out: list<dict<any>>
	var pack_dir: string = resolve($MYVIMDIR .. 'pack') .. '/'
	var ls_make: list<dict<any>>
	var n: number
	var pack_count: number
	var laststatus: number = &laststatus
	var statusline = &statusline
	w:pack_manage_statusline = {p: 0, bar: ''}
	def Progress(): void # 進行状況を示す終了割合と、プログレス・バー代わりの文字列生成
		w:pack_manage_statusline.p = n * 100 / pack_count
		for i in range(( winwidth(0) - 21 ) * w:pack_manage_statusline.p / 100 - len(w:pack_manage_statusline.bar))
			w:pack_manage_statusline.bar ..= ' '
		endfor
		redrawstatus
	enddef

	dirs = glob(pack_dir .. '*/opt/*', false, true, true)
	extend(dirs, glob(pack_dir .. '*/start/*', false, true, true))
	pack_count = len(pack_info)
	&laststatus = 2
	setlocal statusline=install/update...\ %#MatchParen#%3{w:pack_manage_statusline.p}%%\|%{w:pack_manage_statusline.bar}%<%*
	set more
	for [k, info] in items(pack_info)
		Progress()
		n += 1
		if IsMulti(k, info, out, true)
			continue
		elseif match(dirs, '^' .. info.dir .. '$') != -1
			Update(info.dir)
		else # 未インストール/ディレクトリ違い
			info_i = info.info[0]
			if info_i.url =~# 'https://github\.com/'
				swap_dir = pack_dir .. 'github'
			else
				swap_dir = pack_dir .. substitute(info_i.url, '/.\+', '', '')
			endif
			swap_dir = substitute(info.dir, swap_dir .. '/\zs\(start\|opt\)\ze/', '\={"opt": "start", "start": "opt"}[submatch(0)]', '')
			if match(dirs, '^' .. swap_dir .. '$') != -1 # ディレクトリ違い
				echohl WarningMsg
				echo 'mv ' .. swap_dir .. ' ' info.dir
				echohl None
				rename(swap_dir, info.dir)
				Update(info.dir)
			else # 未インストール
				if info_i.url =~# 'https://github\.com/'
					echohl MatchParen | echo 'git clone ' .. info_i.url .. ' ' .. info.dir | echohl None
					echo system('git clone ' .. info_i.url .. ' ' .. info.dir .. ' &')
				else
					add(out, {filename: info_i.file, lnum: info_i.line, text: 'Can not install ' .. k .. ', not Github'})
				endif
			endif
		endif
		LsMake(info, ls_make)
	endfor
	&l:statusline = statusline
	unlet w:pack_manage_statusline
	&laststatus = laststatus
	OutMulti(out)
	Make(ls_make)
	# 設定なしを削除↓移動済みの場合が有るので再度リストアップ (上の Make() が有るとコマンドラインが閉じられてしまうが解決策が見つからない)
	dirs = glob(pack_dir .. '*/opt/*', false, true, true)
	extend(dirs, glob(pack_dir .. '*/start/*', false, true, true))
	packs = values(pack_info)->map((_, v) => v.dir)
	swap_dir = '^' .. pack_dir .. 'github/'
	echohl WarningMsg
	for s in dirs
		if match(packs, '^' .. s .. '$') != -1
			continue
		elseif s =~# swap_dir
			echomsg 'no setting: rm ' .. substitute(s, '^' .. pack_dir, '', '')
			delete(s, 'rf')
		else
			echomsg 'no setting: ' .. substitute(s, '^' .. pack_dir, '', '')
		endif
	endfor
	echohl None
	if !more
		set nomore
	endif
enddef

def Reinstall(packs: list<string>): void # プラグインの強制再インストール
	var pack_info: dict<any> = Get_pack_ls()
	var p: dict<any>
	var out: list<dict<any>>
	var more: bool = &more
	var ls_make: list<dict<any>>

	set more
	for i in packs
		if !has_key(pack_info, i)
			echohl WarningMsg
			echomsg 'no setting: ' .. i
			echohl None
			continue
		endif
		p = pack_info[i]
		if IsMulti(i, p, out, true)
			continue
		elseif p.info[0].url !~# '^https://github\.com/'
			echohl WarningMsg
			echomsg 'Not Github: ' .. i
			echohl None
			continue
		endif
		if isdirectory(p.dir)
			delete(p.dir, 'rf')
		endif
		echohl MatchParen | echo 'git clone ' .. p.info[0].url .. ' ' .. p.dir | echohl None
		echo system('git clone ' .. p.info[0].url .. ' ' .. p.dir .. ' &')
		Update(p.dir)
		LsMake(p, ls_make)
	endfor
	OutMulti(out)
	Make(ls_make)
	if !more
		set nomore
	endif
enddef

export def SetMAP(plug: string, cmd: string, map_ls: list<dict<any>>): void # キーマップにによる遅延読み込み用関数
	var extra: string
	var c: number
	var exe_cmd: string
	var exe_method: number
	var exe_methods: dict<number>
	var mode: string = tolower(mode())

	while 1
		c = getchar(0)
		if c == 0
			break
		endif
		extra ..= nr2char(c)
	endwhile
	for i in map_ls
		exe_method = get(i, 'method', 0)
		# mode() の返り値先頭と map の時の先頭文字が違うものが有るので、置き換える
		if i.mode ==# 'x'
			exe_methods[i.cmd .. ':v'] = exe_method
		elseif i.mode ==# 'v'
			exe_methods[i.cmd .. ':v'] = exe_method
			exe_methods[i.cmd .. ':s'] = exe_method
		else
			exe_methods[i.cmd .. ':' .. i.mode] = exe_method
		endif
		if exe_method == 0
			execute i.mode .. 'noremap ' .. (get(i, 'buffer', false) ? '<buffer>' : '') .. i.key .. ' <Plug>' .. i.cmd
		elseif ( i.mode ==# 'v' || i.mode ==# 's' || i.mode ==# 'x' ) && exe_method == 2
			execute i.mode .. 'noremap ' .. (get(i, 'buffer', false) ? '<buffer>' : '') .. i.key .. ' :' .. i.cmd .. '<CR>'
		else
			execute i.mode .. 'noremap ' .. (get(i, 'buffer', false) ? '<buffer>' : '') .. i.key .. ' <Cmd>' .. i.cmd .. '<CR>'
		endif
	endfor
	execute 'packadd ' .. plug
	if cmd ==# ''
		return
	endif
	exe_method = get(exe_methods, cmd .. ':' .. mode, 0)
	if exe_method == 0
		exe_cmd = substitute(cmd, ' ', "\<Plug>", 'g')
		feedkeys("\<Plug>" .. exe_cmd .. extra)
	elseif mode =~# '^[vsx]' && exe_method == 2
		feedkeys(":" .. cmd .. "\<CR>")
	else
		execute cmd
	endif
enddef

export def GetPackLs(): dict<any> # プラグインの名称、リポジトリ、インストール先取得
	return Get_pack_ls()
enddef
