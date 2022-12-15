vim9script
scriptencoding utf-8
# ~/.vim/pack/*/{stat,opt}/* でプラグインを管理する上で、便利な関数

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
					var docrid: string
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

def Pack_ls(f: string): list<string> # f に書かれた # OR " で始まり comment https://github.com/user/plugin {{(foldmaker){ をリスト・アプ
	return systemlist("grep -Ehi '^[\"#\t ]+.*https://github\.com/[a-z0-9._/-]+ {" .. "{{[0-9]*' " .. f)
		->map('substitute(v:val, ''\c^[#"\t ]\+.*\(https:\/\/github\.com\/[a-z0-9._/-]\+\/[a-z0-9._-]\+\)\s*{'' .. ''{{\d*.*'', ''\1'', '''')')
		# 上 2 つの検索文字列中の波括弧がそのままだと foldmarker の扱いになるので文字列結合を使うことで分断している
enddef

def Get_pack_ls(): list<dict<string>> # プラグインの名称、リポジトリ、インストール先取得
	var Packadd_ls: func(string): list<any> = (f: string) => # packadd plugin で書かれたプラグイン読み込みを探す
		systemlist("grep -Ehi '^[^\#\"]*\\<packadd' " .. f)
			->map('substitute(v:val, ''\c^[^\#"]*\<packadd[ \t]\+\([a-z0-9_.-]\+\).*'', ''\1'', '''')')

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

	var Map_ls: func(string): list<any> = (f: string) => # set_map_plug#Main(plugin, ...) で書かれたプラグイン読み込みを探す
		systemlist("grep -Ehi '^[^#\"]*\\<set_map_plug\#Main\\([ \t]*'\\' " .. f)
			->map('substitute(v:val, ''\c^[^\#\"]*\<set_map_plug\#Main([ \t]*''''\([^'''']\+\).*'', ''\1'', '''')')

	var packadds: list<string> = Packadd_ls('~/.vim/plugin/*.vim')
	extend(packadds, Packadd_ls('~/.vim/autoload/*.vim'))
		->extend(Map_ls('~/.vim/plugin/*.vim'))
		->extend(Map_ls('~/.vim/autoload/*.vim'))
		->uniq()
	return extendnew(Get_packages('~/.vim/plugin/*.vim', packadds), Get_packages('~/.vim/autoload/*.vim', packadds))
		->sort((lhs, rhs) => lhs.package >? rhs.package ? 1 : -1)
enddef

export def Install(): void # プラグインのインストール
	for s in Get_pack_ls()
			echomsg s.rep .. ' ' .. s.dir
		# if isdirectory(s.dir)
		# 	echomsg s.rep .. ' ' .. s.dir
		# else
		# if !isdirectory(s.dir)
		# 	echo system('git clone ' .. s.rep .. ' ' .. s.dir)
		# endif
	endfor
enddef

export def Reinstall(...packs: list<string>): void # プラグインの強制再インストール
	var all_packs: list<dict<string>> = Get_pack_ls()
	var pack_ls: list<dict<string>>
	var hit: list<dict<string>>
	for p in packs
		hit = all_packs->deepcopy()->filter('v:val.package ==# "' .. p .. '"')
		if len(hit)
			extend(pack_ls, hit)
		else
			echo p .. ': no setting'
		endif
	endfor
	var dic: dict<string>
	for p in pack_ls
		dic = p
		if isdirectory(dic.dir)
			echo 'rm -rf ' .. dic.dir
			delete(dic.dir, 'rf')
		endif
		echo dic.rep .. ' ' .. dic.dir
		systemlist('git clone ' .. dic.rep .. ' ' .. dic.dir)
	endfor
enddef
