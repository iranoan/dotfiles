scriptencoding utf-8

function set_fern#main() abort
	let g:fern#disable_default_mappings = 1
	let g:fern#disable_drawer_smart_quit = 1 " fern のウィンドウだけに成っても Vim を閉じない
	let g:fern#default_exclude = '^\%\(\(\.git\|node_modules\)\|.\+\(\.o\|\.fls\|\.synctex\.gz\|\.fdb_latexmk\|\.toc\|\.out\|\.dvi\|\.aux\|\.nav\|\.ltjruby\|\.snm\|\.swp\)\)$'
	" *g:fern#comparator*
	" 	A |String| name of comparator used to sort tree items. Allowed value
	" 	is a key of |g:fern#comparators|.
	" 	Default: "default"
	packadd fern.vim
	" Git のステータス表示 https://github.com/lambdalisue/fern-git-status.vim {{{
	" どういう規則性で表示されるのかわからない
	" とりあえず変更の有るフォルダで a -> open:right などでは表示される
	packadd fern-git-status.vim
	call fern_git_status#init()
	" }}}
	" プレビュー  https://github.com/yuki-yano/fern-preview.vim {{{
	packadd fern-preview.vim
	let g:fern_preview_window_calculator = #{height: {-> &lines - 2}, left: {-> g:fern#drawer_width + 1}, top: {-> 0}, width: {-> &columns - g:fern#drawer_width - 2}}
	" }}}
	" fzf と連携 https://github.com/LumaKernel/fern-mapping-fzf.vim {{{
	packadd fern-mapping-fzf.vim
	let g:fern#mapping#fzf#disable_default_mappings = 1
	" g:fern#mapping#fzf#fzf_options を指定すると、b:fzf_action, g:fzf_action が無視され開けなくなる
	" let g:fern#mapping#fzf#fzf_options = {'options': '--multi --no-unicode --margin=0% --padding=0% --preview=''~/bin/fzf-preview.sh {}'' --bind=''ctrl-]:change-preview-window(hidden|)'''}
	" }}}
	" アイコン表示 {{{
	" https://github.com/lambdalisue/glyph-palette.vim {{{
	packadd glyph-palette.vim " }}}
	" https://github.com/lambdalisue/nerdfont.vim {{{
	packadd nerdfont.vim
	let g:nerdfont#autofix_cellwidths = 0 " call setcellwidths([[0x03B1, 0x03C9, 1]]) の警告を無くす
	" }}}
	" https://github.com/lambdalisue/fern-renderer-nerdfont.vim {{{
	packadd fern-renderer-nerdfont.vim
	let g:fern#renderer = "nerdfont"
	augroup fern-custom
		autocmd!
		autocmd FileType nerdtree,startify call glyph_palette#apply()
		autocmd FileType fern call s:init_fern()
		autocmd FileType fern ++once if !pack_manage#IsInstalled('fzf.vim')
					\ | 	call set_fzf#vim('')
					\ | 	delfunction set_fzf#vim
					\ | endif
	augroup END
	" }}}
	" }}}
endfunction

def set_fern#FernSync(dir: string = '%:p'): void
	def Sync(b: list<number>, name: string, fern: number): void
		var fern_win: list<number> = getbufinfo(fern)[0].windows
		for w in gettabinfo(tabpagenr())[0].windows
			if index(fern_win, w) != -1
				# win_gotoid(w)
				# execute('FernReveal ' .. substitute(name, expand('$HOME/'), '', ''))
				win_execute(w, 'FernReveal ' .. name)
				break
			endif
		endfor
		return
	enddef

	if &filetype ==# 'fern'
		return
	endif
	var edit: list<number> = getbufinfo(bufnr())[0].windows # 編集中のバッファ
	var edit_name: string = expand('%:p')
	var bufnr: number
	for b in getbufinfo()
		bufnr = b.bufnr
		if has_key(b.variables, 'fern')
			for w in tabpagebuflist()
				if w == bufnr
					Sync(edit, edit_name, bufnr)
					return
				endif
			endfor
			execute 'topleft vsplit | buffer ' .. bufnr
			Sync(edit, edit_name, bufnr) # 同期が効いていない
			return
		endif
	endfor
	var pwd: string = execute('pwd')->split('\n')[0] # expand('%:h') を使うと、無題の時にうまく行かない
	if pwd =~# '^' .. $HOME
		execute 'topleft Fern $HOME -drawer -reveal=' .. dir .. ' -toggle'
	else
		execute 'topleft Fern ' .. pwd .. ' -drawer -reveal=' .. dir .. ' -toggle'
	endif
	clearjumps # <C-o>, <C-i> で移動後戻るった時も o の <Plug>... が効かなくなる
	augroup FernWin
		autocmd!
		autocmd CursorMoved <buffer> if isdirectory(fern#helper#new().sync.get_cursor_node()._path)
			| 	execute('lcd ' .. fern#helper#new().sync.get_cursor_node()._path, 'silent')
			| else
			| 	execute('lcd ' .. substitute(fern#helper#new().sync.get_cursor_node()._path, '/[^/]\+$', '', ''), 'silent')
			| endif
	augroup END
	return
enddef

def set_fern#undo_ftplugin(): void
	setlocal number< foldcolumn<
	mapclear <buffer>
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
enddef

def s:visible_popup(): bool
	var ls: list<number> = popup_list()
	if ls == []
		return false
	endif
	for i in ls
		if popup_getpos(i).visible
			return true
		endif
	endfor
	return false
enddef

def s:help(): void
	maplist()
		->filter((_, d) => d.rhs =~? '\(call(''fern#\|<plug>(fern-\|call fern_preview\)' && d.lhs !~? '^<plug>(fern-')
		->map((_, d) => printf(' %-7s %s', d.lhs,
				substitute(d.rhs, '<Cmd>call call(''fern#.\+'', \[funcref(''<SNR>'' \.\. getscriptinfo(#{name: ''/fern.\+\.vim\$''})\[0\]\.sid \.\. ''_'' \.\. ''map_\(.\+\)])<CR>', '\1', '')
				->substitute(''')', '', 'g')
			))
		->sort('i')
		->popup_create({
				drag: true,
				border: [1],
				borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
				close: 'click',
				moved: 'any',
				filter: 's:close_popup'
		})
enddef
defcompile

def s:close_popup(id: number, key: string): bool
	if key ==? 'q' || key ==? '/' || key ==? '?' || key ==? "\<Esc>"
		popup_close(id)
	endif
	return true
enddef

def s:init_fern(): void
	setlocal nonumber foldcolumn=0 statusline=%#StatusLineLeft#[%{&filetype}]
	glyph_palette#apply()     # バッファ毎に呼ばないと効かない
	# キー・マップ {{{
	# <Plug>.. の展開だと FernReveal で読み込まれた時動作しない
	# <Plug>(fern-action-leave)
	nnoremap <buffer><C-K>     <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/mapping/node\.vim$'})[0].sid .. '_' .. 'map_leave')])<CR>
	# <Plug>(fern-action-cancel)
	nnoremap <buffer><C-C>     <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/mapping/tree\.vim$'})[0].sid .. '_' .. 'map_cancel')])<CR>
	# <Plug>(fern-action-reload)
	nnoremap <buffer><F5>      <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/mapping/node\.vim$'})[0].sid .. '_' .. 'map_reload_all')])<CR>
	# <Plug>(fern-action-hidden:toggle)
	nnoremap <buffer>!         <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/mapping/filter\.vim$'})[0].sid .. '_' .. 'map_hidden_toggle')])<CR>
	nnoremap <buffer><C-H>     <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/mapping/filter\.vim$'})[0].sid .. '_' .. 'map_hidden_toggle')])<CR>
	# <Plug>(fern-action-mark:toggle)
	nnoremap <buffer>-         <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/mapping/mark\.vim$'})[0].sid .. '_' .. 'map_mark_toggle')])<CR>
	# <Plug>(fern-action-help) 相当
	nnoremap <buffer><leader>? <Plug>(fern-action-help)
	nnoremap <buffer>?         <Cmd>call <SID>help()<CR>
	# <Plug>(fern-action-copy)
	nnoremap <buffer>c         <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/scheme/file/mapping\.vim$'})[0].sid .. '_' .. 'map_copy')])<CR>
	# <Plug>(fern-action-trash=)y<CR>
	nnoremap <buffer>d         <Cmd>call call('fern#mapping#call_without_guard', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/scheme/file/mapping\.vim$'})[0].sid .. '_' .. 'map_trash')])<CR>y<CR>
	# <Plug>(fern-action-open:right)
	nnoremap <buffer>s         <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/mapping/open\.vim$'})[0].sid .. '_' .. 'map_open'), 'rightbelow vsplit'])<CR>
	# <Plug>(fern-action-open:tabedit)
	nnoremap <buffer>t         <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/mapping/open\.vim$'})[0].sid .. '_' .. 'map_open'), 'tabedit'])<CR>
	nnoremap <buffer>o         <Cmd>call <SID>open()<CR>
	# <Plug>(fern-action-rename)
	nnoremap <buffer>r         <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/scheme/file/mapping/rename\.vim$'})[0].sid .. '_' .. 'map_rename'), 'split'])<CR>
	# <Plug>(fern-action-yank)
	nnoremap <buffer>y         <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/mapping/yank\.vim$'})[0].sid .. '_' .. 'map_yank'), 'bufname'])<CR>
	nnoremap <buffer>x         <Cmd>call <SID>OpenSystem()<CR>
	nnoremap <buffer><leader>x <Cmd>call <SID>OpenSystem()<CR>
	# <Plug>(fern-action-clipboard-move)
	nnoremap <buffer>D         <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/scheme/file/mapping/clipboard\.vim$'})[0].sid .. '_' .. 'map_clipboard_move')])<CR>
	# <Plug>(fern-action-clipboard-copy)
	nnoremap <buffer>Y         <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/scheme/file/mapping/clipboard\.vim$'})[0].sid .. '_' .. 'map_clipboard_copy')])<CR>
	# <Plug>(fern-action-clipboard-paste)
	nnoremap <buffer>P         <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/scheme/file/mapping/clipboard\.vim$'})[0].sid .. '_' .. 'map_clipboard_paste')])<CR>
	# <Plug>(fern-action-zoom:reset)
	nnoremap <buffer>i         <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/mapping/drawer\.vim$'})[0].sid .. '_' .. 'map_zoom_reset')])<CR>
	# <Plug>(fern-action-reload:all)
	nnoremap <buffer><C-L>     <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/mapping/node\.vim$'})[0].sid .. '_' .. 'map_reload_all')])<CR>
	# ranger like collapse/expand
	# <Plug>(fern-action-focus:parent)
	nnoremap <buffer>h          <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/mapping/node\.vim$'})[0].sid .. '_' .. 'map_focus_parent')])<CR>
	# <Plug>(fern-action-expand)
	nnoremap <buffer>l          <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern\.vim/autoload/fern/mapping/node\.vim$'})[0].sid .. '_' .. 'map_expand_in')])<CR>
	# FZF {{{
	nnoremap <buffer>/          <Cmd>BLines<CR>
	# }}}
	# fern-preview\.vim 用 {{{
	nnoremap <buffer>p              <Cmd>call fern_preview#toggle_auto_preview()<CR>
	nnoremap <buffer>q              <Cmd>if <SID>visible_popup() <Bar> call fern_preview#toggle_auto_preview() <Bar> else <Bar> quit! <Bar> endif<CR>
	nnoremap <buffer><Space>        <Cmd>if <SID>visible_popup() <Bar> call fern_preview#half_down() <Bar> else <Bar> call feedkeys("\<PageDown>") <Bar> endif<CR>
	nnoremap <buffer><S-Space>      <Cmd>if <SID>visible_popup() <Bar> call fern_preview#half_up() <Bar> else <Bar> call feedkeys("\<PageUp>") <Bar> endif<CR>
	nnoremap <buffer><BackSpace>    <Cmd>if <SID>visible_popup() <Bar> call fern_preview#half_up() <Bar> else <Bar> call feedkeys("\<PageUp>") <Bar> endif<CR>
	# }}}
	# fern-mapping-fzf\.vim {{{
	# <Plug>(fern-action-fzf-files)
	nnoremap <buffer><leader>f <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern-mapping-fzf\.vim/autoload/fern/mapping/fzf\.vim$'})[0].sid .. '_' .. 'map_fzf_files')])<CR>
	nnoremap <buffer>f     <Cmd>call call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo(#{name: '/fern-mapping-fzf\.vim/autoload/fern/mapping/fzf\.vim$'})[0].sid .. '_' .. 'map_fzf_files')])<CR>
	# }}}
	# }}}
	if exists('b:undo_ftplugin')
		if b:undo_ftplugin !~#  '\<call set_fern#undo_ftplugin()'
			b:undo_ftplugin ..= ' | call set_fern#undo_ftplugin()'
		endif
	else
		b:undo_ftplugin = 'call set_fern#undo_ftplugin()'
	endif
enddef

def g:Fern_mapping_fzf_customize_option(spec: dict<any>): dict<any>
	spec.options ..= ' --multi --margin=0% --padding=0% --preview=''~/bin/fzf-preview.sh {}'' --bind=''ctrl-o:execute-silent(xdg-open {})'' --prompt=''Files> '''
	# Note that fzf#vim#with_preview comes from fzf.vim
	# if exists('*fzf#vim#with_preview')
	# 	return fzf#vim#with_preview(a:spec)
	# else
		return spec
	# endif
enddef

def s:open(): void
	if &filetype != 'fern'
		return
	endif

	var helper: dict<any> = fern#helper#new()
	var node: dict<any> = helper.sync.get_cursor_node()
	var status: number = node.status

	if status == helper.STATUS_COLLAPSED
		# <Plug>(fern-action-expand)
		call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo({name: '/fern\.vim/autoload/fern/mapping/node\.vim$'})[0].sid .. '_' .. 'map_expand_in')])
	elseif status == helper.STATUS_EXPANDED
		# <Plug>(fern-action-collapse)
		call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo({name: '/fern\.vim/autoload/fern/mapping/node\.vim$'})[0].sid .. '_' .. 'map_collapse')])
	else
		var mime: string = systemlist('mimetype --brief ' .. resolve(node._path))[0]
		if index(['application/xhtml+xml', 'image/svg+xml', 'application/json', 'application/x-awk', 'application/x-shellscript', 'application/x-desktop'], mime) != -1
				|| mime[0 : 4] ==# 'text/'
			if len(gettabinfo(tabpagenr())[0].windows) == 1
				# <Plug>(fern-action-open:right)
				call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo({name: '/fern\.vim/autoload/fern/mapping/open\.vim$'})[0].sid .. '_' .. 'map_open'), 'rightbelow vsplit'])
			else
				# <Plug>(fern-action-open:select)
				call('fern#mapping#call', [funcref('<SNR>' .. getscriptinfo({name: '/fern\.vim/autoload/fern/mapping/open\.vim$'})[0].sid .. '_' .. 'map_open'), 'select'])
			endif
		else
			if executable(node._path)
				execute 'topleft terminal ' .. node._path
			else
				system('xdg-open ' .. node._path .. ' &')
			endif
		endif
	endif
	return
enddef

def s:OpenSystem(): void # <Plug>(fern-action-open:system) はアプリを閉じるまで Vim が操作不能になる
	system('xdg-open ' .. fern#helper#new().sync.get_cursor_node()._path .. ' &')
enddef

def s:fern_fzf(line: list<string>): void
	if match(bufname(), '^fern://drawer:\d\+/file:///.\+;\$$') == 0
		var winids = gettabinfo(tabpagenr())[0].windows
		filter(winids, s:fern_fzf_filter)
		if winids == []
			# let fern_win = bufwinid(bufnr())
			execute 'rightbelow vsplit ' .. line[-1]
			# call win_execute(fern_win, 'feedkeys("\<Plug>(fern-action-zoom:reset)")')
		else
			win_execute(winids[0], 'edit ' .. line[-1])
		endif
	else
		execute 'edit ' .. line[-1]
	endif
	remove(line, -1)
	if len(line) >= 1
		args join(line)
	endif
enddef

def s:fern_fzf_filter(i: number, v: number): bool
	var v_dic: dict<number> = getwininfo(v)[0]
	if v == bufwinid(bufnr()) || v_dic.loclist == 1 || v_dic.quickfix == 1 || v_dic.terminal == 1
		return false
	endif
	return true
enddef
