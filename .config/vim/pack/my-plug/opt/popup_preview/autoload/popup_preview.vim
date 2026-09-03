vim9script
scriptencoding utf-8

var istalled_popup_image: bool = getscriptinfo({name: '/plugin/popup_image.vim'}) != []

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
		extendnew(WarningMsg, MakeBackground('PopupPreviewWarningMsg', background)),
		extendnew(MessageWindow, MakeBackground('PopupPreviewMsg', background))
	])
enddef

MakeHighlight()

augroup PopupPreviewHighlightMsg
	autocmd!
	autocmd ColorScheme * MakeHighlight()
augroup END

def GetFileType(p: string): string
	var f: string = tolower(p)
	var t = get(g:popup_preview, 'type')
	var ext: string = fnamemodify(f, ':e')
	var f_type: string = get(t.ext, ext, get(t.name, fnamemodify(f, ':t'), ''))

	if fnamemodify(f, ':r:e') ==# 'tar' && index(['gz', 'bz2', 'xz', 'z', 'lzma'], ext) != -1
		ext = $'tar.{ext}'
	endif
	if f_type !=# ''
		return f_type
	endif
	for i in t.path
		if match(p, i.reg) != -1
			return i.type
		endif
	endfor
	return ext !=# '' ? ext : 'text'
enddef

def HumanReadableSize(n: number): string
	if n > 10995116277760 # 10TB より大きい
		return printf('%.1fTB', n / 1099511627776.0)
	elseif n > 10737418240
		return printf('%.1fGB', n / 1073741824.0 )
	elseif n > 10485760
		return printf('%.1fMB', n / 1048576.0 )
	elseif n > 10240
		return printf('%.1fKB', n / 1024.0 )
	else
		return $'{n} B'
	endif
enddef

def GetFileInfo(dir: string): list<dict<any>>
	var d: string = dir =~# '/$' ? dir : $'{dir}/'
	var info: list<dict<any>>
	var size: number
	var type: string = getfperm(d)
	var time: number
	var time_iso: number
	var f: string
	var link_type: bool

	if type !~# '^r........$' # 読み取り権限がない→ディクトリ自身の情報のみ返す
		time = getftime(d)
		return [{
			type: 1,
			permission: $'d{type}',
			size: 0,
			size_s: '0 B',
			time: time,
			time_iso: strftime('%F %T', time),
			name: './',
			link: '',
			broken_link: false
		}]
	endif
	for p in readdir(d)->sort('l')
		f = fnamemodify($'{d}{p}', ':p')
		f = f =~# '[/\\]$' ? f[ : -2 ] : f # 末尾に / があると、シンボリックリンクでも dir 扱いになる
		type = getftype(f)
		time = getftime(f)
		if type ==# 'dir'
			add(info, {
				type: 1,
				permission: $'d{getfperm(f)}',
				size: 0,
				size_s: '0 B',
				time: time,
				time_iso: strftime('%F %T', time),
				name: p,
				link: '',
				broken_link: false
			})
		elseif type ==# 'link'
			f = resolve(f)
			if getftype(f) ==# '' # リンクが切れている
				add(info, {
					type: 0,
					permission: 'l---------',
					size: 0,
					size_s: '---',
					time: localtime(),
					time_iso: strftime('%F %T'),
					name: p,
					link: f,
					broken_link: true
				})
			else
				link_type = getftype(f) ==# 'dir'
				size = getfsize(f)
				time = getftime(f)
				add(info, {
					type: link_type ? 1 : 2,
					permission: $'l{getfperm(f)}',
					size: size,
					size_s: HumanReadableSize(size),
					time: time,
					time_iso: strftime('%F %T', time),
					name: p,
					link: $'{f}{link_type ? '/' : ''}',
					broken_link: false
				})
			endif
		else
			size = getfsize(f)
			add(info, {
				type: 2,
				permission: $'{type ==# 'file' ? '-' : type ==# 'bdev' ? 'b' : type ==# 'cdev' ? 'c' : type ==# 'socket' ? 's' : 'p'}{getfperm(f)}',
				size: size,
				size_s: HumanReadableSize(size),
				time: time,
				time_iso: strftime('%F %T', time),
				name: p,
				link: '',
				broken_link: false
			})
		endif
	endfor
	return info
enddef

def SetFileType(n: number, t: string): void
	var save_ei: string = &eventignore

	&eventignore = 'BufAdd,BufCreate'
	try
		setbufvar(n, '&filetype', t)
	finally
		&eventignore = save_ei
	endtry
enddef

export def Preview(id: number, p: string, z: number = 0): void
	var type: string = GetFileType(p)
	var bufnr: number = winbufnr(id)

	if getwinvar(id, 'popup_preview_path', '') !=# p
		setwinvar(id, 'popup_preview_path', p)
	elseif !istalled_popup_image # ファイルが同じで popup_image もない→画像表示もない
		return
	else # ファイルが同じで popup_image がある→画像表示がある
		var opts: dict<any> = popup_getoptions(id)
		var pre_opts: dict<any> = getwinvar(id, 'popup_image', {pre_info: {
			maxwidth: 0,
			maxheight: 0
		}}).pre_info
		if opts.maxwidth == pre_opts.maxwidth && opts.maxheight == pre_opts.maxheight # サイズ変更なし
			return
		endif
	endif
	if istalled_popup_image
		popup_image#Clear(id)
	endif
	popup_setoptions(id, {firstline: 1, highlight: 'Pmenu', highlights: 'PopupTitle:Pmenu,Popup:Pmenu'})
	if isdirectory(p)
		var files: list<dict<any>> = GetFileInfo(p)
		var max_len: number = max(files->mapnew((_, v) => len(v.size_s)))
		popup_settext(id, sort(files, (v0, v1) =>
		                               v0.type > v1.type ?  1 : v0.type < v1.type ? -1 : # dir, file の種別
		                               v0.time > v1.time ? -1 : v0.time < v1.time ?  1 : # 更新日時降順
		                               0 # 名前順は GetFileInfo() 内で locale でソート済み
		                       )
		                       ->mapnew((_, v) =>
		                                 printf($'%s %{max_len}s %s %s%s',
		                                 v.permission, v.size_s, v.time_iso, v.name, v.link ==# '' ? '' : $' {v.broken_link ? '!->' : '->'} {v.link}'))
		)
		SetFileType(bufnr, 'LsLike')
	elseif !filereadable(p)
		popup_settext(id, '<Unreadable file>')
		popup_setoptions(id, {highlight: 'PopupPreviewWarningMsg', highlights: 'PopupTitle:Pmenu,Popup:PopupPreviewWarningMsg'})
		SetFileType(bufnr, 'WarningMsg')
	elseif index(g:popup_preview.image, tolower(fnamemodify(p, ':e'))) != -1
		if istalled_popup_image
			popup_image#Preview(id, p, z, (v) => {
				if !v
					popup_image#WarningMsg(id)
				endif
			})
		else
			popup_settext(id, [
				'<Image/Video/PDF/PostScript file>',
				'',
				'Need popup_image plugin and Need following tools',
				'All video/image: ''mimetype'' command',
				'image:           FFmgeg (ffmpeg/ffprobe command)',
				'video:           FFmgeg (ffmpeg/ffprobe command)',
				'PDF/PostScript:  ImageMagick (magick command)',
			])
			popup_setoptions(id, {highlight: 'PopupPreviewWarningMsg', highlights: 'PopupTitle:Pmenu,Popup:PopupPreviewWarningMsg'})
		endif
		SetFileType(bufnr, 'Image')
	elseif index(keys(g:popup_preview.filter), type) != -1
		var filter: list<string> = g:popup_preview.filter[type]
		var filter_place_folder: number = index(filter, '.')
		filter = filter_place_folder == -1 ? filter + [p] :
			filter_place_folder == len(filter) ? filter[ : -2 ] + [p] :
			filter[ : filter_place_folder - 1 ] + [p] + filter[ filter_place_folder + 1 : ]
		if executable(filter[0])
			popup_settext(id, systemlist(filter))
			if v:shell_error != 0
				popup_settext(id, [ $'<Failed to execute ''{join(filter)}''>'])
				popup_setoptions(id, {highlight: 'PopupPreviewWarningMsg', highlights: 'PopupTitle:Pmenu,Popup:PopupPreviewWarningMsg'})
				SetFileType(bufnr, 'WarningMsg')
			else
				SetFileType(bufnr, 'Stdoutput')
			endif
		else
			popup_settext(id, [ $'<filter command ''{filter[0]}'' can not executable>'])
			popup_setoptions(id, {highlight: 'PopupPreviewWarningMsg', highlights: 'PopupTitle:Pmenu,Popup:PopupPreviewWarningMsg'})
			SetFileType(bufnr, 'WarningMsg')
		endif
	elseif general_function#IsBinary(p)
		popup_settext(id, '<Binary file>')
		popup_setoptions(id, {highlight: 'PopupPreviewMsg', highlights: 'PopupTitle:Pmenu,Popup:PopupPreviewMsg'})
		SetFileType(bufnr, 'WarningMsg')
	elseif getfsize(p) > 104851000 # テキストファイルで 100 MB (100*1024*1024) より大きい
		popup_settext(id, ['<Too large file size>', $'path: {p}', $'size:  {HumanReadableSize(getfsize(p))}'])
		popup_setoptions(id, {highlight: 'PopupPreviewMsg', highlights: 'PopupTitle:Pmenu,Popup:PopupPreviewMsg'})
	else
		popup_settext(id, readfile(p))
		SetFileType(bufnr, type)
	endif
	setbufvar(bufnr, '&modified', false)
enddef

export def PageUpDown(id: number, down_flag: bool): void
	var bufnr: number = winbufnr(id)
	var max_idx: number = len(getbufline(bufnr, 1, '$'))
	var new_idx: number = getcurpos(id)[1]
	var s: dict<any> = popup_getoptions(id)

	if down_flag
		new_idx += popup_getoptions(id).maxheight
	else
		new_idx -= popup_getoptions(id).maxheight
	endif
	new_idx = max([1, min([new_idx, max_idx - 1])])
	if new_idx >= 1 && new_idx < max_idx
		popup_setoptions(id, {firstline: new_idx})
		win_execute(id, $'setpos(".", [{bufnr}, {new_idx}, 1, 0])')
	endif
enddef
