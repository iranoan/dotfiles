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

export def AddErrorMessage(id: number, err_msg: list<string>): void
	SaveOrignalOption(id)
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
				wrap: opts.wrap,
				opacity: opts.opacity, # popup_image#WarningMsg() で変更される
				image: {}
			},
			pre_info: { # 直前に表示した情報
				maxwidth: 0,
				maxheight: 0,
				fit_zoom: true,
				path: ''
			},
			tab_leave_close: false, # タブページの切り替えやターミナルの出現によって閉じられたたか?
			err_msg: [],
			job: null_job,
			options: { # イメージ表示で変更するオプション
				maxwidth:  opts.maxwidth,
				maxheight: opts.maxheight,
				highlight: opts.highlight,
				highlights: opts.highlights,
				border: get(opts, 'border', [0, 0, 0, 0]),
			}
		})
		var tabnr: number = tabpagenr()
		execute($'augroup PopupImageTabPage{tabnr}')
		autocmd!
		execute($'autocmd TabClosed             * AutocmdDelete({tabnr}, {id})')
		execute($'autocmd TabEnter              * Show({tabnr}, {id})')
		execute($'autocmd WinLeave              * if &buftype ==# "terminal" | Show({tabnr}, {id}) | endif')
		execute($'autocmd TabLeave,TerminalOpen * Hide({tabnr}, {id})')
		execute($'augroup END')
		# sleep 10ms # Clear() で options キーがないというエラーが出ることがある
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
			Preview(id, getwinvar(id, 'popup_image', {pre_info: {path: '' }}).pre_info.path, 0)
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
	if index(popup_list(), id) == -1
		return
	endif
	SaveOrignalOption(id)
	popup_setoptions(id, getwinvar(id, 'popup_image', {clear: {}}).clear)
enddef

export def WarningMsg(id: number): void
	if index(popup_list(), id) == -1
		return
	endif
	SaveOrignalOption(id)
	popup_settext(id, remove(getwinvar(id, 'popup_image', {err_msg: []}).err_msg, -1))
	popup_setoptions(id, {highlight: 'PopupImageWarningMsg', highlights: 'PopupTitle:Pmenu,Popup:PopupImageWarningMsg', opacity: 100})
enddef

def DummyDone(_: bool)
enddef

export def Preview(id: number, f: string, z: number = 0, OnDone: func(bool) = DummyDone): void
	if index(popup_list(), id) == -1
		AddErrorMessage(id, ['Already close pop-up'])
		OnDone(false)
		return
	endif
	var opts: dict<any> = SaveOrignalOption(id)
	var win_opts: dict<any> = getwinvar(id, 'popup_image', {highlight: '', highlights: ''})
	popup_settext(id, ['Making Image Data...'])
	popup_setoptions(id, {wrap: true, highlight: 'PopupImageMsg', highlights: 'PopupTitle:Pmenu,Popup:PopupImageMsg'})
	redraw
	sleep 1m # 時間のかかるこの後の処理前に上のメッセージを確実に表示する

	if win_opts.job != null_job && job_status(win_opts.job) == 'run'
		job_stop(win_opts.job)
		extend(win_opts, {job: null_job})
	endif

	var max_w: number # popup の最大桁数
	var max_h: number # popup の最大行数
	var fit_zoom: bool
	if !executable('mimetype')
		AddErrorMessage(id, ['Need ''mimetype'' command'])
		OnDone(false)
		return
	endif
	if win_opts.options.maxwidth == 0 || win_opts.options.maxheight == 0 # 呼び出し時にウィンドウサイズの指定がない
		max_w = &columns
		max_h = &lines
	elseif z == -2
		max_w = win_opts.options.maxwidth
		max_h = win_opts.options.maxheight
	else
		max_w = get(opts, 'maxwidth', 0)
		max_h = get(opts, 'maxheight', 0)
	endif

	def ScaleImage(w: number, h: number): list<number>
		var scale: float = min([max_w * 5.0 / w * g:popup_image_options.pt2px.x / 72,
			max_h * 10.0 / h * g:popup_image_options.pt2px.y / 72])
		var cols: number
		var lines: number

		if fit_zoom && scale > 1
			scale = max([g:popup_image_options.min_size.x * 5.0 / w * g:popup_image_options.pt2px.x / 72,
				g:popup_image_options.min_size.y * 10.0 / h * g:popup_image_options.pt2px.y / 72])
			if scale <= 1
				scale = 1.0
			endif
		endif
		cols =  float2nr(round(scale / 5.0 * w / g:popup_image_options.pt2px.x * 72 + 0.5))
		lines = float2nr(round(scale / 10.0 * h / g:popup_image_options.pt2px.y * 72 + 0.5))
		return [float2nr(round(w * scale)), float2nr(round(h * scale)), cols, lines]
	enddef

	var p: string = resolve(expand(f, true))
	var path: string = p
	var w: number
	var h: number
	var t: list<string>
	var ft: string = systemlist(['mimetype', '--brief', p])[0]
	var w_h: list<number>
	var border: number = get(opts, 'border', []) == [] ? 1 : opts.border[0]
	var padding: list<number> = get(opts, 'padding', [0, 0, 0, 0])
	var not_empty_title: bool = get(opts, 'title', '') !=# ''
	var img_cols: number # 画像の桁数相当サイズ
	var img_lines: number # 画像の行数相当サイズ

	def ConvPrevImage(cmd: list<string>, delete: string, in_data: blob = null_blob): void
		var out_data: blob
		var err_line: string
		var job_exited: bool
		var channel_closed: bool
		var job_obj: job
		var job_exit_code: number = -1
		var curr_cmd: list<string>
		var next_cmd: list<string>
		var pipe_idx: number = index(cmd, '|')

		def SetImage(): void
			if len(out_data) != w * h * 3
				AddErrorMessage(id, [
					'''data size'' is not eqal ''width x height x 3''',
					$'file path:          {p}',
					$'data size:          {len(out_data)}',
					$'width:              {w}',
					$'height:             {h}',
					$'width x height x 3: {w * h * 3}',
				])
				if OnDone != null
					OnDone(false)
				endif
				return
			endif
			if win_opts.options.maxwidth == 0 || win_opts.options.maxheight == 0 # 呼び出し時にウィンドウサイズの指定がない
					|| z == -2 # 若しくは、第3引数で指定
				max_w = img_cols
				max_h = img_lines
			endif
			popup_setoptions(id, extendnew(opts, extendnew(win_opts.options, {
				image: {data: out_data, width: w, height: h},
				minwidth: max_w,
				minheight: max_h,
				maxwidth: max_w,
				maxheight: max_h,
				border: not_empty_title ? opts.border : [0, 0, 0, 0],
				padding: border == 0 && not_empty_title ? [1, padding[1], padding[2], padding[3]] : padding,
			})))
			extend(win_opts.pre_info, {maxwidth: max_w, maxheight: max_h, path: path})
			setwinvar(id, 'popup_image', win_opts)
			popup_settext(id, [])
			redraw
			if OnDone != null
				OnDone(true)
			endif
		enddef

		def TryFinish(): void
			if !job_exited || !channel_closed
				return
			endif
			if job_exit_code < 0 # job_stop() で終了
				AddErrorMessage(id, [$'Cancel Image Data Conversion: {p}'])
				OnDone(false)
				return
			elseif job_exit_code != 0 # プログラム自体のコマンドエラー
				var stdout: list<string>
				if OnDone != null
					if type(out_data) == v:t_blob && out_data != null_blob
						try
							stdout = blob2str(out_data)
						catch /^Vim\%((\S\+)\)\=:E1515:/
						endtry
					endif
					AddErrorMessage(id, ['Convert Error'] + stdout + split(err_line, "[\n\r]"))
					OnDone(false)
				endif
				return
			endif
			if !empty(next_cmd) # 次に実行すべきコマンド群(next_cmd)が残っていれば再帰呼び出し
				ConvPrevImage(next_cmd, delete, out_data)
			else # パイプの最後のコマンドまで到達したら画像を表示
				SetImage()
				if delete !=# '' && filereadable(delete)
					delete(delete)
				endif
			endif
		enddef

		if pipe_idx != -1
			curr_cmd = cmd[0 : pipe_idx - 1]
			next_cmd = cmd[pipe_idx + 1 : -1]
		else
			curr_cmd = cmd
			next_cmd = []
		endif
		job_obj = job_start(curr_cmd, extendnew({ # まず共通部分のオプション
			out_io: 'pipe',
			err_io: 'pipe',
			out_mode: 'blob',
			err_mode: 'nl',
			out_cb: (_, data: blob) => {
				out_data += data
			},
			err_cb: (_, msg: string) => {
				err_line ..= msg
			},
			close_cb: (_) => { # channel が閉じられていることの確認←出力の取りこぼしを防ぐ
				channel_closed = true
				TryFinish() # 本来は job の終了を確認すべきだが、結果的に呼び出し先で確認している
			},
			exit_cb: (_, status: number) => {
				job_exited = true
				extend(win_opts, {job: null_job})
				if delete !=# ''
					delete(p)
				endif
				job_exit_code = status
				TryFinish()
			}
		}, in_data != null_blob ? { # データを標準入力から読み込む場合
			in_io: 'pipe',
			in_mode: 'blob'
		} : {}))
		extend(win_opts, {job: job_obj})
		if in_data != null_blob
			var ch = job_getchannel(job_obj)
			ch_sendraw(ch, in_data)
			ch_close_in(ch)
		endif
		return
	enddef

	if glob(p, true, true) == []
		AddErrorMessage(id, [$'Don''t Exist: {p}'])
		OnDone(false)
		return
	endif
	if !filereadable(p)
		AddErrorMessage(id, [$'Unreaadable: {p}'])
		OnDone(false)
		return
	endif
	max_w = max_w == 0  ? &columns : max_w
	max_h = max_h == 0  ? &lines   : max_h
	if has_key(opts, 'image') # 連続して呼び出されたときに、消さないと後ろに残る
		popup_setoptions(id, {image: {}})
		redraw
	endif
	if ft ==# 'application/pdf' || ft ==# 'image/x-eps' || ft ==# 'image/eps' || ft ==# 'application/postscript'
		if !executable('gs') && !executable('ffmpeg')
			AddErrorMessage(id, ['Need ''GhostScript'' and ''FFmpeg'' for PDF/eps/postscript'])
			OnDone(false)
			return
		endif
	elseif ft =~# '^video/' || ft =~# '^image/'
		if !executable('ffprobe') || !executable('ffmpeg')
			AddErrorMessage(id, ['Need ''FFmpeg'' for image/video'])
			OnDone(false)
			return
		endif
	endif
	if ft =~# '^video/' # video の最初の一割時点の時刻
		silent t = ['-ss', $'{str2nr(system([ 'ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', p ])) / 10.0}']
	endif
	if z == 0
		fit_zoom = win_opts.pre_info.fit_zoom
	elseif z == 1
		extend(win_opts.pre_info, {fit_zoom: false})
		fit_zoom = false
	else # if z == -1 || z == -2
		extend(win_opts.pre_info, {fit_zoom: true})
		fit_zoom = true
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
		if len(w_h) < 4
			AddErrorMessage(id, [
				'Not Get BoundingBox',
				$'file path: {p}',
			])
			OnDone(false)
			return
		endif
		[w, h, img_cols, img_lines] = ScaleImage(w_h[2] - w_h[0], w_h[3] - w_h[1])
		ConvPrevImage(['gs', '-q', '-dNOPAUSE', '-dBATCH', '-dEPSCrop', '-sDEVICE=ppmraw', '-r150', '-dFirstPage=1', '-dLastPage=1', '-sOutputFile=-', p, '|', 'ffmpeg', '-hide_banner', '-v', 'error', '-i', '-', '-vf', $'scale={w}:{h}', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-'], '')
	else
		var temp: string
		var plugin: string = get(get(g:popup_image_options, 'plugin', {}), ft, '')
		if plugin !=# ''
			temp = call(plugin, [id, p])
			if temp ==# ''
				OnDone(false)
				return
			endif
			p = temp
		endif
		silent [w, h] = split(system(['ffprobe', '-v', 'error', '-select_streams', 'v:0', '-show_entries', 'stream=width,height', '-of', 'csv=p=0', p]), ',')
			->map((_, v) => str2nr(v))
		[w, h, img_cols, img_lines] = ScaleImage(w, h)
		ConvPrevImage(['ffmpeg', '-hide_banner'] + t + ['-i', p, '-vf', $'scale={w}:{h}', '-vframes', '1', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-'], temp)
	endif
enddef

export def ResetPreview(id: number, f: string): void
	if index(popup_list(), id) == -1
		return
	endif
	var opts: dict<any> = getwinvar(id, 'popup_image', {options: {}})

	extend(opts.options, popup_getoptions(id)->filter((k, _) => k !=# 'image'))
	popup_setoptions(id, opts.options)
	if popup_getpos(id).visible
		Preview(id, f, 0)
	endif
enddef
defcompile
