vim9script
scriptencoding utf-8

def Cleanup(s: dict<any>): void
	if s.render_timer != 0
		timer_stop(s.render_timer)
		s.render_timer = 0
	endif
	if has_key(s, 'job') && job_status(s.job) == 'run'
		s.canceled = true
		var ch = job_getchannel(s.job)
		if ch_status(ch) != 'closed'
			ch_close_in(ch)
		endif
		job_stop(s.job, 'kill')
		s.job = null_job
	endif
	if s.list_winid > 0
		popup_close(s.list_winid)
		s.list_winid = 0
	endif
	if s.preview_winid > 0
		popup_close(s.preview_winid)
		s.preview_winid = 0
	endif
	if tabpagenr() == s.tabnr
		tabclose
	endif
	if bufexists(s.filter_buf)
		execute $'silent! bwipeout! {s.filter_buf}'
	endif
	if bufexists(s.list_buf)
		execute $'silent! bwipeout! {s.list_buf}'
	endif
	if bufexists(s.preview_buf)
		execute $'silent! wbipeout! {s.preview_buf}'
	endif
	stopinsert
enddef

def GetFileType(p: string): string
	var f: string = tolower(p)
	var t = get(g:fuzzy_file_finder, 'type')
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
	var info: list<dict<any>>
	var size: number
	var size_s: string
	var type: string
	var name: string
	var lower_name: string
	var time: number
	var time_iso: number

	for p in glob($'{match(dir, '/$') != -1 ? dir[ : -2 ] : dir}/*', true, true, true)
		type = getftype(p)
		name = fnamemodify(p, ':t')
		lower_name = tolower(name)
		time = getftime(p)
		if type ==# 'dir'
			add(info, {
				type: type,
				permission: $'d{getfperm(p)}',
				size: 0,
				size_s: '0',
				time: time,
				time_iso: strftime('%F %T', time),
				name: name,
				lower_name: lower_name,
				link: ''
			})
		elseif type ==# 'link'
			add(info, {
				type: type,
				permission: 'lrwxrwxrwx',
				size: 0,
				size_s: '0',
				time: time,
				time_iso: strftime('%F %T', time),
				name: name,
				lower_name: lower_name,
				link: resolve(p)
			})
		else
			size = getfsize(p)
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
				permission: $'-{getfperm(p)}',
				size: size,
				size_s: size_s,
				time: time,
				time_iso: strftime('%F %T', time),
				name: name,
				lower_name: lower_name,
				link: ''
			})
		endif
	endfor
	return info
enddef

def IsBinary(path: string): bool
	for b in readfile(path, 'b', 3)
		if stridx(b, "\<NL>") != -1
			return true
		endif
	endfor
	return false
enddef

def UpdatePreview(s: dict<any>): void
	if empty(s.matches)
		s.preview_path = ''
		popup_settext(s.preview_winid, '<No selection>')
		setbufvar(s.preview_buf, '&filetype', '')
		setbufvar(s.preview_buf, '&modified', false)
		popup_image#Clear(s.preview_winid)
		return
	endif

	var p: string = s.matches[s.selected_idx]
	var type: string = GetFileType(p)
	if s.preview_path ==# p
		return
	endif
	popup_image#Clear(s.preview_winid)
	setbufvar(s.preview_buf, '&filetype', '')
	# deletebufline(s.preview_winid, [])
	s.preview_path = p
	if isdirectory(p)
		var files: list<dict<any>> = GetFileInfo(p)
		var max_len: number = max(files->mapnew((_, v) => len(v.size_s)))
		popup_settext(s.preview_winid, sort(files, (v0, v1) =>
		                                         v0.time > v1.time ? -1 : v0.time < v1.time ? 1 : # 更新日時降順
		                                         v0.lower_name < v1.lower_name ? -1 : v0.lower_name > v1.lower_name ? 1 : # ファイル名順 (大小文字区別なし)
		                                         v0.name < v1.name ? -1 : 1 ) # 大文字先
		                              ->mapnew((_, v) =>
		                                        printf($'%s %{max_len}s %s %s%s',
		                                        	v.permission, v.size_s, v.time_iso, v.name, v.type ==# 'link' ? $' -> {v.link}' : ''))
		)
	elseif filereadable(p)
		if index(g:fuzzy_file_finder.image, tolower(fnamemodify(p, ':e'))) != -1
			popup_image#Preview(s.preview_winid, p)
		elseif index(keys(g:fuzzy_file_finder.filter), type) != -1
			var filter: list<string> = g:fuzzy_file_finder.filter[type]
			var filter_place_folder: number = index(filter, '<>')
			filter = filter_place_folder == -1 ? filter + [p] :
				filter_place_folder == len(filter) ? filter[ : -2 ] + [p] :
				filter[ : filter_place_folder - 1 ] + [p] + filter[ filter_place_folder + 1 : ]
			popup_settext(s.preview_winid, systemlist(filter))
		elseif IsBinary(p)
			popup_settext(s.preview_winid, ' <Binary file> ')
		else
			popup_settext(s.preview_winid, readfile(p))
			setbufvar(s.preview_buf, '&filetype', type)
		endif
	else
		popup_settext(s.preview_winid, ' <Unreadable file>')
	endif
	setbufvar(s.preview_buf, '&modified', false)
enddef

def SchedulePreview(s: dict<any>, delay: number = 50): void
	if s.timer_id != 0
		timer_stop(s.timer_id)
		s.timer_id = 0
	endif

	s.timer_id = timer_start(delay, (_) => {
		s.timer_id = 0
		UpdatePreview(s)
	})
enddef

def SetListTitle(s: dict<any>): void
	var marked_count: number = len(s.marked_files)
	var status: string = (has_key(s, 'job') && job_status(s.job) == 'run') ? $' [Loading... {len(s.all_files)}]' : ''
	popup_setoptions(s.list_winid, {title: $' [{s.target}] {len(s.matches)}/{len(s.all_files)}{status}{marked_count > 0 ? $' ({marked_count} selected)' : ''}'})
enddef

def Render(s: dict<any>): void
	var prompt: string = getbufline(s.filter_buf, 1)->join()
	var preview_idx: number
	var display_matches: list<string>

	if prompt ==# ''
		s.matches = copy(s.all_files)
	else
		s.matches = matchfuzzy(s.all_files, prompt)
	endif
	preview_idx = index(s.matches, s.preview_path)
	if preview_idx == -1
		preview_idx = 0
	else
	endif
	s.selected_idx = preview_idx
	display_matches = mapnew(s.matches, (i, v) => $'{(i == preview_idx) ? '>' : ' '} {has_key(s.marked_files, v) ? '[*]' : '[ ]'} {v}')
	SetListTitle(s)
	popup_settext(s.list_winid, display_matches)
	setbufvar(s.list_buf, '&modified', false)
	SchedulePreview(s, 100)
	win_execute(s.list_winid, $'call cursor({preview_idx + 1}, 1)')
	s.is_dirty = false
enddef

def RequestRender(s: dict<any>): void
	s.is_dirty = true
	if s.render_timer != 0
		timer_stop(s.render_timer)
	endif
	s.render_timer = timer_start(150, (_) => {
		s.render_timer = 0
		if s.is_dirty
			if line('$') > 1
				setline(1, getline(1, '$'))
				execute ':2,$delete'
			endif
			Render(s)
		endif
	})
enddef

def RequestRenderThrottle(s: dict<any>): void
	s.is_dirty = true
	if s.render_timer == 0
		s.render_timer = timer_start(100, (_) => {
			s.render_timer = 0
			if s.is_dirty
				Render(s)
			endif
		})
	endif
enddef

def MoveSelection(s: dict<any>, delta: any): void
	var max_idx = len(s.matches)
	var new_idx: number
	var f: string
	var h: number = popup_getoptions(s.list_winid).maxheight

	if type(delta) == 1
		if delta ==# 'PageUp'
			new_idx = s.selected_idx - (h - 1)
		elseif delta ==# 'PageDown'
			new_idx = s.selected_idx + (h - 1)
		elseif delta ==# '$'
			new_idx = max_idx - 1
		endif
	else
		new_idx = delta == 0 ? 0 : s.selected_idx + delta
	endif
	new_idx = max([0, min([new_idx, max_idx - 1])])
	if new_idx >= 0 && new_idx < max_idx
		f = s.matches[s.selected_idx]
		setbufline(s.list_buf, s.selected_idx + 1, $'  {has_key(s.marked_files, f) ? '[*]' : '[ ]'} {f}')
		f = s.matches[new_idx]
		setbufline(s.list_buf, new_idx + 1, $'> {has_key(s.marked_files, f) ? '[*]' : '[ ]'} {f}')
		win_execute(s.list_winid, $'call cursor({new_idx + 1}, 1)')
		s.selected_idx = new_idx
		SchedulePreview(s)
	endif
enddef

def ToggleMark(s: dict<any>): void
	if !empty(s.matches) && s.selected_idx < len(s.matches)
		var cur_file: string = s.matches[s.selected_idx]
		if has_key(s.marked_files, cur_file)
			remove(s.marked_files, cur_file)
		else
			s.marked_files[cur_file] = true
		endif
		SetListTitle(s)
		MoveSelection(s, 1)
	endif
enddef

def Confirm(s: dict<any>): void
	var files_to_open: list<string> = []
	var open: string = g:fuzzy_file_finder.open
	var open_b: string
	var img: list<string> = g:fuzzy_file_finder.image
	var netrw: bool = g:fuzzy_file_finder.dir

	if has('unix')
		open_b = 'xdg-open'
	elseif has('win32') || has('win32unix')
		open_b = 'start'
	elseif has('mac')
		open_b = 'open'
	endif
	if !empty(s.marked_files)
		files_to_open = keys(s.marked_files)
	elseif !empty(s.matches) && s.selected_idx < len(s.matches)
		add(files_to_open, s.matches[s.selected_idx])
	endif
	map(files_to_open, (_, v) => fnamemodify(v, ':p'))
	Cleanup(s) # これでカレント・ディレクトリが変わることがあるので、この後でフル・パス変換はダメ
	if !empty(files_to_open)
		for f in files_to_open
			if isdirectory(f) && netrw
				execute $'{open} {fnameescape(f)}'
			elseif index(img, tolower(fnamemodify(f, ':e'))) != -1 || isdirectory(f) || IsBinary(f)
				if open_b ==# ''
					echohl ErrorMsg
					echo $'Binary file: {f}'
					echohl None
				endif
					echohl ErrorMsg
					echo systemlist([open_b, f])->join('\n')
					echohl None
			else
				execute $'{open} {fnameescape(f)}'
			endif
		endfor
	endif
enddef

export def Bridge(cmd: string): void
	if cmd ==# 'Confirm'
		Confirm(b:fuzzy_state)
	elseif cmd ==# 'MoveUp'
		MoveSelection(b:fuzzy_state, -1)
	elseif cmd ==# 'MoveDown'
		MoveSelection(b:fuzzy_state, 1)
	elseif cmd ==# 'MoveTop'
		MoveSelection(b:fuzzy_state, 0)
	elseif cmd ==# 'MoveLast'
		MoveSelection(b:fuzzy_state, '$')
	elseif cmd ==# 'MovePageDown'
		MoveSelection(b:fuzzy_state, 'PageDown')
	elseif cmd ==# 'MovePageUp'
		MoveSelection(b:fuzzy_state, 'PageUp')
	elseif cmd ==# 'ToggleMark'
		ToggleMark(b:fuzzy_state)
	elseif cmd ==# 'Cleanup'
		Cleanup(b:fuzzy_state)
	elseif cmd ==# 'Render'
		RequestRender(b:fuzzy_state)
	elseif cmd ==# 'VimResized'
		ChangePopupSize(false)
	elseif cmd ==# 'CmdwinLeave'
		if CheckFuzzyFileFinderWin()
			ChangePopupSize(false)
		endif
	elseif cmd ==# 'CmdwinEnter'
		if CheckFuzzyFileFinderWin()
			ChangePopupSize(true)
		endif
	elseif cmd ==# 'TogglePreview'
		TogglePreview(b:fuzzy_state)
	else
		echohl ErrorMsg
		echo 'No command!'
		echohl None
	endif
enddef

def CheckFuzzyFileFinderWin(): bool
	var tabnr: number = tabpagenr()

	for b in tabpagebuflist()
		if has_key(getbufinfo(b)[0].variables, 'fuzzy_state')
			return true
		endif
	endfor
	return false
enddef

export def Open(dir: string = ''): void
	var target_dir: string = fnamemodify(dir ==# '' ? getcwd() : expand(dir, true), ':p')
	var target_len: number = len(target_dir)
	var main_width: number = &columns * 45 / 100
	var preview_width: number = &columns - main_width - 3
	var line_height: number = &lines - 2 - (&laststatus != 0 ? 1 : 0) - &cmdheight
	var cmd_place_folder: number = index(g:fuzzy_file_finder.cmd, '<>')
	var cmd: list<string> = cmd_place_folder == -1 ? g:fuzzy_file_finder.cmd + [target_dir] :
		cmd_place_folder == len(g:fuzzy_file_finder.cmd) ? g:fuzzy_file_finder.cmd[ : - 2 ] + [target_dir] :
		g:fuzzy_file_finder.cmd[ : cmd_place_folder - 1 ] + [target_dir] + g:fuzzy_file_finder.cmd[ cmd_place_folder + 1 : ]

	if !isdirectory(target_dir)
		echohl ErrorMsg
		echo $'Not a directory: {target_dir}'
		echohl None
		return
	endif
	tabnew
	execute $'lcd {target_dir}'
	var s = {
		tabnr: tabpagenr(),
		filter_buf: bufnr('%'),
		list_buf: bufadd(''),
		preview_buf: bufadd(''),
		preview_path: '',
		all_files: [],
		matches: [],
		selected_idx: 0,
		marked_files: {},
		target: stridx(target_dir, $'{$HOME}/') == 0 ? '~/' .. target_dir[len($'{$HOME}/') :] : target_dir,
		list_winid: 0,
		preview_winid: 0,
		preview_on: true,
		render_timer: 0,
		timer_id: 0,
		is_dirty: false,
		job: null_job
	}
	setbufvar(s.filter_buf, '&filetype', 'fuzzy-file-finder')
	bufload(s.list_buf)
	setbufvar(s.list_buf, '&buftype', 'nofile')
	setbufvar(s.list_buf, '&bufhidden', 'wipe')
	# setbufvar(s.list_buf, '&breakindent', 1)
	# setbufvar(s.list_buf, '&breakindentopt', 'list:-1')
	# setbufvar(s.list_buf, '&formatlistpat', '^[[] >*]\+')
	bufload(s.preview_buf)
	setbufvar(s.preview_buf, '&buftype', 'nofile')
	setbufvar(s.preview_buf, '&bufhidden', 'wipe')
	s.list_winid = popup_create(s.list_buf, {
		title: $' [{s.target}] 0/0',
		line: 2,
		col: 1,
		minwidth: main_width,
		maxwidth: main_width,
		minheight: line_height,
		maxheight: line_height,
		border: [1, 1, 0, 0],
		borderchars: ['-', '|', '-', '|', '+', '+', '+', '+'],
		padding: [0, 0, 0, 0],
		cursorline: true
	})
	s.preview_winid = popup_create(s.preview_buf, {
		title: ' Preview ',
		wrap: false,
		line: 2,
		col: main_width + 3,
		minwidth: preview_width,
		maxwidth: preview_width,
		minheight: line_height,
		maxheight: line_height,
		border: [1, 0, 0, 0],
		borderchars: ['-', '|', '-', '|', '+', '+', '+', '+'],
		padding: [0, 0, 0, 0],
	})
	execute $'colorscheme {g:colors_name}' # これがないと画像表示状態で ChangePopupSize() が起きると、テキスト背景が標準色 (黒/白) になる (filetype を変えるため)
	s.canceled = false
	s.job = job_start(cmd, {
		out_cb: (ch, msg) => {
			if s.canceled # canceled フラグを立てたら、出力を読み飛ばすようにする
				return
			endif
			add(s.all_files, stridx(msg, target_dir) == 0 ? msg[target_len :] : msg)
			var count_out_cb: number = len(s.all_files)
			if count_out_cb <= &lines || count_out_cb % 1000 == 0
				RequestRenderThrottle(s)
			endif
		},
		close_cb: (ch) => {
			RequestRender(s)
		}
	})
	b:fuzzy_state = s
	Render(s)
	startinsert
enddef

def ChangePopupSize(cmdwin: bool): void
	var main_width: number
	var preview_width: number
	var line_height: number
	var winid: number
	var opts: dict<any>

	if cmdwin
			|| gettabinfo()[0].windows->map((_, v) => win_gettype(v))->index('command') != -1 # コマンド・ライン・ウィンドウがある
		line_height = &lines - 2 - (&laststatus != 0 ? 1 : 0) - &cmdheight - (&cmdwinheight + (&laststatus != 0 ? 1 : 0))
	else
		line_height = &lines - 2 - (&laststatus != 0 ? 1 : 0) - &cmdheight
	endif
	for v in getbufinfo()
			->filter((_, v) => has_key(v.variables, 'fuzzy_state'))
			->map((_, v) => v.variables.fuzzy_state)
		if v.preview_on # プレビューが表示されている
			main_width = &columns * 45 / 100
			preview_width = &columns - main_width - 3
			winid = v.preview_winid
			if winbufnr(winid) != -1
				opts = popup_getoptions(winid)
				if opts.maxwidth != preview_width || opts.maxheight != line_height
					popup_setoptions(winid, extendnew(opts, {
						col: main_width + 3,
						minwidth: preview_width,
						maxwidth: preview_width,
						minheight: line_height,
						maxheight: line_height
					}))
					if get(opts, 'image', {}) != {}
						popup_image#ResetPreview(winid, v.matches[v.selected_idx])
					endif
				endif
			endif
		else
			main_width = &columns
		endif
		winid = v.list_winid
		if winbufnr(winid) != -1
			opts = popup_getoptions(winid)
			if opts.maxwidth != main_width || opts.maxheight != line_height
				popup_setoptions(winid, extendnew(opts, {
					minwidth: main_width,
					maxwidth: main_width,
					minheight: line_height,
					maxheight: line_height
				}))
			endif
		endif
	endfor
enddef

def TogglePreview(s: dict<any>): void
	var winid: number = s.preview_winid
	var opts: dict<any>

	if winid == -1
		return
	endif
	if s.preview_on
		popup_hide(winid)
		s.preview_on = false
	else
		popup_show(winid)
		s.preview_on = true
	endif
	ChangePopupSize(false)
enddef
