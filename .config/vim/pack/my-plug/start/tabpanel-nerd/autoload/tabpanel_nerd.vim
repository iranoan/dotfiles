vim9script
scriptencoding utf-8

var icon_infos: dict<dict<string>> = {
	awk:           {icon: '', cur_hl: 'GlyphPalette0'},
	c:             {icon: '', cur_hl: 'GlyphPalette4'},
	conf:          {icon: '', cur_hl: 'GlyphPalette7'},
	cpp:           {icon: '', cur_hl: 'GlyphPalette4'},
	css:           {icon: '', cur_hl: 'GlyphPalette4'},
	csv:           {icon: '', cur_hl: 'GlyphPalette2'},
	DIFF:          {icon: '', cur_hl: 'GlyphPalette3'},
	dirdiff:       {icon: '', cur_hl: 'GlyphPalette7'},
	fern:          {icon: '', cur_hl: 'GlyphPalette3'},
	fortran:       {icon: '󱈚', cur_hl: 'GlyphPalette13'},
	git:           {icon: '', cur_hl: 'GlyphPalette1'},
	gitattributes: {icon: '', cur_hl: 'GlyphPalette1'},
	gitconfig:     {icon: '', cur_hl: 'GlyphPalette1'},
	gitignore:     {icon: '', cur_hl: 'GlyphPalette1'},
	gunuplot:      {icon: '', cur_hl: 'GlyphPalette9'},
	fugitive:      {icon: '', cur_hl: 'GlyphPalette1'},
	go:            {icon: '', cur_hl: 'GlyphPalette4'},
	haskel:        {icon: '', cur_hl: 'GlyphPalette13'},
	html:          {icon: '', cur_hl: 'GlyphPalette3'},
	xhtml:         {icon: '', cur_hl: 'GlyphPalette3'},
	java:          {icon: '', cur_hl: 'GlyphPalette4'},
	javascript:    {icon: '', cur_hl: 'GlyphPalette3'},
	typescript:    {icon: '', cur_hl: 'GlyphPalette3'},
	json:          {icon: '', cur_hl: 'GlyphPalette4'},
	ksh:           {icon: '', cur_hl: 'GlyphPalette9'},
	HELP:          {icon: '󰞋', cur_hl: 'GlyphPalette3'},
	help:          {icon: '', cur_hl: 'GlyphPalette0'},
	lisp:          {icon: '', cur_hl: 'GlyphPalette0'},
	log:           {icon: '', cur_hl: 'GlyphPalette8'},
	lua:           {icon: '', cur_hl: 'GlyphPalette9'},
	mail:          {icon: '', cur_hl: 'GlyphPalette0'},
	maple:         {icon: '󰲓', cur_hl: 'GlyphPalette6'},
	netrw:         {icon: '', cur_hl: 'GlyphPalette3'},
	make:          {icon: '', cur_hl: 'GlyphPalette4'},
	markdown:      {icon: '', cur_hl: 'GlyphPalette3'},
	perl:          {icon: '', cur_hl: 'GlyphPalette4'},
	python:        {icon: '', cur_hl: 'GlyphPalette3'},
	ruby:          {icon: '', cur_hl: 'GlyphPalette1'},
	scheme:        {icon: '', cur_hl: 'GlyphPalette7'},
	sh:            {icon: '', cur_hl: 'GlyphPalette9'},
	bash:          {icon: '', cur_hl: 'GlyphPalette9'},
	csh:           {icon: '', cur_hl: 'GlyphPalette9'},
	tsh:           {icon: '', cur_hl: 'GlyphPalette9'},
	zsh:           {icon: '', cur_hl: 'GlyphPalette9'},
	TERMINAL:      {icon: '', cur_hl: 'GlyphPalette7'},
	tex:           {icon: '', cur_hl: 'GlyphPalette4'},
	text:          {icon: '', cur_hl: 'GlyphPalette7'},
	tmux:          {icon: '', cur_hl: 'GlyphPalette2'},
	toml:          {icon: '', cur_hl: 'GlyphPalette11'},
	tsv:           {icon: '', cur_hl: 'GlyphPalette2'},
	vim:           {icon: '', cur_hl: 'GlyphPalette2'},
	xml:           {icon: '󰗀', cur_hl: 'GlyphPalette3'},
	yaml:          {icon: '', cur_hl: 'GlyphPalette6'},
}

export def MakeTabPanelColor(): void
	var hl_values: dict<string> = {NonText: 'TabPanelColor0'}
	extend(icon_infos, get(g:, 'tabpanel_icons', {}))
	values(icon_infos)
		->mapnew((_, v) => v.cur_hl)
		->sort()
		->uniq()
		->foreach((i, v) => {
			hl_values[v] = 'TabPanelColor' .. (i + 1)
		})
	var hl: list<dict<any>>
	var hl_tmp: list<dict<any>>
	var hl_one: dict<any> = hlget('TabPanel')[0]
	if has_key(hl_one, 'linksto')
		hl_one = hlget(hl_one.linksto)[0]
	endif
	const tabpanel_cterm = hl_one.ctermbg
	const tabpanel_gui = hl_one.guibg

	for [k, v] in items(hl_values)
		hl_tmp = hlget(k)
		if hl_tmp == []
			hl_one = hlget('TabPanelSel')[0]
		else
			hl_one = hl_tmp[0]
		endif
		if has_key(hl_one, 'linksto')
			hl_one = hlget(hl_one.linksto)[0]
		endif
		if has_key(hl_one, 'font')
			remove(hl_one, 'font')
		endif
		remove(hl_one, 'id')
		add(hl, hl_one->extend({name: v, ctermbg: tabpanel_cterm, guibg: tabpanel_gui}))
	endfor
	hlset(hl)
	map(icon_infos, (_, v) => v->extendnew({nocur_hl: hl_values[v.cur_hl]}))
	return
enddef
MakeTabPanelColor()

augroup TabPanel
	autocmd!
	autocmd OptionSet background call tabpanel_nerd#MakeTabPanelColor()
	autocmd ColorScheme * call tabpanel_nerd#MakeTabPanelColor()
	autocmd BufDelete * autocmd SafeState * ++once redrawtabp
augroup END

export def TabPanel(): string
	def BufLabel(b: dict<any>, w: number, active: bool): string
		const hl = active ? '%*' : '%#TabPanel#'
		const ft: string = (w != 0 && gettabwinvar(g:actual_curtabpage, w, '&diff'))
			? 'DIFF'
			: get({help: 'HELP', terminal: 'TERMINAL'}, getbufvar(b.bufnr, '&buftype'), getbufvar(b.bufnr, '&filetype'))
		const path: string = fnamemodify(b.name, ':p')->substitute('^' .. $HOME .. '\ze[/\\]', '~', '')
		var name: string = ft ==# 'dirdiff' ? '' : fnamemodify(path, ':t')
		var name_len: number = strdisplaywidth(name)
		var c_dir: string = fnamemodify(expand('%'), ':p:h')->substitute('^' .. $HOME .. '\ze[/\\]', '~', '')
		var dir: string
		var width: number = matchstr(&tabpanelopt, '\(columns:\)\@<=\d\+')->str2nr()
		if b.hidden
			name_len = strdisplaywidth(name) + strdisplaywidth(printf('%2d', b.bufnr)) + 1
			name = printf('%s%2d|%s', hl, b.bufnr, name)
		endif
		const icon_info: dict<string> = get(icon_infos, ft, {icon: '', cur_hl: 'TabPanelSel', nocur_hl: 'TabPanel'})
		const icon: string = $'%#{get(icon_info, (active ? 'cur_hl' : 'nocur_hl'), (active ? 'TabPanelSel' : 'TabPanel'))}#{get(icon_info, 'icon', '')}{hl}'
		if ft ==# 'netrw'
			dir = path
		elseif ft ==# 'fugitive'
			dir = fnamemodify(path[ 11 : ], ':h:h')->substitute('^' .. $HOME .. '\ze[/\\]', '~', '')
		elseif ft ==# 'DIFF'
			dir = vimrc#DiffPath(w)
		# elseif ft ==# 'TERMINAL' # terminal のカレントディレクトリの取得方法がない
		# 	# dir = substitute(getcwd(), '^' .. $HOME .. '\ze[/\\]', '~', '')
		# 	dir = fnamemodify(path, ':h:h')->substitute('^' .. $HOME .. '\ze[/\\]', '~', '')
		elseif name ==# '' && ft !=# 'dirdiff'
			dir = c_dir
		else
			dir = fnamemodify(path, ':h')->substitute('^' .. $HOME .. '\ze[/\\]', '~', '')
		endif
		width = (width == 0 ? 20 : width) - (match(&tabpanelopt, '[,=]vert\>') == -1 ? 0 : 1 )
		if ft ==# 'TERMINAL' || dir ==# c_dir
			if name_len + 2 > width
				return icon .. substitute(name, $'\%{width - 2}v.*', $'%#TabPanelColor0#>{hl}', '')
			endif
			return icon .. name
		elseif name_len + 3 > width
			return icon .. substitute(name, $'\%{width - 2}v.*', $'%#TabPanelColor0#>{hl}', '')
		endif
		width = width - name_len
		if strdisplaywidth(dir) - width + 4 < 0
			return $'{icon}{name}%#TabPanelColor0#<{hl}{dir}'
		else
			return $'{icon}{name}%#TabPanelColor0#<{hl}{substitute(dir, $'.*\%{strdisplaywidth(dir) - width + 4}v', '', '')}'
		endif
	enddef

	var label = [$'{g:actual_curtabpage}']
	for w in gettabinfo(g:actual_curtabpage)[0].windows
		add(label, BufLabel(getbufinfo(getwininfo(w)[0].bufnr)[0], w, tabpagenr() == g:actual_curtabpage))
	endfor

	# Show Hiddens
	if g:actual_curtabpage ==# tabpagenr('$')
		const hiddens = getbufinfo({buflisted: 1})->filter((_, v) => v.hidden)
		if !!hiddens
			label->add('%#TabPanel#Hidden')
			for h in hiddens
				label->add(BufLabel(h, 0, false))
			endfor
		endif
	endif

	return label->join("\n")
enddef
