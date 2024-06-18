vim9script
scriptencoding utf-8

export def PackManage(...arg: list<string>): void
	if len(arg) < 1
		help pack_manage-sub_help
		echohl WarningMsg | echomsg 'Requires argument (subcommand).' | echomsg 'open help.' | echohl None
	else
		var sub_cmd: string = remove(arg, 0)
		if index(['help', 'list', 'reinstall', 'set', 'tags'], sub_cmd) == -1
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
		elseif sub_cmd ==# 'set'
			Setup()
		endif
	endif
enddef

export def CompPack(arg: string, cmd: string, pos: number): list<string>
	var cmd_ls: list<string> = split(cmd)
	if len(cmd_ls) >= 2 && cmd_ls[1] == 'reinstall'
		return keys(Get_pack_ls())
					->sort('i')
					->filter((_, v) => v =~ '^' .. arg)
	elseif len(cmd_ls) <= 2
		return filter(['help', 'list', 'reinstall ', 'set', 'tags'], (_, v) => v =~# '^' .. arg)
	endif
	return []
enddef

def Helptags(remake: number): void
	# ~/.vim/pack/*/{stat,opt}/*/doc に有るヘルプのタグを ~/.vim/doc/tags{,??x} に出力 (packadd しなくても、help が開けるようになる)
	# ~/.vim/pack/*/{stat,opt}/*/doc に有る tags{,-??} が古ければ再作成
	# コンパイル済みの Python スクリプトにしても大して速度は変わらない
	def MkHelpTags(h: string): void
		var docdir: string = h .. '/doc'
		if len(glob(docdir .. '/*.{txt,??x}', 1, 1))
			execute 'helptags ' .. docdir
		else
			for f in glob(docdir .. '/tags{,-??}', 1, 1)
				delete(f)
			endfor
		endif
		for d in glob(h .. '/pack/*/{start,opt}/*/doc', 1, 1)
			var dir: string = fnamemodify(d, ':p:h:h:s?.\+/??')
			if dir ==# 'vimdoc' || dir =~# '^vimdoc-..$' # ヘルプは除外 tags,tags-ja は作成済み
				continue
			endif
			if isdirectory(d)
				execute 'helptags ' .. d
				var tags: string
				for f in glob(d .. 'tags{,-??}', 1, 1)
					tags = substitute(f, '[-_/A-Za-z0-9.]\+\/\zetags\(-..\)\?$', '', '')
					dir = substitute(substitute(f, 'tags\(-..\)\?$', '', ''), h, '..', '')
					execute 'noautocmd :0split ' .. f
					execute 'silent :%s;^[^\t]\+\t;&' .. dir .. '; '
					execute 'silent noautocmd write! >> ' .. docdir .. '/' .. tags
					bwipeout!
					delete(f)
				endfor
			endif
		endfor
		for f in glob(docdir .. '/tags{,-??}', 1, 1)
			execute 'noautocmd split ' .. f
			sort u | write
			bwipeout!
		endfor
	enddef

	var h: string = split(&runtimepath, ',')[0]
	var docdir: string = h .. '/doc'
	if !isdirectory(docdir)
		mkdir(docdir, 'p', 0o700)
	endif
	if remake != 0
		MkHelpTags(h)
		return
	endif
	var max_tags_time: number = 0 # tags, tags-?? 最終更新日時取得
	for tags in glob(h .. '/doc/tags{,-??}', 1, 1)
		var tags_time: number = getftime(tags)
		if tags_time > max_tags_time
			max_tags_time = tags_time
		endif
	endfor
	for f in glob(h .. '/pack/*/{start,opt}/*/doc/*.{txt,??x}', 1, 1)
		# for f in glob(h .. '/pack/github/{start,opt}/*/doc/*.{txt,??x}', 1, 1)
		if fnamemodify(f, ':p:h:h:s?.\+/??') ==# 'vimdoc-ja' # 日本語ヘルプは除外 (tags,tags-ja は作成済み)
			continue
		endif
		if max_tags_time < getftime(f)
			MkHelpTags(h)
			return
		endif
	endfor
enddef

export def IsInstalled(plugin: string): bool
	return (match(substitute(&runtimepath, ',', '\n', 'g'), '/' .. plugin .. '\n') != -1)
enddef

def GrepList(s: string, file: string, nosuf: bool): list<string> # 外部プログラム無しの grep もどき
	var ret: list<string>
	for f in glob(file, false, true, true)
		extend(ret, readfile(resolve(expand(f))))
			->filter((_, v) => v =~? s)
	endfor
	return ret
enddef

def List(): void
	var packs: dict<any> = Get_pack_ls()
	var ls: list<string>
	var pkg: dict<any>
	var out: list<dict<any>>
	var format: string = printf("%%s %%s %%-%ds %%s",
		keys(packs)
		->map((_, v) => len(v))
		->max()
	)

	for k in keys(packs)->sort('i')
		pkg = packs[k]
		add(ls, printf(format,
			isdirectory(pkg.dir) ? 'I ' : '  ',
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
			->map((_, v) => substitute(v, '["#].*', '', '')) # コメント削除
			->filter((_, v) => v =~# '\<packadd\>')
			->map((_, v) => substitute(v, '\c^.*\<packadd[ \t]\+\([a-z0-9_.-]\+\).*', '\1', ''))

	def Get_packages(f: string, p: list<string>): dict<any> # ファイル f に書かれたプラグインの名称、リポジトリ、インストール先取得
		def GetPack(file: string): list<dict<any>> # 外部プログラム無しの grep もどき
			var ret: list<dict<any>>
			var d: dict<any>
			for i in glob(file, false, true, true)
				for j in readfile(resolve(expand(i)))
									->matchstrlist('^["#\t ]\+.*\zshttps://github\.com/[a-z0-9._/-]\+/\([a-z0-9._-]\+\)\ze *{{{[0-9]*', {submatches: true})
					d = {
						file: i,
						line: j.idx + 1,
						url: j.text,
						pack: j.submatches[0]
					}
					add(ret, d)
				endfor
			endfor
			return ret
		enddef

		var pkgs: dict<any>
		var pack: string
		var pack_dir: string = resolve(expand('~/.vim/pack/github/')) .. '/'

		for i in GetPack(f)
			pack = i.pack
			if !has_key(pkgs, pack)
				pkgs[pack] = {
					info: [],
					dir: pack_dir .. ( index(p, pack) == -1 ? 'start' : 'opt' ) .. '/' .. pack
				}
			endif
			add(pkgs[pack].info, {
				url:  i.url,
				file: i.file,
				line: i.line
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
	var packadds: list<string> = Packadd_ls('~/.vim/plugin/*.vim')
	extend(packadds, Packadd_ls('~/.vim/autoload/*.vim'))
		->extend(Map_ls('~/.vim/plugin/*.vim'))
		->extend(Map_ls('~/.vim/autoload/*.vim'))
		->uniq()
	ExtendDic(packages, Get_packages('~/.vim/vimrc', packadds))
	ExtendDic(packages, Get_packages('~/.vim/gvimrc', packadds))
	ExtendDic(packages, Get_packages('~/.vim/autoload/*.vim', packadds))
	ExtendDic(packages, Get_packages('~/.vim/plugin/*.vim', packadds))
	return packages
enddef

def IsMulti(k: string, info: dict<any>, out: list<dict<any>>, msg: bool): bool # 多重設定があり、リポジトリ URL も複数の時 ture を返す
	var urls: list<string>
	if len(info.info) == 1
		return false
	endif
	add(out, {module: k})
	for i in info.info
		add(out, {filename: i.file, lnum: i.line, text: i.url})
		add(urls, i.url)
	endfor
	set more
	if msg
		if len(uniq(urls)) > 1
			echohl ErrorMsg
			echo 'Do not install ' .. k .. "\nmulti url: " .. join(urls)
			echohl None
			return true
		else
			echohl WarningMsg
			echo 'multi defin: ' .. k
			echohl None
		endif
	endif
	return false
enddef

def OutMulti(out: list<dict<any>>): void # 多重設定を QuickFix に出力して開く
	var qf_nr: number = getqflist({nr: '$'}).nr
	var qf_info: dict<any>
	if len(out) > 0
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

def Setup(): void # プラグインのインストール、設定のないものの削除
	var swap_dir: string
	var pack_info: dict<any> = Get_pack_ls()
	var packs: list<string>
	var dirs: list<string>
	var info: dict<any>
	var more: bool = &more
	var out: list<dict<any>>

	dirs = glob(resolve(expand('~/.vim/pack/github/opt')) .. '/*', false, true, true)
	extend(dirs, glob(resolve(expand('~/.vim/pack/github/start')) .. '/*', false, true, true))
	for k in keys(pack_info)->sort('i')
		info = pack_info[k]
		if match(dirs, '^' .. info.dir .. '$') != -1
			echo 'Installed: ' .. k
		else # 未インストール/ディレクトリ違い
			swap_dir = substitute(info.dir, resolve(expand('~/.vim/pack/github')) .. '/\zs\(start\|opt\)\ze/', '\={"opt": "start", "start": "opt"}[submatch(0)]', '')
			set more
			echohl WarningMsg
			if match(dirs, '^' .. swap_dir .. '$') != -1 # ディレクトリ違い
				echo 'mv ' .. swap_dir .. ' ' info.dir
				rename(swap_dir, info.dir)
			else # 未インストール
				echo system('git clone ' .. info.info[0].url .. ' ' .. info.dir)
			endif
			echohl None
		endif
		IsMulti(k, info, out, true)
	endfor
	OutMulti(out)
	# 設定なしを削除↓移動済みの場合が有るので再度リストアップ
	dirs = glob(resolve(expand('~/.vim/pack/github/opt')) .. '/*', false, true, true)
	extend(dirs, glob(resolve(expand('~/.vim/pack/github/start')) .. '/*', false, true, true))
	packs = values(pack_info)->map((_, v) => v.dir)
	echohl WarningMsg
	set more
	for s in dirs
		if match(packs, '^' .. s .. '$') != -1
			continue
		else
			echo 'no setting: rm ' .. s
			delete(s, 'rf')
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

	set more
	for i in packs
		if !has_key(pack_info, i)
			echohl WarningMsg
			echo 'no setting: ' .. i
			echohl None
			continue
		endif
		p = pack_info[i]
		if IsMulti(i, p, out, true)
			continue
		endif
			echomsg i
		if isdirectory(p.dir)
			delete(p.dir, 'rf')
		endif
		echo system('git clone ' .. p.info[0].url .. ' ' .. p.dir)
	endfor
	OutMulti(out)
	if !more
		set nomore
	endif
enddef

export def SetMAP(plug: string, cmd: string, map_ls: list<dict<string>>): void # キーマップにによる遅延読み込み用関数
	var extra: string
	var c: number

	while 1
		c = getchar(0)
		if c == 0
			break
		endif
		extra ..= nr2char(c)
	endwhile
	for i in map_ls
		execute i.mode .. 'noremap ' .. i.key .. ' <Plug>' .. i.cmd
	endfor
	var exe_cmd = substitute(cmd, ' ', "\<Plug>", 'g')
	execute 'packadd ' .. plug
	feedkeys("\<Plug>" .. exe_cmd .. extra)
enddef

export def GetPackLs(): dict<any> # プラグインの名称、リポジトリ、インストール先取得
	return Get_pack_ls()
enddef
