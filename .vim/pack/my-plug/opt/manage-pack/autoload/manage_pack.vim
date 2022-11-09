vim9script
scriptencoding utf-8
# ~/.vim/pack/*/{stat,opt}/* でプラグインを管理する上で、便利な関数

export def Helptags(): void
	# ~/.vim/pack/*/{stat,opt}/*/doc に有るヘルプのタグを ~/.vim/doc/tags{,??x} に出力 (packadd しなくても、help が開けるようになる)
	# ~/.vim/pack/*/{stat,opt}/*/doc に有る tags{,-??} が古ければ再作成
	# コンパイル済みの Python スクリプトにしても大して速度は変わらない
	def MkHelpTags(h: string): void
		var docdir = h .. '/doc'
		if len(glob(docdir .. '/*.{txt,??x}', 1, 1))
			execute 'helptags ' .. docdir
		else
			for f in glob(docdir .. '/tags{,-??}', 1, 1)
				delete(f)
			endfor
		endif
		for d in glob(h .. '/pack/*/{start,opt}/*/doc', 1, 1)
			var dir = fnamemodify(d, ':p:h:h:s?.\+/??')
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

	var h = split(&runtimepath, ',')[0]
	var docdir = h .. '/doc'
	if !isdirectory(docdir)
		mkdir(docdir, 'p', 0o700)
	endif
	var max_tags_time = 0 # tags, tags-?? 最終更新日時取得
	for tags in glob(h .. '/doc/tags{,-??}', 1, 1)
		var tags_time = getftime(tags)
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

def Get_pack_ls(): list<dict<string>> # プラグインの名称、リポジトリ、インストール先取得
	def Packadd_ls(f: string): list<string> # packadd plugin で書かれたプラグイン読み込みを探す
		var packages: list<string>
		for s in systemlist("grep -Ehi '^[^\#\"]*\\<packadd' " .. f)
			add(packages, substitute(s, '\c^[^\#\"]*\<packadd[ \t]\+\([a-z0-9_.-]\+\).*', '\1', ''))
		endfor
		return packages
	enddef

	def Get_packages(f: string, p: list<string>): list<dict<string>> # ファイル f に書かれたプラグインの名称、リポジトリ、インストール先取得
		var packages: list<dict<string>>
		var url: string
		var pack: string
		var pack_dir: string = resolve(expand('~/.vim/pack/github/')) .. '/'

		for s in systemlist("grep -Ehi '^[\#\"\t].+https://github\.com/[a-z0-9._/-]+ {" .. "{{[0-9]*$' " .. f)
			url = substitute(s, '\c^[\#\"\t].\+\(https:\/\/github\.com\/[a-z0-9._/-]\+\/[a-z0-9._-]\+\) \+{' .. '{{\d*', '\1', '')
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

	def Map_ls(f: string): list<string> # set_map_plug#Main(plugin, ...) で書かれたプラグイン読み込みを探す
		var packages: list<string>
		for s in systemlist("grep -Ehi '^[^#\"]*\\<set_map_plug\#Main\\([ \t]*'\\' " .. f)
			add(packages, substitute(s, '\c^[^\#\"]*\<set_map_plug\#Main([ \t]*''\([^'']\+\).*', '\1', ''))
		endfor
		for s in systemlist("grep -Ehi '^[^#\"]*\\<set_map_plug\#Main\\([ \t]*\"' " .. f)
			add(packages, substitute(s, '\c^[^\#\"]*\<set_map_plug\#Main([ \t]*"\([^"]\+\).*', '\1', ''))
		endfor
		return packages
	enddef

	var packages = extendnew(Packadd_ls('~/.vim/plugin/*.vim'), Packadd_ls('~/.vim/autoload/*.vim'))
	extend(packages, Map_ls('~/.vim/plugin/*.vim'))
	extend(packages, Map_ls('~/.vim/autoload/*.vim'))
	uniq(sort(packages))
	return extendnew(Get_packages('~/.vim/plugin/*.vim', packages),
	Get_packages('~/.vim/autoload/*.vim', packages))->sort((lhs, rhs) => lhs.package >? rhs.package ? 1 : -1)
enddef

export def Install(): void # プラグインのインストール
	for s in Get_pack_ls()
		if isdirectory(s.dir)
			echo s.package .. ': installed or already existed direcory'
		else
			echo s.rep .. ' ' .. s.dir
			systemlist('git clone ' .. s.rep .. ' ' .. s.dir)
		endif
	endfor
enddef

export def Reinstall(pack: string): void # プラグインの強制再インストール
	var pack_ls: list<dict<string>> = Get_pack_ls()->filter('v:val.package ==# "' .. pack .. '"')
	if len(pack_ls)
		var dic: dict<string> = pack_ls[0]
		if isdirectory(dic.dir)
			echo 'rm -rf ' .. dic.dir
			delete(dic.dir, 'rf')
		endif
		echo dic.rep .. ' ' .. dic.dir
		systemlist('git clone ' .. dic.rep .. ' ' .. dic.dir)
	else
		echo pack .. ': no setting'
	endif
enddef
