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

	def ListupTags(d: string, f: string): list<dict<any>>
		var dir: string
		var ls: list<dict<any>>
		var lang_n: number
		var lang_s: string

		for t in globpath(d, f, true, true)
			lang_s = (f =~# '/tags$' ? 'en' : t[-2 : -1])
			lang_n = get(helplang, lang_s, 1000)
			dir = substitute(t, '/[^/]\+$', '', '')
			ls += readfile(t)
			        ->filter((_, v) => v =~# '^[^\t]\+\t[^\t]\+\t[^\t]\+$')
			        ->filter((_, v) => v !~# '!_TAG_FILE_ENCODING')
			        ->map((_, v) => split(v, "\t"))
			        ->filter((_, v) => v[1] =~# '\.\(txt\|\a\ax\)$')
			        ->map((_, v) => ({
			          		tag:     v[0],
			          		search:  '*' .. v[0] .. '*',
			          		file:    substitute(v[1], '.*/', '', ''),
			          		path:    simplify(dir .. '/' .. v[1]),
			          		dir:     simplify(dir .. '/' .. v[1])->substitute('^' .. $MYVIMDIR .. '\(pack/\)\?', '', '')->substitute('/doc/[^/]\+$', '', ''),
			          		opt:     v[1] =~# '/pack/[^/]\+/opt/[^/]\+/doc/[^/]\+$' ? 'opt' : 'start',
			          		lang:    lang_s,
			          		priority: lang_n
			        }))
		endfor
		return ls
	enddef

	var tags_list: list<dict<any>> = ListupTags($MYVIMDIR, 'doc/tags')
	var tags: list<any>
	var tag_width: number
	var file_width: number

	tags_list += ListupTags($MYVIMDIR, 'doc/tags-[a-z][a-z]')
	tags_list += ListupTags($MYVIMDIR, 'pack/*/*/*/doc/tags')
	tags_list += ListupTags($MYVIMDIR, 'pack/*/*/*/doc/tags-[a-z][a-z]')
	for i in split(&runtimepath, ',')->filter((_, v) => resolve(v .. '/') !~# '^' .. $MYVIMDIR)
		tags_list += ListupTags(i, 'doc/tags')
		tags_list += ListupTags(i, 'doc/tags-[a-z][a-z]')
		tags_list += ListupTags(i, 'pack/*/*/*/doc/tags')
		tags_list += ListupTags(i, 'pack/*/*/*/doc/tags-[a-z][a-z]')
	endfor
	tag_width = min([20, max(deepcopy(tags_list)->map((_, v) => strdisplaywidth(v.tag)))])
	file_width = min([20, max(deepcopy(tags_list)->map((_, v) => strdisplaywidth(v.file)))])
	return deepcopy(tags_list)
		->sort((d1, d2) => d1.tag >? d2.tag ? 1 : ( d1.tag <? d2.tag ? -1 : d1.priority - d2.priority ))
		->map((_, v) => printf("\x1B[32m%-" .. tag_width .. "S\x1B[0m\t%2S\t%-" .. file_width .. "S\t%S\t%S\t%s",
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
