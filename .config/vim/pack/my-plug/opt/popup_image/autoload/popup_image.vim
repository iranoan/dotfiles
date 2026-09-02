vim9script
scriptencoding utf-8

if !g:popup_image_options.loaded
	finish
endif

def MakeBackground(n: string, d: dict<any>): dict<string>
	if has_key(d, 'ctermbg')
		if has_key(d, 'guibg')
			return {name: n, ctermbg: d.ctermbg, guibg: d.guibg}
		else
			return {name: n, ctermbg: d.ctermbg}
		endif
	else
		if has_key(d, 'guibg')
			return {name: n, guibg: d.guibg}
		else
			return {name: n}
		endif
	endif
enddef

def MakeHighlight(): void
	var background: dict<string> = hlget('Pmenu', true)[0]->filter((k, _) => k =~# '\<\(cterm\|gui\)bg\>')
	var WarningMsg: dict<any> = hlget('WarningMsg', true)[0]->filter((k, _) => k !=# '\<\(id\|name\)\>')
	var MessageWindow: dict<any> = hlget('MessageWindow', true)[0]->filter((k, _) => k !=# '\<\(id\|name\)\>')

	hlset([
		extendnew(WarningMsg, MakeBackground('PopupImageWarningMsg', background)),
		extendnew(MessageWindow, MakeBackground('PopupImageMsg', background))
	])
enddef

MakeHighlight()

augroup PopupImageHighlightMsg
	autocmd!
	autocmd ColorScheme * MakeHighlight()
augroup END

def AddErrorMessage(id: number, err_msg: list<string>): void
	var opts: dict<any> = getwinvar(id, 'popup_image', {err_msg: []})

	setwinvar(id, 'popup_image', extendnew(opts, {err_msg: get(opts, 'err_msg', []) + [err_msg]}))
enddef

def SaveOrignalOption(id: number): dict<any>
	var opts: dict<any> = popup_getoptions(id)
	if getwinvar(id, 'popup_image', {}) == {}
		setwinvar(id, 'popup_image', {
			clear: { # クリアする時に設定するオプション
				highlight: opts.highlight,
				highlights: opts.highlights,
				image: {}
			},
			pre_info: { # 直前に表示した情報
				maxwidth: 0,
				maxheight: 0,
				path: ''
			},
			tab_leave_close: false, # タブページの切り替えによって閉じられたたか?
			err_msg: [],
			options: { # イメージ表示で変更するオプション
				highlight: opts.highlight,
				highlights: opts.highlights,
				border: get(opts, 'border', [0, 0, 0, 0]),
				opacity: 100
			}
		})
		var tabnr: number = tabpagenr()
		execute($'augroup PopupImageTabPage{tabnr}')
		autocmd!
		execute($'autocmd TabClosed *             AutocmdDelete({tabnr}, {id})')
		execute($'autocmd TabEnter *              Show({tabnr}, {id})')
		execute($'autocmd TabLeave,TerminalOpen * Hide({tabnr}, {id})')
		execute($'augroup END')
		sleep 10ms # Clear(id: number) の
		# 		extend(default_opts.options, extendnew(opts, default_opts.clear))
		# で options キーがないというエラーが出ることがある
		# 発生条件が掴めていないの、試しに少し時間を置いてみる
	endif
	return opts
enddef

def AutocmdDelete(tabnr: number, id: number): void
	if index(popup_list(), id) == -1
		timer_start(1, (_) => autocmd_delete([{group: $'PopupImageTabPage{tabnr}'}]))
	endif
enddef

def Show(tabnr: number, id: number): void # タブ・ページの切り替えによる再表示
	var opts: dict<any> = popup_getoptions(id)
	var win_opts: dict<any> = getwinvar(id, 'popup_image', {tab_leave_close: false})

	if tabpagenr() == tabnr && index(popup_list(), id) != -1
		if win_opts.tab_leave_close
			popup_show(id)
		endif
		if get(popup_getoptions(id), 'image', {}) != {}
			GenerateAndSetImage(id, getwinvar(id, 'popup_image', {pre_info: {path: '' }}).pre_info.path)
		endif
		win_opts.tab_leave_close = false
	endif
enddef

def Hide(tabnr: number, id: number): void
	var win_opts: dict<any> = getwinvar(id, 'popup_image', {tab_leave_close: false})

	if tabpagenr() == tabnr && index(popup_list(), id) != -1 && popup_getpos(id).visible && popup_getoptions(id).tabpage != -1
		win_opts.tab_leave_close = true
		popup_hide(id)
	endif
enddef

export def Clear(id: number): void
	SaveOrignalOption(id)
	popup_setoptions(id, getwinvar(id, 'popup_image', {clear: {}}).clear)
enddef

export def WarningMsg(id: number): void
	SaveOrignalOption(id)
	popup_settext(id, remove(getwinvar(id, 'popup_image', {err_msg: []}).err_msg, -1))
	popup_setoptions(id, {highlight: 'PopupImageWarningMsg', highlights: 'PopupTitle:Pmenu,Popup:PopupImageWarningMsg'})
enddef

def SystemBlob(cmd: list<string>): blob
	var img: blob
	var b: blob
	var job: job = job_start(cmd, {
		out_io: 'pipe',
		out_mode: 'raw',
		err_io: 'null',
	})
	var ch: channel = job_getchannel(job)

	while ch_status(ch) ==# 'open' || ch_status(ch) ==# 'buffered'
		b = ch_readblob(ch)
		if len(b) > 0
			img += b
		else
			sleep 1m  # CPU100%消費の張り付き防止
		endif
	endwhile
	return img
enddef

def DummyDone(_: bool)
enddef

export def Preview(id: number, f: string, OnDone: func(bool) = DummyDone): bool
	timer_start(1, (_) => {
		var success = GenerateAndSetImage(id, f)

		if OnDone != null
			OnDone(success)
		endif
	})

	return true
enddef

def DefaultOpts(o: dict<any>, d: dict<any>, key: string): string
	if has_key(o, key)
		return o[key]
	else
		return d[key]
	endif
enddef

def GenerateAndSetImage(id: number, f: string): bool # パス f の画像、動画、PDF を表示
	var opts: dict<any> = SaveOrignalOption(id)
	if !executable('mimetype')
		AddErrorMessage(id, ['Need ''mimetype'' command'])
		return false
	endif
	var win_opts: dict<any> = getwinvar(id, 'popup_image', {highlight: '', highlights: ''})
	var max_w: number = get(opts, 'maxwidth', 0)
	var max_h: number = get(opts, 'maxheight', 0)

	def ScaleImage(w: number, h: number): list<number>
		var scale: float = min([max_w * 5.0 / w * g:popup_image_options.pt2px.x / 72,
			max_h * 10.0 / h * g:popup_image_options.pt2px.y / 72])

		if scale > 1
			scale = max([g:popup_image_options.min_size.x * 5.0 / w * g:popup_image_options.pt2px.x / 72,
				g:popup_image_options.min_size.y * 10.0 / h * g:popup_image_options.pt2px.y / 72])
			if scale > 1
				return [float2nr(round(w * scale)), float2nr(round(h * scale))]
			endif
			return [w, h]
		endif
		return [float2nr(round(w * scale)), float2nr(round(h * scale))]
	enddef

	var p: string = resolve(expand(f, true))
	var path: string = p
	var w: number
	var h: number
	var t: list<string>
	silent var ft: string = systemlist(['mimetype', '--brief', p])[0]
	var img_data: blob
	var w_h: list<number>
	var border: number = get(opts, 'border', []) == [] ? 1 : opts.border[0]
	var padding: list<number> = get(opts, 'padding', [0, 0, 0, 0])
	var not_empty_title: bool = get(opts, 'title', '') !=# ''

	max_w = max_w == 0  ? &columns : max_w
	max_h = max_h == 0  ? &lines   : max_h
	if has_key(opts, 'image') # 連続して呼び出されたときに、消さないと後ろに残る
		popup_setoptions(id, {image: {}})
		redraw
	endif
	if ft ==# 'application/pdf' || ft ==# 'image/x-eps' || ft ==# 'image/eps' || ft ==# 'application/postscript' || ft == 'application/epub+zip'
		if !executable('gs') && !executable('ffmpeg')
			AddErrorMessage(id, ['Need ''GhostScript'' and ''FFmpeg'' for PDF/eps/postscript'])
			return false
		endif
	elseif ft =~# '^video/' || ft =~# '^image/'
		if !executable('ffprobe') || !executable('ffmpeg')
			AddErrorMessage(id, ['Need ''FFmpeg'' for image/video'])
			return false
		endif
	else
		AddErrorMessage(id, ['support mimetype', 'video/*', 'image/*', 'application/pdf', 'application/postscript'])
		return false
	endif
	if ft =~# '^video/' # video の最初の一割時点の時刻
		silent t = ['-ss', $'{str2nr(system([ 'ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', p ])) / 10.0}']
	endif
	popup_settext(id, ['Making Image Data...'])
	popup_setoptions(id, {highlight: 'PopupImageMsg', highlights: 'PopupTitle:Pmenu,Popup:PopupImageMsg'})
	redraw
	if ft ==# 'application/pdf' || ft ==# 'image/x-eps' || ft ==# 'image/eps' || ft ==# 'application/postscript'
		var resolution: number
		var resolution_s: string
		if ft ==# 'application/pdf' || ft ==# 'application/postscript'
			resolution = 600
		else
			resolution = 72
		endif
		w_h = systemlist(['gs', '-dQUIET', '-dBATCH', '-dNOPAUSE', '-sDEVICE=bbox', p])
			->matchlist('^%%BoundingBox: \+\zs\(\d\+\.\?\d*\) \(\d\+\.\?\d*\) \(\d\+\.\?\d*\) \(\d\+\.\?\d*\)')[1 : ]
			->map((_, v) => float2nr(round(str2float(v) * resolution / 72)))
		if len(w_h) < 4
			AddErrorMessage(id, [
				'Not Get BoundingBox',
				$'file path: {p}',
			])
			return false
		endif
		[w, h] = ScaleImage(w_h[2] - w_h[0], w_h[3] - w_h[1])
			img_data = SystemBlob(['sh', '-c', $'gs -q -dNOPAUSE -dBATCH -dEPSCrop -sDEVICE=ppmraw -r600 -dFirstPage=1 -dLastPage=1 -sOutputFile=- {shellescape(p)} | ffmpeg -v error -i - -vf scale={w}:{h} -f rawvideo -pix_fmt rgb24 -'])
	else
		var temp: string
		if ft ==# 'application/epub+zip' # Epub は隠し対応
			if executable('gnome-epub-thumbnailer')
				temp = $'{tempname()}.png'
				systemlist(['gnome-epub-thumbnailer', $'{p}', $'{temp}'])
				p = temp
			else
				AddErrorMessage(id, ['Epub need ''gnome-epub-thumbnailer'''])
				return false
			endif
		endif
		silent [w, h] = split(system(['ffprobe', '-v', 'error', '-select_streams', 'v:0', '-show_entries', 'stream=width,height', '-of', 'csv=p=0', p]), ',')
			->map((_, v) => str2nr(v))
		[w, h] = ScaleImage(w, h)
		img_data = SystemBlob(['ffmpeg'] + t + ['-i', p, '-vf', $'scale={w}:{h}', '-vframes', '1', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-'])
		if temp !=# ''
			delete(temp)
		endif
	endif
	if len(img_data) != w * h * 3
		AddErrorMessage(id, [
			'''data size'' is not eqal ''width x height x 3''',
			$'file path:          {p}',
			$'data size:          {len(img_data)}',
			$'width:              {w}',
			$'height:             {h}',
			$'width x height x 3: {w * h * 3}',
		])
		return false
	endif
	popup_setoptions(id, extendnew(opts, extendnew(win_opts.options, {
		image: {data: img_data, width: w, height: h},
		border: not_empty_title ? opts.border : [0, 0, 0, 0],
		padding: border == 0 && not_empty_title ? [1, padding[1], padding[2], padding[3]] : padding,
		opacity: 100
	})))
	win_opts.pre_info = {maxwidth: max_w, maxheight: max_h, path: path}
	setwinvar(id, 'popup_image', win_opts)
	popup_settext(id, [])
	redraw
	return true
enddef

export def ResetPreview(id: number, f: string): void
	var opts: dict<any> = deepcopy(getwinvar(id, 'popup_image', {options: {}}).options)

	extend(opts, popup_getoptions(id))
	filter(opts, (k, _) => k !=# 'image')
	popup_setoptions(id, opts)
	if popup_getpos(id).visible
		GenerateAndSetImage(id, f)
	endif
enddef
