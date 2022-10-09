vim9script
# ~/.vim/pack/*/{stat,opt}/*/doc に有るヘルプのタグを ~/.vim/doc/tags{,??x} に出力 (packadd しなくても、help が開けるようになる)
scriptencoding utf-8

def s:mkHelpTags(h: string): void
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

# ~/.vim/pack/*/{stat,opt}/*/doc に有る tags{,-??} が古ければ再作成
# コンパイル済みの Python スクリプトにしても大して速度は変わらない
def pack_helptags#remakehelptags(): void
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
			s:mkHelpTags(h)
			return
		endif
	endfor
enddef
