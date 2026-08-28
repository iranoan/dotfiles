vim9script
scriptencoding utf-8

var istalled_popup_preview: bool = getscriptinfo({name: '/plugin/popup_preview.vim'}) != []

def Cleanup(s: dict<any>, cancel: bool): void
	var ch: channel
	if s.render_timer != 0
		timer_stop(s.render_timer)
		s.render_timer = 0
	endif
	if has_key(s, 'job')
		for j in s.job
			if job_status(j) == 'run'
				s.canceled = true
				ch = job_getchannel(j)
				if ch_status(ch) != 'closed'
					ch_close_in(ch)
				endif
				job_stop(j, 'kill')
				remove(s.job, index(s.job, j))
			endif
		endfor
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
		execute $'silent! bwipeout! {s.preview_buf}'
	endif
	if cancel
		win_gotoid(s.current_winid)
	endif
	stopinsert
enddef

def UpdatePreview(s: dict<any>): void
	var id: number = s.preview_winid
	if empty(s.matches)
		s.preview_path = ''
		popup_settext(s.preview_winid, '<No selection>')
		popup_setoptions(id, {highlight: 'WarningMsg', highlights: 'PopupTitle:Pmenu,Popup:WarningMsg'})
		if s.display_image
			popup_image#Clear(s.preview_winid)
		endif
		return
	endif

	popup_preview#Preview(s.preview_winid, s.matches[s.selected_idx])
enddef

def SchedulePreview(s: dict<any>, delay: number = 50): void
	if !istalled_popup_preview
		return
	endif
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
	var status: string

	if has_key(s, 'job')
		for j in s.job
			if job_status(j) == 'run'
				status = $' [Loading... {len(s.all_files)}]'
				break
			endif
		endfor
	endif
	popup_setoptions(s.list_winid, {title: $' [{s.target}] {len(s.matches)}/{len(s.all_files)}{status}{marked_count > 0 ? $' ({marked_count} selected)' : ''} '})
enddef

def RegErrMsg(e: list<dict<any>>): void
	if e == []
		return
	endif
	var max_len: number = mapnew(e, (_, v) => strdisplaywidth(v.expression))->max() + 1

	popup_create(mapnew(e, (_, v) => printf($'%-{max_len}S%s', v.expression, v.error)), {
		title: ' Filter Regular RExpression Error ',
		line: 'cursor+1',
		col: 1,
		minwidth: 35,
		tabpage: -1,
		zindex: 300,
		highlight: 'WarningMsg',
		border: [1, 1, 1, 1,],
		borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
		padding: [0, 1, 0, 1],
		filter: (id, key) => {
			if key !~? '^<.*mouse' && key !~? '^<.*scroll' # マウス操作でない
				popup_close(id)
			endif
			return false
		}
	})
enddef

def Render(s: dict<any>): void
	var prompt: list<string> = getbufline(s.filter_buf, 1)->join()->split()
	var special_s: list<string>
	var special_c: string
	var match_idx: number
	var preview_idx: number
	var display_matches: list<string>
	var matches: list<string>
	var reg_err: list<dict<string>>

	sort(s.all_files)->uniq()
	matches = copy(s.all_files)
	while true # ! ←これだけ否定マッチ
		match_idx = match(prompt, '^!')
		if match_idx == -1
			break
		endif
		special_c = remove(prompt, match_idx)[1 : ]
		if special_c =~# '^\\.'
			add(special_s, special_c[ 1 : ])
		elseif special_c =~# '\$$'
			add(special_s, $'{escape(special_c[ : -2 ], '\.*$[]~')}$')
		elseif special_c =~# '^\^.'
			special_c = escape(special_c, '\.*$[]~')
			add(special_s, $'/{escape(special_c[ 1 : ], '\.*$[]~')}')
		add(special_s, $'\({special_c}\|/{special_c[ 1 : ]}\)')
		else
			add(special_s, escape(special_c, '\.*$[]~'))
		endif
	endwhile
	for str in special_s
		try
			match('', str)
		catch /^Vim\%((\a\+)\)\=:E/
			add(reg_err, {expression: str, error: v:exception[4 : ]})
			continue
		endtry
		filter(matches, (_, v) => v !~? str)
	endfor
	special_s = []
	while true # ^
		match_idx = match(prompt, '^\^.')
		if match_idx == -1
			break
		endif
		special_c = remove(prompt, match_idx)->escape('\.*$[]~')
		add(special_s, $'\({special_c}\|/{special_c[ 1 : ]}\)')
	endwhile
	while true # '
		match_idx = match(prompt, '^''')
		if match_idx == -1
			break
		endif
		special_c = remove(prompt, match_idx)
		if special_c =~# '''$'
			add(special_s, $'\<{special_c[1 : -2]->escape('^\.*$[]~')}\>')
		else
			add(special_s, special_c[1 : ]->escape('^\.*$[]~'))
		endif
	endwhile
	while true # \
		match_idx = match(prompt, '^\\.')
		if match_idx == -1
			break
		endif
		add(special_s, remove(prompt, match_idx)[1 : ])
	endwhile
	while true # $
		match_idx = match(prompt, '.\$$')
		if match_idx == -1
			break
		endif
		add(special_s, remove(prompt, match_idx)->escape('^\.*[]~'))
	endwhile
	for str in special_s
		try
			match('', str)
		catch /^Vim\%((\a\+)\)\=:E/
			add(reg_err, {expression: str, error: v:exception[4 : ]})
			continue
		endtry
		filter(matches, (_, v) => v =~? str)
	endfor
	if prompt == []
		s.matches = copy(matches)
	else
		s.matches = matchfuzzy(matches, join(prompt))
	endif
	RegErrMsg(reg_err)
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
				setline(1, getline(1, '$')->join())
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
	var max_idx: number = len(s.matches)
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
	Cleanup(s, false) # これでカレント・ディレクトリが変わることがあるので、この後でフル・パス変換はダメ
	if !empty(files_to_open)
		for f in files_to_open
			if isdirectory(f) && netrw
				execute $'{open} {fnameescape(f)}'
			elseif index(img, tolower(fnamemodify(f, ':e'))) != -1 || isdirectory(f) || general_function#IsBinary(f)
				if open_b ==# ''
					echohl ErrorMsg
					echo $'Binary file: {f}'
					echohl None
				endif
				job_start([open_b, f])
			else
				execute $'{open} {f}'
			endif
		endfor
	endif
enddef

export def Bridge(cmd: string): void
	if cmd ==# 'Confirm'
		Confirm(b:fuzzy_state)
	elseif cmd ==? 'MoveUp'
		MoveSelection(b:fuzzy_state, -1)
	elseif cmd ==? 'MoveDown'
		MoveSelection(b:fuzzy_state, 1)
	elseif cmd ==? 'MoveTop'
		MoveSelection(b:fuzzy_state, 0)
	elseif cmd ==? 'MoveLast'
		MoveSelection(b:fuzzy_state, '$')
	elseif cmd ==? 'MovePageDown'
		MoveSelection(b:fuzzy_state, 'PageDown')
	elseif cmd ==? 'MovePageUp'
		MoveSelection(b:fuzzy_state, 'PageUp')
	elseif cmd ==? 'ToggleMark'
		ToggleMark(b:fuzzy_state)
	elseif cmd ==? 'Cleanup'
		Cleanup(b:fuzzy_state, true)
	elseif cmd ==? 'Render'
		RequestRender(b:fuzzy_state)
	elseif cmd ==? 'VimResized'
		ChangePopupSize(true)
	elseif cmd ==? 'CmdwinLeave'
		if CheckFuzzyFileFinderWin()
			ChangePopupSize(false)
		endif
	elseif cmd ==? 'CmdwinEnter'
		if CheckFuzzyFileFinderWin()
			ChangePopupSize(true)
		endif
	elseif cmd ==? 'TogglePreview'
		TogglePreview(b:fuzzy_state)
	elseif cmd ==? 'ToggleListWrap'
		ToggleWrap(b:fuzzy_state.list_winid, false)
	elseif cmd ==? 'TogglePreviewWrap'
		ToggleWrap(b:fuzzy_state.preview_winid, true)
	elseif cmd ==? 'PreviewPageDown'
		PreviewPageUpDown(b:fuzzy_state.preview_winid, true)
	elseif cmd ==? 'PreviewPageUp'
		PreviewPageUpDown(b:fuzzy_state.preview_winid, false)
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

def WarningMsg(s: list<string>): void
	popup_create(s, {
		title: ' Fuzzy File Finder Warning ',
		line: 'cursor+1',
		col: 'cursor',
		minwidth: 20,
		time: 5000,
		tabpage: -1,
		zindex: 300,
		drag: 1,
		highlight: 'WarningMsg',
		border: [1, 1, 1, 1,],
		borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
		close: 'click',
		padding: [0, 1, 0, 1],
		filter: (id, _) => {
			popup_close(id)
			return
		}
	})
enddef

def GetWindowSize(prev_on: bool, cmdwin: bool): list<number>
	var list_width: number
	var preview_width: number
	var line_height: number
	var ls_border: list<number> = g:fuzzy_file_finder.list_border
	var pv_border: list<number>
	var ls_border_c: list<string>
	var pv_border_c: list<string>
	var slide: number

	sleep 1m # gvim --clientserver socket で起動している時に、これが無いとサイズ変更がうまく行かない
	ls_border = ls_border == [] ? [1, 1, 1, 1] : ls_border
	if cmdwin
			&& gettabinfo(tabpagenr())[0].windows->map((_, v) => win_gettype(v))->index('command') != -1 # コマンド・ライン・ウィンドウがある
		line_height = &lines - ls_border[2] - (&laststatus != 0 ? 1 : 0) - &cmdheight - (&cmdwinheight + (&laststatus != 0 ? 1 : 0)) - 2 # タイトルとフィルター入力の為 1 行ずらしている合わせて 2 行分は必ず減る
	else
		line_height = &lines - ls_border[2] - (&laststatus != 0 ? 1 : 0) - &cmdheight - 2
	endif
	if prev_on
		pv_border = g:fuzzy_file_finder.list_border
		pv_border_c = g:fuzzy_file_finder.preview_borderchars
		ls_border_c = g:fuzzy_file_finder.list_borderchars
		list_width = &columns * 45 / 100
	else
		pv_border = [0, 0, 0, 0]
		pv_border_c = ['', '', '', '']
		ls_border_c = g:fuzzy_file_finder.list_borderchars
		list_width = &columns - ls_border[1] * strdisplaywidth(ls_border_c[1]) - ls_border[3] * strdisplaywidth(ls_border_c[3]) - 2 + ls_border[1] * ls_border[3] # スクロール・バーの分
	endif
	preview_width = &columns - list_width - 5 # スクロール・バーとパディングの分 (プレビュー枠がズレたり (ambiwidth=single)、右端に〉が表示される (ambiwidth=double) する分の微調整)
		- (
			  ls_border[1] * strdisplaywidth(ls_border_c[1])
			+ pv_border[1] * strdisplaywidth(pv_border_c[1])
			+ pv_border[3] * strdisplaywidth(pv_border_c[3])
			+ (pv_border[3] * strdisplaywidth(pv_border_c[3]) == 1 ? 1 : 0)
		)
	slide = list_width + 3 + ls_border[3]
	return [list_width, preview_width, line_height, slide]
enddef

def ListBorder(v: list<number>): list<number> # 右側のプレビュー枠左側に罫線があれば、左側のリスト枠右側は強制的に無しにする (重ねたように見せつつ余分な領域をなくす)
	return istalled_popup_preview && g:popup_preview.border[3] == 1 ? [v[0], 0] + v[2 : ] : v
enddef

def SetFilterBuffer(dir: string): void
	setlocal filetype=fuzzy-file-finder nonumber signcolumn=no foldcolumn=0 buftype=nofile bufhidden=wipe
	autocmd FuzzyFileFinder TextChangedI,TextChangedP,TextChanged <buffer> fff#Bridge('Render')
	# execute($'file! fuzzy-file-finder:://{dir}')
	if get(g:fuzzy_file_finder, 'mapping', true)
		# Normal モード
		nnoremap <buffer><silent><Esc>      <Cmd>call fff#Bridge('Cleanup')<CR>
		nnoremap <buffer><silent>gg         <Cmd>call fff#Bridge('MoveTop')<CR>
		nnoremap <buffer><silent>G          <Cmd>call fff#Bridge('MoveLast')<CR>
		nnoremap <buffer><silent>O          I
		nnoremap <buffer><silent>o          A
		# Insert / Normal モード双方からの操作
		nnoremap <buffer><silent><CR>       <Cmd>call fff#Bridge('Confirm')<CR>
		inoremap <buffer><silent><CR>       <Cmd>call fff#Bridge('Confirm')<CR>
		nnoremap <buffer><silent><C-j>      <Cmd>call fff#Bridge('MoveDown')<CR>
		inoremap <buffer><silent><C-j>      <Cmd>call fff#Bridge('MoveDown')<CR>
		nnoremap <buffer><silent><C-n>      <Cmd>call fff#Bridge('MoveDown')<CR>
		inoremap <buffer><silent><C-n>      <Cmd>call fff#Bridge('MoveDown')<CR>
		nnoremap <buffer><silent><Down>     <Cmd>call fff#Bridge('MoveDown')<CR>
		inoremap <buffer><silent><Down>     <Cmd>call fff#Bridge('MoveDown')<CR>
		nnoremap <buffer><silent>j          <Cmd>call fff#Bridge('MoveDown')<CR>
		nnoremap <buffer><silent><C-k>      <Cmd>call fff#Bridge('MoveUp')<CR>
		inoremap <buffer><silent><C-k>      <Cmd>call fff#Bridge('MoveUp')<CR>
		nnoremap <buffer><silent><C-p>      <Cmd>call fff#Bridge('MoveUp')<CR>
		inoremap <buffer><silent><C-p>      <Cmd>call fff#Bridge('MoveUp')<CR>
		nnoremap <buffer><silent><Up>       <Cmd>call fff#Bridge('MoveUp')<CR>
		inoremap <buffer><silent><Up>       <Cmd>call fff#Bridge('MoveUp')<CR>
		nnoremap <buffer><silent>k          <Cmd>call fff#Bridge('MoveUp')<CR>
		nnoremap <buffer><silent><Tab>      <Cmd>call fff#Bridge('ToggleMark')<CR>
		inoremap <buffer><silent><Tab>      <Cmd>call fff#Bridge('ToggleMark')<CR>
		nnoremap <buffer><silent><PageDown> <Cmd>call fff#Bridge('MovePageDown')<CR>
		inoremap <buffer><silent><PageDown> <Cmd>call fff#Bridge('MovePageDown')<CR>
		nnoremap <buffer><silent><C-f>      <Cmd>call fff#Bridge('MovePageDown')<CR>
		inoremap <buffer><silent><C-f>      <Cmd>call fff#Bridge('MovePageDown')<CR>
		nnoremap <buffer><silent><PageUp>   <Cmd>call fff#Bridge('MovePageUp')<CR>
		inoremap <buffer><silent><PageUp>   <Cmd>call fff#Bridge('MovePageUp')<CR>
		nnoremap <buffer><silent><C-b>      <Cmd>call fff#Bridge('MovePageUp')<CR>
		inoremap <buffer><silent><C-b>      <Cmd>call fff#Bridge('MovePageUp')<CR>
		nnoremap <buffer><silent><C-]>      <Cmd>call fff#Bridge('TogglePreview')<CR>
		inoremap <buffer><silent><C-]>      <Cmd>call fff#Bridge('TogglePreview')<CR>
	endif
enddef

def GetCommonPath(dirs: list<string>): string
	if empty(dirs)
		return ''
	elseif len(dirs) == 1
		if dirs[0] =~# '/$'
			return dirs[0]
		endif
		return $'{dirs[0]}/'
	endif

	var common_parts: list<string> = split(dirs[0], '/', true)
	var parts: list<string>
	var min_len: number
	var new_common: list<string>

	for p in dirs[1 :]
		parts = split(p, '/', true)
		min_len = min([len(common_parts), len(parts)])
		new_common = []
		for i in range(min_len)
			if common_parts[i] == parts[i]
				add(new_common, common_parts[i])
			else
				break
			endif
		endfor
		common_parts = new_common
	endfor
	if common_parts[-1] ==# ''
		return $'{join(common_parts, '/')}'
	endif
	return $'{join(common_parts, '/')}/'
enddef

def MakeCmd(dirs: list<string>, target: list<list<string>>, not_dirs: list<string>, files: list<string>): string
	var cmd_len: number = len(g:fuzzy_file_finder.cmd)
	var cmd_s: list<string> = g:fuzzy_file_finder.cmd
	var dirs_uniq: list<string> =
		dirs == []
			? [$'{resolve(getcwd())}']
		: mapnew(dirs, (_, v) => v ==# ''
			? $'{resolve(getcwd())}'
			: $'{resolve(fnamemodify(expand(v, true), ':p'))}')
	var ftype: string
	var cmd_place_folder: number = index(g:fuzzy_file_finder.cmd, '.')
	var dirs2: list<string>

	if cmd_place_folder == -1
		for d in dirs_uniq
			ftype = getftype(d)
			if ftype ==# 'file'
				add(files, d)
				continue
			elseif ftype !=# 'dir'
				add(not_dirs, $'{d}')
				continue
			endif
			add(dirs2, d)
			add(target, cmd_s + [d])
		endfor
	elseif cmd_place_folder == cmd_len
		for d in dirs_uniq
			ftype = getftype(d)
			if ftype ==# 'file'
				add(files, d)
				continue
			elseif ftype !=# 'dir'
				add(not_dirs, $'{d}')
				continue
			endif
			add(dirs2, d)
			add(target, cmd_s[ : - 2 ] + [d])
		endfor
	else
		for d in dirs_uniq
			ftype = getftype(d)
			if ftype ==# 'file'
				add(files, d)
				continue
			elseif ftype !=# 'dir'
				add(not_dirs, $'{d}')
				continue
			endif
			add(dirs2, d)
			add(target, cmd_s[ : cmd_place_folder - 1 ] + [d] + cmd_s[ cmd_place_folder + 1 : ])
		endfor
	endif
	return GetCommonPath(dirs2)
enddef

def SetBufVar(n: number): void
	setbufvar(n, '&bufhidden', 'wipe')
	setbufvar(n, '&buflisted', false)
	setbufvar(n, '&buftype', 'nofile')
	setbufvar(n, '&swapfile', false)
	setbufvar(n, '&undofile', false)
	setbufvar(n, '&number', false)
enddef

export def FFFiles(dirs: list<string> = []): void
	var cmds: list<list<string>>
	var files: list<string>
	var not_dirs: list<string>
	var common_path: string = MakeCmd(dirs, cmds, not_dirs, files)
	var common_len: number = len(common_path)
	var list_width: number
	var preview_width: number
	var line_height: number
	var slide: number
	var current_winid: number = win_getid()
	var i: number

	if not_dirs != []
		WarningMsg(['Not a directory'] + not_dirs)
	elseif cmds == [] && files == []
		return
	elseif !executable(g:fuzzy_file_finder.cmd[0])
		WarningMsg([$'Not execute: {g:fuzzy_file_finder.cmd[0]}'])
		return
	endif
	tabnew
	execute($'silent lcd {common_path}')
	[list_width, preview_width, line_height, slide] = GetWindowSize(istalled_popup_preview, true)
	var s = {
		current_winid: current_winid,
		display_image: getscriptinfo({name: '/plugin/popup_image.vim'}) != [],
		tabnr: tabpagenr(),
		filter_buf: bufnr('%'),
		list_buf: bufadd(''),
		preview_buf: bufadd(''),
		preview_path: '',
		all_files: mapnew(files, (_, v) => stridx(v, common_path) == 0 ? v[common_len :] : v),
		matches: [],
		selected_idx: 0,
		marked_files: {},
		target: stridx(common_path, $'{$HOME}/') == 0 ? '~/' .. common_path[len($'{$HOME}/') : ] : common_path,
		list_winid: 0,
		preview_winid: 0,
		preview_on: istalled_popup_preview,
		render_timer: 0,
		timer_id: 0,
		is_dirty: false,
		job: []
	}
	SetBufVar(s.list_buf)
	# setbufvar(s.list_buf, '&breakindent', 1)
	# setbufvar(s.list_buf, '&breakindentopt', 'list:-1')
	# setbufvar(s.list_buf, '&formatlistpat', '^[[] >*]\+')
	SetBufVar(s.preview_buf)
	SetFilterBuffer(common_path)
	s.list_winid = popup_create(s.list_buf, {
		title: $' [{s.target}] 0/0 ',
		line: 2,
		col: 1,
		minwidth: list_width,
		maxwidth: list_width,
		minheight: line_height,
		maxheight: line_height,
		border: ListBorder(g:fuzzy_file_finder.list_border),
		borderchars: g:fuzzy_file_finder.list_borderchars,
		padding: [0, 0, 0, 1],
		zindex: 50,
		cursorline: true
	})
	if istalled_popup_preview
		s.preview_winid = popup_create(s.preview_buf, {
			title: ' Preview ',
			wrap: false,
			line: 2,
			col: slide,
			minwidth: preview_width,
			maxwidth: preview_width,
			minheight: line_height,
			maxheight: line_height,
			border: g:fuzzy_file_finder.preview_border,
			borderchars: g:fuzzy_file_finder.preview_borderchars,
			borderhighlight: ['Pmenu', 'Pmenu', 'Pmenu', 'Pmenu'],
			zindex: 51,
			padding: [0, 1, 0, 1],
		})
	endif
	execute $'colorscheme {g:colors_name}' # これがないと画像表示状態で ChangePopupSize() が起きると、テキスト背景が標準色 (黒/白) になる (filetype を変えるため)
	s.canceled = false
	s.active_jobs = len(cmds)
	for cmd in cmds
		s.job[i] = job_start(cmd, {
			out_cb: (ch, msg) => {
				if s.canceled # canceled フラグを立てたら、出力を読み飛ばすようにする
					return
				endif
				add(s.all_files, stridx(msg, common_path) == 0 ? msg[common_len :] : msg)
				var count_out_cb: number = len(s.all_files)
				if count_out_cb <= &lines || count_out_cb % 1000 == 0
					RequestRenderThrottle(s)
				endif
			},
			close_cb: (ch) => {
				s.active_jobs -= 1
				if s.active_jobs == 0
					RequestRender(s)
				endif
			}
		})
		i += 1
	endfor
	b:fuzzy_state = s
	Render(s)
	startinsert
enddef

def ChangePopupSize(cmdwin: bool): void # cmdwin 現在の状態でコマンド・ライン・ウィンドウで判定するか?→false なら完全に無し扱い
	var list_width: number
	var preview_width: number
	var line_height: number
	var winid: number
	var opts: dict<any>
	var slide: number
	var border: list<number>

	for v in getbufinfo()
			->filter((_, v) => has_key(v.variables, 'fuzzy_state'))
			->map((_, v) => v.variables.fuzzy_state)
		if v.preview_on # プレビューが表示されている
			[list_width, preview_width, line_height, slide] = GetWindowSize(true, cmdwin)
			winid = v.preview_winid
			if winbufnr(winid) != -1
				opts = popup_getoptions(winid)
				if opts.maxwidth != preview_width || opts.maxheight != line_height
					popup_setoptions(winid, {
						border: g:popup_preview.border,
						col: slide,
						minwidth: preview_width,
						maxwidth: preview_width,
						minheight: line_height,
						maxheight: line_height
					})
					if get(opts, 'image', {}) != {}
						ResetPreview(winid, v.matches[v.selected_idx])
					endif
				endif
			endif
			popup_show(winid)
			border = ListBorder(g:fuzzy_file_finder.list_border)
		else
			border = g:fuzzy_file_finder.list_border
			[list_width, preview_width, line_height, slide] = GetWindowSize(false, cmdwin)
			popup_close(winid)
		endif
		winid = v.list_winid
		if winbufnr(winid) != -1
			opts = popup_getoptions(winid)
			if opts.maxwidth != list_width || opts.maxheight != line_height
				popup_setoptions(winid, {
					border: border,
					borderchars: g:fuzzy_file_finder.list_borderchars,
					minwidth: list_width,
					maxwidth: list_width,
					minheight: line_height,
					maxheight: line_height
				})
			endif
		endif
	endfor
enddef

def TogglePreview(s: dict<any>): void
	if !istalled_popup_preview
		return
	endif
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
	ChangePopupSize(true)
enddef

def ToggleWrap(id: number, preview_flag: bool): void
	if preview_flag && !istalled_popup_preview
		return
	endif
	var wrap: bool = get(popup_getoptions(id), 'wrap', true)
	popup_setoptions(id, {wrap: !wrap})
	echo $'{preview_flag ? 'Preview' : 'File List'}: {wrap ? 'nowrap' : 'wrap'}'
	redraw!
enddef

def PreviewPageUpDown(id: number, down_flag: bool): void
	if !istalled_popup_preview
		return
	endif
	popup_preview#PageUpDown(id, down_flag)
enddef

def ResetPreview(id: number, f: string): void
	var opts: dict<any> = getwinvar(id, 'popup_image', {options: {}})

	opts.options = extendnew(popup_getoptions(id), {image: {}})
	popup_setoptions(id, getwinvar(id, 'popup_image', {options: {}}).options)
	if tabpagenr() == getwininfo(id)[0].tabnr
		popup_image#Preview(id, f)
	else
		execute $'autocmd FuzzyFileFinder TabEnter * ++once if tabpagenr() == {getwininfo(id)[0].tabnr} | call popup_image#Preview({id}, ''{f}'') | endif'
	endif
enddef
