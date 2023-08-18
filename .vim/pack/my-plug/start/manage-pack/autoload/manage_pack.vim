vim9script
scriptencoding utf-8

export def Helptags(): void
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
			if dir ==# 'vimdoc' || dir ==# 'vimdoc-ja' # ヘルプは除外 tags,tags-ja は作成済み
				continue
			endif
			if isdirectory(d)
				execute 'helptags ' .. d
				var tags: string
				for f in glob(d .. 'tags{,-??}', 1, 1)
					tags = substitute(f, '[-_/A-Za-z0-9.]\+\/\zetags\(-..\)\?$', '', '')
					dir = substitute(substitute(f, 'tags\(-..\)\?$', '', ''), h, '..', '')
					execute ':0split ' .. f
					execute 'silent :%s;^[^\t]\+\t;&' .. dir .. '; '
					execute 'silent write! >> ' .. docdir .. '/' .. tags
					bwipeout!
					delete(f)
				endfor
			endif
		endfor
		for f in glob(docdir .. '/tags{,-??}', 1, 1)
			execute 'split ' .. f
			sort u | write
			bwipeout!
		endfor
	enddef

	var h: string = split(&runtimepath, ',')[0]
	var docdir: string = h .. '/doc'
	if !isdirectory(docdir)
		mkdir(docdir, 'p', 0o700)
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

export function CompPackList(arg, cmd, pos) abort " ~/.vim/plugin/set-pack-{start,opt}.vim, ~/.vim/autoload/*.vim で設定されたプラグインの補完関数
	return extendnew(<SID>Pack_ls('~/.vim/plugin/*.vim'), <SID>Pack_ls('~/.vim/autoload/*.vim'))
				\ ->uniq()
				\ ->map('substitute(v:val, ''.\+/'', "", "")')
				\ ->sort('i')
				\ ->filter('v:val =~ "^' .. a:arg .. '"')
endfunction

def GrepList(s: string, files: string): list<string> # 外部プログラム無しの grep もどき
	var ret: list<string>
	for f in glob(files, false, true, true)
		extend(ret, readfile(resolve(expand(f))))
			->filter('v:val =~? ''' .. substitute(s, "'", "''", '') .. '''')
	endfor
	return ret
enddef

def Pack_ls(f: string): list<string> # f に書かれた # OR " で始まり comment https://github.com/user/plugin {{{(foldmaker)をリスト・アプ
	return GrepList('^["#\t ]\+.*https://github\.com/[a-z0-9._/-]\+ *{{{[0-9]*', f)
		->map('substitute(v:val, ''\c^[#"\t ]\+.*\(https:\/\/github\.com\/[a-z0-9._/-]\+\/[a-z0-9._-]\+\)\s*{{{\d*.*'', ''\1'', "")')
enddef

def Get_pack_ls(): list<dict<string>> # プラグインの名称、リポジトリ、インストール先取得
	var Filter: func(list<string>, string): list<any> = (l: list<string>, s: string) => # 文字列、コメントを削除した上で更に filter
			l->filter('v:val !~# ''^[\t ]*["#]''') # 行頭コメント削除
			->map('substitute(v:val, ''\("\(\"\|[^"]\)*"\|''''\(''''\|[^'''']\)*''''\)'', "", "")') # 文字列削除
			->map('substitute(v:val, ''["#].*'', "", "")') # コメント削除
			->filter('v:val =~# ''' .. s .. '''')

	var Packadd_ls: func(string): list<any> = (f: string) => # packadd plugin で書かれたプラグイン読み込みを探す
		GrepList('\<packadd\>', f)
			->Filter('\<packadd\>')
			->map('substitute(v:val, ''\c^.*\<packadd[ \t]\+\([a-z0-9_.-]\+\).*'', ''\1'', "")')

	def Get_packages(f: string, p: list<string>): list<dict<string>> # ファイル f に書かれたプラグインの名称、リポジトリ、インストール先取得
		var packages: list<dict<string>>
		var pack: string
		var pack_dir: string = resolve(expand('~/.vim/pack/github/')) .. '/'

		for url in Pack_ls(f)
			# 上 2 つの検索文字列中の波括弧がそのままだと foldmarker の扱いにあんるので文字列結合を使うことで分断している
			pack = substitute(url, '.\+/', '', '')
			add(packages, {
				'rep': url,
				'package': pack,
				'dir': pack_dir .. ( index(p, pack) == -1 ? 'start' : 'opt' ) .. '/' .. pack
				})
		endfor
		return packages
	enddef

	var Map_ls: func(string): list<any> = (f: string) => # manage_pack#SetMAP(plugin, ...) で書かれたプラグイン読み込みを探す
		GrepList('^[^#"]*\<manage_pack#SetMAP([ \t]*[''"]', f)
			->map('substitute(v:val, ''\c^[^#"]*\<manage_pack#SetMAP([ \t]*["'''']\([^"'''']\+\).*'', ''\1'', "")')

	var packadds: list<string> = Packadd_ls('~/.vim/plugin/*.vim')
	extend(packadds, Packadd_ls('~/.vim/autoload/*.vim'))
		->extend(Map_ls('~/.vim/plugin/*.vim'))
		->extend(Map_ls('~/.vim/autoload/*.vim'))
		->uniq()
	return extendnew(Get_packages('~/.vim/plugin/*.vim', packadds), Get_packages('~/.vim/autoload/*.vim', packadds))
		->sort((lhs, rhs) => lhs.package >? rhs.package ? 1 : -1)
enddef

export def Setup(): void # プラグインのインストール、設定のないものの削除
	var swap_dir: string
	var pack_info: list<dict<string>> = Get_pack_ls()
	var packs: list<any>
	var dirs: list<string> = glob(resolve(expand('~/.vim/pack/github/opt')) .. '/*', false, true, true)
	extend(dirs, glob(resolve(expand('~/.vim/pack/github/start')) .. '/*', false, true, true))
	def GetDirs(l: list<dict<string>>): list<string>
		var p: list<string>
		for i in l
			add(p, i.dir)
		endfor
		return p
	enddef

	for s in pack_info
		if match(dirs, '^' .. s.dir .. '$') != -1
			echo 'Installed: ' .. s.package
		else # 未インストール/ディレクトリ違い
			swap_dir = substitute(s.dir, resolve(expand('~/.vim/pack/github')) .. '/\zs\(start\|opt\)\ze/', '\={"opt": "start", "start": "opt"}[submatch(0)]', '')
			echohl WarningMsg
			if match(dirs, '^' .. swap_dir .. '$') != -1 # ディレクトリ違い
				echo 'mv ' .. swap_dir .. ' ' s.dir
				rename(swap_dir, s.dir)
			else # 未インストール
				echo system('git clone ' .. s.rep .. ' ' .. s.dir)
			endif
			echohl None
		endif
	endfor
	# 設定なしを削除
	# packs = map(pack_info, 'v:val.dir')
	packs = GetDirs(pack_info)
	for s in dirs
		echohl WarningMsg
		if match(packs, '^' .. s .. '$') != -1
			continue
		else
			echo 'no setting: rm ' .. s
			delete(s, 'rf')
		endif
		echohl None
	endfor
enddef

export def Reinstall(...packs: list<string>): void # プラグインの強制再インストール
	var all_packs: list<dict<string>> = Get_pack_ls()
	var pack_ls: list<dict<string>>
	for p in packs
		pack_ls = all_packs->deepcopy()->filter('v:val.package ==# "' .. p .. '"')
		if !len(pack_ls)
			echohl WarningMsg
			echo 'no setting: ' .. p
			echohl None
			continue
		endif
		for l in pack_ls
			if isdirectory(l.dir)
				delete(l.dir, 'rf')
			endif
			echo system('git clone ' .. l.rep .. ' ' .. l.dir)
		endfor
	endfor
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
		execute i.mode .. 'map ' .. i.key .. ' <Plug>' .. i.cmd
	endfor
	var exe_cmd = substitute(cmd, ' ', "\<Plug>", 'g')
	execute 'packadd ' .. plug
	feedkeys("\<Plug>" .. exe_cmd .. extra)
enddef
