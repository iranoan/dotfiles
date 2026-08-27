vim9script
scriptencoding utf-8

var istalled_popup_image: bool = getscriptinfo({name: '/plugin/popup_image.vim'}) != []

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

def GetFileInfo(dir: string): list<dict<any>>
	var d: string = dir =~# '/$' ? dir : $'{dir}/'
	var info: list<dict<any>>
	var size: number
	var size_s: string
	var type: string = getfperm(d)
	var lower_name: string
	var time: number
	var time_iso: number
	var f: string

	if type !~# '^r........$' # 読み取り権限がない→ディクトリ自身の情報のみ返す
		time = getftime(d)
		return [{
			type: 'dir',
			permission: $'d{type}',
			size: 0,
			size_s: 0,
			time: time,
			time_iso: strftime('%F %T', time),
			name: './',
			lower_name: './',
			link: ''
		}]
	endif
	for p in readdir(d)
		f = fnamemodify($'{d}{p}', ':p')
		f = f =~# '[/\\]$' ? f[ : -2 ] : f # 末尾に / があると、シンボリックリンクでも dir 扱いになる
		type = getftype(f)
		lower_name = tolower(p)
		time = getftime(f)
		if type ==# 'dir'
			add(info, {
				type: type,
				permission: $'d{getfperm(f)}',
				size: 0,
				size_s: '0',
				time: time,
				time_iso: strftime('%F %T', time),
				name: p,
				lower_name: lower_name,
				link: ''
			})
		elseif type ==# 'link'
			f = resolve(f)
			add(info, {
				type: type,
				permission: $'l{getfperm(f)}',
				size: 0,
				size_s: '0',
				time: time,
				time_iso: strftime('%F %T', time),
				name: p,
				lower_name: lower_name,
				link: f
			})
		else
			size = getfsize(f)
			if size > 1099511627776 # T
				size_s = printf('%.1fT', size / 1099511627776.0)
			elseif size > 1073741824 # G
				size_s = printf('%.1fG', size / 1073741824.0 )
			elseif size > 1048576 # M
				size_s = printf('%.1fM', size / 1048576.0 )
			elseif size > 1024 # K
				size_s = printf('%.1fK', size / 1024.0 )
			else
				size_s = $'{size}'
			endif
			add(info, {
				type: type,
				permission: $'-{getfperm(f)}',
				size: size,
				size_s: size_s,
				time: time,
				time_iso: strftime('%F %T', time),
				name: p,
				lower_name: lower_name,
				link: ''
			})
		endif
	endfor
	return info
enddef

export def Preview(id: number, p: string): void
	var type: string = GetFileType(p)
	var bufnr: number = winbufnr(id)

	if !has_key(w:, 'popup_preview')
		w:popup_preview = {
			path: p,
			options: {highlight: 'Pmenu', highlights: 'PopupTitle:Pmenu,Popup:Pmenu'}
		}
	elseif w:popup_preview.path !=# p
		w:popup_preview.path = p
	else
		return
	endif
	if istalled_popup_image
		popup_image#Clear(id)
	endif
	popup_setoptions(id, w:popup_preview.options)
	setbufvar(bufnr, '&filetype', '')
	if isdirectory(p)
		var files: list<dict<any>> = GetFileInfo(p)
		var max_len: number = max(files->mapnew((_, v) => len(v.size_s)))
		popup_settext(id, sort(files, (v0, v1) =>
		                                         v0.time > v1.time ? -1 : v0.time < v1.time ? 1 : # 更新日時降順
		                                         v0.lower_name < v1.lower_name ? -1 : v0.lower_name > v1.lower_name ? 1 : # ファイル名順 (大小文字区別なし)
		                                         v0.name < v1.name ? -1 : 1 ) # 大文字先
		                              ->mapnew((_, v) =>
		                                        printf($'%s %{max_len}s %s %s%s',
		                                        	v.permission, v.size_s, v.time_iso, v.name, v.type ==# 'link' ? $' -> {v.link}' : ''))
		)
	elseif filereadable(p)
		if index(g:popup_preview.image, tolower(fnamemodify(p, ':e'))) != -1
			if istalled_popup_image
				popup_image#Preview(id, p, (v) => {
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
				popup_setoptions(id, {highlight: 'WarningMsg', highlights: 'PopupTitle:Pmenu,Popup:WarningMsg'})
			endif
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
					popup_setoptions(id, {highlight: 'WarningMsg', highlights: 'PopupTitle:Pmenu,Popup:WarningMsg'})
				endif
			else
				popup_settext(id, [ $'<filter command ''{filter[0]}'' can not executable>'])
				popup_setoptions(id, {highlight: 'WarningMsg', highlights: 'PopupTitle:Pmenu,Popup:WarningMsg'})
			endif
		elseif general_function#IsBinary(p)
			popup_settext(id, '<Binary file>')
			popup_setoptions(id, {highlight: 'WarningMsg', highlights: 'PopupTitle:Pmenu,Popup:WarningMsg'})
		else
			popup_settext(id, readfile(p))
			setbufvar(bufnr, '&filetype', type)
		endif
	else
		popup_settext(id, '<Unreadable file>')
		popup_setoptions(id, {highlight: 'WarningMsg', highlights: 'PopupTitle:Pmenu,Popup:WarningMsg'})
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
