vim9script
scriptencoding utf-8

def AddErrorMessage(id: number, err_msg: list<string>): void
	var var: dict<any> = getwinvar(id, 'popup_image', {err_msg: []})

	setwinvar(id, 'popup_image', extendnew(var, {err_msg: get(var, 'err_msg', []) + [err_msg]}))
enddef

export def Clear(id: number): void
	var opts: dict<any> = popup_getoptions(id)
	if !has_key(opts, 'image')
		if getwinvar(id, 'popup_image', {}) ==# {}
			setwinvar(id, 'popup_image', {
				clear: { # クリアする時に設定するオプション
					highlight: opts.highlight ==# '' ? 'Pmenu' : opts.highlight,
					highlights: opts.highlights ==# '' ? '' : opts.highlights,
					image: {}
				},
				err_msg: [],
				options: { # イメージ表示で変更するオプション
					border: [1, 1, 1, 1],
					opacity: 100
				}
			})
		endif
		var default_opts: dict<any> = getwinvar(id, 'popup_image', {})
		extend(default_opts.options, extendnew(opts, default_opts.clear))
		popup_setoptions(id, default_opts.options)
		setwinvar(id, 'popup_image', default_opts)
	else
		popup_setoptions(id, extendnew(getwinvar(id, 'popup_image', {options: {}}).options, getwinvar(id, 'popup_image', {clear: {}}).clear))
		redraw!
	endif
enddef

export def WarningMsg(id: number): void
	popup_settext(id, remove(getwinvar(id, 'popup_image', {err_msg: []}).err_msg, -1))
	popup_setoptions(id, {highlight: 'WarningMsg'})
enddef

if !executable('mimetype')
	|| !executable('ffprobe')
	|| !executable('ffmpeg')
	|| !executable('gs')
	popup_notification([
		'All video/image: ''mimetype'' command',
		'image:           FFmgeg (ffmpeg/ffprobe command)',
		'video:           FFmgeg (ffmpeg/ffprobe command)',
		'PDF/PostScript:  and GhostScript (gs command)',
	], {title: 'Need following tools ', highlight: 'ErrorMsg', borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'], padding: [0, 1, 0, 1]})
	export def Preview(id: number, f: string): bool
		AddErrorMessage(id, [
			'Need following tools',
			'All video/image: ''mimetype'' command',
			'image:           FFmgeg (ffmpeg/ffprobe command)',
			'video:           FFmgeg (ffmpeg/ffprobe command)',
			'PDF/PostScript:  and GhostScript (gs command)',
		])
		return false
	enddef
	export def ResetPreview(id: number, f: string): void
		return
	enddef
	finish
endif

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
	popup_settext(id, ['making image data...'])
	popup_setoptions(id, {highlight: 'WarningMsg'})
	redraw

	timer_start(1, (_) => {
		var success = GenerateAndSetImage(id, f)

		if OnDone != null
			OnDone(success)
		endif
	})

	return true
enddef

def GenerateAndSetImage(id: number, f: string): bool # パス f の画像、動画、PDF を表示
	if !executable('mimetype')
		AddErrorMessage(id, ['Need ''mimetype'' command'])
		return false
	endif
	var opts: dict<any> = popup_getoptions(id)
	var max_w: number = opts.maxwidth  == 0 ? &columns : opts.maxwidth
	var max_h: number = opts.maxheight == 0 ? &lines   : opts.maxheight

	def ScaleImage(w: number, h: number): list<number>
		var scale: float = min([max_w * 5.0 / w * g:popup_image_options.pt2px.x / 72, max_h * 10.0 / h * g:popup_image_options.pt2px.y / 72])

		if scale > 1
			scale = max([g:popup_image_options.min_size.x * 5.0 / w * g:popup_image_options.pt2px.x / 72, g:popup_image_options.min_size.y * 10.0 / h * g:popup_image_options.pt2px.y / 72])
			if scale > 1
				return [float2nr(round(w * scale)), float2nr(round(h * scale))]
			endif
			return [w, h]
		endif
		return [float2nr(round(w * scale)), float2nr(round(h * scale))]
	enddef

	var p: string = resolve(expand(f, true))
	var w: number
	var h: number
	var t: list<string>
	silent var ft: string = systemlist(['mimetype', '--brief', p])[0]
	var img_data: blob
	var w_h: list<number>

	if has_key(opts, 'image') # 連続して呼び出されたときに、消さないと後ろに残る
		popup_setoptions(id, {image: {}})
		redraw
	endif
	if ft ==# 'application/pdf' || ft ==# 'image/x-eps' || ft ==# 'image/eps' || ft ==# 'application/postscript'
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
		[w, h] = ScaleImage(w_h[2] - w_h[0], w_h[3] - w_h[1])
			img_data = SystemBlob(['sh', '-c', $'gs -q -dNOPAUSE -dBATCH -dEPSCrop -sDEVICE=ppmraw -r600 -dFirstPage=1 -dLastPage=1 -sOutputFile=- {shellescape(p)} | ffmpeg -v error -i - -vf scale={w}:{h} -f rawvideo -pix_fmt rgb24 -'])
	else
		silent [w, h] = split(system(['ffprobe', '-v', 'error', '-select_streams', 'v:0', '-show_entries', 'stream=width,height', '-of', 'csv=p=0', p]), ',')
			->map((_, v) => str2nr(v))
		[w, h] = ScaleImage(w, h)
		img_data = SystemBlob(['ffmpeg'] + t + ['-i', p, '-vf', $'scale={w}:{h}', '-vframes', '1', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-'])
	endif
	if len(img_data) != w * h * 3
		AddErrorMessage(id, [
			'''data size'' is not eqal ''width x height x 3''',
			$'data size:          {len(img_data)}',
			$'width:              {w}',
			$'height:             {h}',
			$'width x height x 3: {w * h * 3}',
		])
		return false
	endif
	popup_setoptions(id, extendnew(getwinvar(id, 'popup_image', {options: {}}).options, {
		image: {data: img_data, width: w, height: h},
		maxwidth: max_w, # 縦横サイズを指定しないと、連続して使われたときに直前に表示された画像サイズに引きずられる
		maxheight: max_h,
		border: [0, 0, 0, 0],
		opacity: 0
	}))
	popup_settext(id, [])
	redraw
	return true
enddef

export def ResetPreview(id: number, f: string): void
	var opts: dict<any> = getwinvar(id, 'popup_image', {options: {}})

	opts.options = extendnew(popup_getoptions(id), {image: {}})
	popup_setoptions(id, getwinvar(id, 'popup_image', {options: {}}).options)
	if tabpagenr() == getwininfo(id)[0].tabnr
		Preview(id, f)
	else
		execute $'autocmd FuzzyFileFinder TabEnter * ++once if tabpagenr() == {getwininfo(id)[0].tabnr} | call popup_image#Preview({id}, ''{f}'') | endif'
	endif
enddef
