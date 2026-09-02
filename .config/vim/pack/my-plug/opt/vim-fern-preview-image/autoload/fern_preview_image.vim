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
	var save_ei: string = &eventignore
	# GetWinIDs(winids, winlayout(), c_winid, row, false)

	&eventignore = 'BufAdd,BufCreate'
	try
		setbufvar(bufnr, '&filetype', '')
	finally
		&eventignore = save_ei
	endtry
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
		auto: true
	}
	DefineAutocmd()
enddef

def PopupVisible(id: number): bool
	if index(popup_list(), id) == -1
		return false
	endif
	return popup_getpos(id).visible
enddef

export def TogglePreview(): void
	if &filetype !=# 'fern'
		return
	endif

	if !has_key(b:, 'fern_preview_image') || index(popup_list(), b:fern_preview_image.winid) == -1
		InitPopup()
		popup_preview#Preview(b:fern_preview_image.winid, fern#helper#new().sync.get_cursor_node()['_path']->resolve())
	elseif PopupVisible(b:fern_preview_image.winid)
		b:fern_preview_image.auto = false
		Hide()
	else
		b:fern_preview_image.auto = true
		Show()
		popup_preview#Preview(b:fern_preview_image.winid, fern#helper#new().sync.get_cursor_node()['_path']->resolve())
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
	if !has_key(b:, 'fern_preview_image')
		return
	endif
	popup_preview#PageUpDown(b:fern_preview_image.winid, down_flag)
enddef

def CursorMoved(n: number): void
	if has_key(b:, 'fern_preview_image')
			&& PopupVisible(b:fern_preview_image.winid)
		popup_preview#Preview(b:fern_preview_image.winid, fern#helper#new().sync.get_cursor_node()['_path']->resolve())
	endif
enddef

def Show(): void
	if b:fern_preview_image.auto == true
		popup_show(b:fern_preview_image.winid)
	endif
enddef

def Hide(): void
	popup_hide(b:fern_preview_image.winid)
enddef

def Risize(cmdwin: bool): void
	var winid: number
	var options: dict<any> = g:fern_preview_image
	var border: list<number> = options.border
	var borderchars: list<string> = options.borderchars
	var width: number = get(options, 'width', &columns - g:fern#drawer_width - 4 - border[1] * strdisplaywidth(borderchars[1]) - border[3] * strdisplaywidth(borderchars[3]))
	var height: number
	var opts: dict<any>

	if cmdwin
			&& gettabinfo(tabpagenr())[0].windows->map((_, v) => win_gettype(v))->index('command') != -1 # コマンド・ライン・ウィンドウがある
		height = get(options, 'height', &lines - border[2] - (&laststatus != 0 ? 1 : 0) - &cmdheight - &cmdwinheight - 1)
	else
		height = get(options, 'height', &lines - border[2] - (&laststatus != 0 ? 1 : 0) - &cmdheight - 1)
	endif
	for v in getbufinfo()
			->filter((_, v) => has_key(v.variables, 'fern_preview_image'))
			->map((_, v) => v.variables.fern_preview_image)
			->filter((_, v) => v.winid != -1 && index(popup_list(), v.winid) != -1)
		winid = v.winid
		# 表示/非表示に関係なくサイズ変更はしておく必要あり
		# そうしないと現在別タブページで、元のタブページに戻った時にリサイズされない
		# opts = extendnew(popup_getoptions(winid), {maxwidth: 0, maxheight: 0})
		opts = popup_getoptions(winid)
		if opts.maxwidth != width || opts.maxheight != height
			popup_setoptions(winid, {
				minwidth: width,
				maxwidth: width,
				minheight: height,
				maxheight: height
			})
			if has_key(b:, 'fern_preview_image') && get(opts, 'image', {}) != {} # カレント・ウィンドウでは直ちに書き換える←fern のウィンドウでないと fern#helper#new() が失敗する
				popup_image#ResetPreview(winid, fern#helper#new().sync.get_cursor_node()['_path']->resolve())
			endif
		endif
	endfor
enddef

def DefineAutocmd(): void
	augroup FernPreviewControlWindow
		autocmd! * <buffer>
		autocmd VimResized          *                 Risize(true)
		autocmd BufEnter            <buffer>          Show()
		autocmd BufLeave            <buffer>          Hide()
		autocmd CursorMoved         <buffer> ++nested timer_start(1, CursorMoved)
		execute($'autocmd BufUnload <buffer>          popup_close({b:fern_preview_image.winid})')
		execute($'autocmd BufUnload <buffer>          silent! bwipeout! {winbufnr(b:fern_preview_image.winid)}')
		execute($'autocmd BufDelete <buffer>          autocmd_delete([{{group: ''FernPreviewControlWindow'', bufnr: {bufnr()}}}])')
	augroup END
	nnoremap <buffer><Esc> <Cmd>call <SID>Hide()<CR>
enddef
