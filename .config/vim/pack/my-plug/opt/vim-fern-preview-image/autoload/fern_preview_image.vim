vim9script
scriptencoding utf-8

def InitPopup(): void
	# var winids: list<number>
	# var c_winid: number = bufwinid('')
	var options: dict<any> = g:fern_preview_image
	var col: number = get(options, 'col', g:fern#drawer_width + 2)
	var line: number = get(options, 'line', 1)
	var border: list<number> = options.border
	var borderchars: list<string> = options.borderchars
	var width: number = get(options, 'width', &columns - g:fern#drawer_width - 4 - border[1] * strdisplaywidth(borderchars[1]) - border[3] * strdisplaywidth(borderchars[3]))
	var height: number = get(options, 'height', &lines - border[2] - (&laststatus != 0 ? 1 : 0) - &cmdheight - 1)
	var bufnr: number = bufadd('')
	var id: number
	# GetWinIDs(winids, winlayout(), c_winid, row, false)

	setbufvar(bufnr, '&filetype', '')
	setbufvar(bufnr, '&modified', false)
	setbufvar(bufnr, '&bufhidden', 'wipe')
	setbufvar(bufnr, '&buflisted', false)
	setbufvar(bufnr, '&buftype', 'nofile')
	setbufvar(bufnr, '&swapfile', false)
	setbufvar(bufnr, '&undofile', false)
	setbufvar(bufnr, '&number', false)
	id = popup_create(bufnr, {
		title: ' Preview ',
		line: line,
		col: col,
		minwidth: width,
		maxwidth: width,
		minheight: height,
		maxheight: height,
		border: border,
		borderchars: borderchars,
		padding: [0, 1, 0, 1],
		wrap: false,
		borderhighlight: ['Pmenu', 'Pmenu', 'Pmenu', 'Pmenu'],
	})
	b:fern_preview_image = {
		winid: id,
		on: true,
		auto: true
	}
	DefineAutocmd()
enddef

def Update(): void
	var path: string = fern#helper#new().sync.get_cursor_node()['_path']->resolve()

	if getfsize(path) > 104851000 && !general_function#IsBinary(path) # テキストファイルで 100 MB (100*1024*1024) より大きい
		popup_settext(b:fern_preview_image.winid, $'Too large filesize: {path}')
		popup_setoptions(b:fern_preview_image.winid, {highlight: 'WarningMsg', highlights: 'PopupTitle:Pmenu,Popup:WarningMsg'})
		return
	endif
	popup_setoptions(b:fern_preview_image.winid, {highlight: 'Pmenu', highlights: 'PopupTitle:Pmenu,Popup:Pmenu'})
	popup_preview#Preview(b:fern_preview_image.winid, path)
enddef

export def TogglePreview(): void
	if &filetype !=# 'fern'
		return
	endif

	if !has_key(b:, 'fern_preview_image') || index(popup_list(), b:fern_preview_image.winid) == -1
		InitPopup()
		Update()
	elseif b:fern_preview_image.on
		b:fern_preview_image.auto = false
		Hide()
	else
		b:fern_preview_image.auto = true
		Show()
		Update()
	endif
enddef

export def ToggleWrap(): void
	var id: number = b:fern_preview_image.winid
	var wrap: bool = get(popup_getoptions(id), 'wrap', true)

	popup_setoptions(id, {wrap: !wrap})
	echo $'Preview: {wrap ? 'nowrap' : 'wrap'}'
	redraw!
enddef

export def PageUpDown(down_flag: bool): void
	if &filetype !=# 'fern'
		return
	endif
	popup_preview#PageUpDown(b:fern_preview_image.winid, down_flag)
enddef

def CursorMoved(n: number): void
	if &filetype !=# 'fern'
		autocmd! FernPreviewControlWindow * <buffer>
		return
	endif
	if b:fern_preview_image.on == true
		Update()
	endif
enddef

def Show(): void
	if b:fern_preview_image.auto == true
		popup_show(b:fern_preview_image.winid)
		b:fern_preview_image.on = true
	endif
enddef

def Hide(): void
	popup_hide(b:fern_preview_image.winid)
	b:fern_preview_image.on = false
enddef

def Risize(cmdwin: bool): void
	if !has_key(b:, 'fern_preview_image')
			|| index(popup_list(), b:fern_preview_image.winid) == -1
			|| !b:fern_preview_image.on
		return
	endif

	var options: dict<any> = g:fern_preview_image
	var border: list<number> = options.border
	var borderchars: list<string> = options.borderchars
	var width: number = get(options, 'width', &columns - g:fern#drawer_width - 4 - border[1] * strdisplaywidth(borderchars[1]) - border[3] * strdisplaywidth(borderchars[3]))
	var height: number

	if cmdwin
			&& gettabinfo(tabpagenr())[0].windows->map((_, v) => win_gettype(v))->index('command') != -1 # コマンド・ライン・ウィンドウがある
		height = get(options, 'height', &lines - border[2] - (&laststatus != 0 ? 1 : 0) - &cmdheight - &cmdwinheight - 1)
	else
		height = get(options, 'height', &lines - border[2] - (&laststatus != 0 ? 1 : 0) - &cmdheight - 1)
	endif
	popup_setoptions(b:fern_preview_image.winid, {
		minwidth: width,
		maxwidth: width,
		minheight: height,
		maxheight: height
	})
enddef

def DefineAutocmd(): void
	augroup FernPreviewControlWindow
		autocmd! * <buffer>
		autocmd VimResized          *                 Risize(true)
		autocmd BufEnter            <buffer>          Show()
		autocmd BufLeave            <buffer>          Hide()
		autocmd CursorMoved         <buffer> ++nested timer_start(1, CursorMoved)
		autocmd BufDelete           <buffer>          popup_close(b:fern_preview_image.winid)
		execute($'autocmd BufDelete <buffer={winbufnr(b:fern_preview_image.winid)}> autocmd_delete([{{group: ''FernPreviewControlWindow'', bufnr: {bufnr()}}}])')
		execute($'autocmd BufDelete <buffer>         silent! bwipeout! {winbufnr(b:fern_preview_image.winid)}')
		execute($'autocmd BufDelete <buffer>         autocmd_delete([{{group: ''FernPreviewControlWindow'', bufnr: {bufnr()}}}])')
	augroup END
enddef
