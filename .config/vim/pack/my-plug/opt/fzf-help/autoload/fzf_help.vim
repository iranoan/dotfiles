vim9script
scriptencoding utf-8

export def HelpTags(): list<string>
	def GetLang(): dict<number>
		var d: dict<number>
		var i: number

		if &g:helplang == ''
			return {en: 0}
		endif
		for l in split(&g:helplang, ',')
			d[l] = i
			i += 1
		endfor
		return d
	enddef

	var helplang: dict<number> = GetLang()
	var lang_n: number
	var lang_s: string
	var tags: list<string>
	var tags_list: list<dict<any>>
	var tag_width: number
	var file_width: number
	var dir: string

	tags += globpath($MYVIMDIR, 'doc/tags', true, true)
	tags += globpath($MYVIMDIR, 'doc/tags-[a-z][a-z]', true, true)
	tags += globpath($MYVIMDIR, 'pack/*/*/*/doc/tags', true, true)
	tags += globpath($MYVIMDIR, 'pack/*/*/*/doc/tags-[a-z][a-z]', true, true)
	for i in split(&runtimepath, ',')
		tags += globpath(i, 'doc/tags', true, true)
		tags += globpath(i, 'doc/tags-[a-z][a-z]', true, true)
		tags += globpath(i, 'pack/*/*/*/doc/tags', true, true)
		tags += globpath(i, 'pack/*/*/*/doc/tags-[a-z][a-z]', true, true)
	endfor
	sort(tags)->uniq()
	for t in tags
		lang_s = (t =~# '/tags$' ? 'en' : t[-2 : -1])
		lang_n = get(helplang, lang_s, 1000)
		dir = substitute(t, '/[^/]\+$', '', '')
		tags_list += readfile(t)
						->filter((_, v) => v =~# '^[^\t]\+\t[^\t]\+\t[^\t]\+$')
						->filter((_, v) => v !~# '!_TAG_FILE_ENCODING')
						->map((_, v) => split(v, "\t"))
						->filter((_, v) => v[1] =~# '\.\(txt\|\a\ax\)$')
						->map((_, v) => ({
									tag:     v[0],
									search:  escape('*' .. v[0] .. '*', '\*^$.+[(?')->escape('\'),
									file:    substitute(v[1], '.*/', '', ''),
									path:    simplify(dir .. '/' .. v[1]),
									dir:     simplify(dir .. '/' .. v[1])->substitute('^' .. $MYVIMDIR .. '\(pack/\)\?', '', '')->substitute('/doc/[^/]\+$', '', ''),
									# opt:     v[1] =~# '/pack/[^/]\+/opt/[^/]\+/doc/[^/]\+$' ? 'opt' : 'start', # ← 「/opt/」で絞り込めるので使っていない
									lang:    lang_s,
									priority: lang_n
						}))
	endfor

	tag_width = min([23, max(deepcopy(tags_list)->map((_, v) => strdisplaywidth(v.tag)))])
	# file_width = min([20, max(deepcopy(tags_list)->map((_, v) => strdisplaywidth(v.file)))])
	return deepcopy(tags_list)
		->sort((d1, d2) => d1.tag >? d2.tag ? 1 : ( d1.tag <? d2.tag ? -1 : d1.priority - d2.priority ))
		->uniq((d1, d2) => d1.tag ==# d2.tag && d1.lang ==# d2.lang ? 0 : 1)
		->map((_, v) => printf("\x1B[32m%-" .. tag_width .. "S\x1B[0m\t%-2S\t%-15S\t%-S\t%S\t%S",
		                	v.tag, v.lang, v.file, v.dir, v.path, v.search))
enddef

export def HelpTagsSink(line: string): void
	var array: list<string> = split(line, '\s\+')
	var path: string = fnamemodify(array[4], ':p:h:h')
	if stridx(&runtimepath, path) < 0
		execute 'set runtimepath+=' .. path
	endif
	execute('help ' .. join(array[ : 1 ], '@'))
enddef
