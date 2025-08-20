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
	packadd fern-preview.vim " }}}
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
		autocmd CursorMoved <buffer> call execute('lcd ' .. substitute(fern#helper#new().sync.get_cursor_node()._path, '/[^/]\+$', '', ''), 'silent')
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

def s:init_fern(): void
	setlocal nonumber foldcolumn=0 statusline=%#StatusLineLeft#[%{&filetype}]
	glyph_palette#apply()     # バッファ毎に呼ばないと効かない
	# キー・マップ
	nnoremap <buffer><C-K>           <Plug>(fern-action-leave)
	nnoremap <buffer><C-C>           <Plug>(fern-action-cancel)
	# nnoremap <buffer><Enter>         <Plug>(fern-action-open:select)
	nnoremap <buffer><F5>            <Plug>(fern-action-reload)
	nnoremap <buffer>!               <Plug>(fern-action-hidden:toggle)
	nnoremap <buffer><C-H>           <Plug>(fern-action-hidden:toggle)
	nnoremap <buffer>-               <Plug>(fern-action-mark:toggle)
	nnoremap <buffer>.               <Plug>(fern-action-repeat)
	# nnoremap <buffer>?               <Plug>(fern-action-help)
	nnoremap <buffer>?               <Cmd>echo join(filter(filter(split(execute('map'), '\n'), 'v:val =~? "\(fern-"' ), 'v:val !~? "^[nvxsoilct] *<plug"'), "\n")<CR>
	nnoremap <buffer>a               <Plug>(fern-action-choice)
	nnoremap <buffer>c               <Plug>(fern-action-copy)
	nnoremap <buffer>d               <Plug>(fern-action-trash=)y<CR>
	nnoremap <buffer>s               <Plug>(fern-action-open:right)
	nnoremap <buffer>t               <Plug>(fern-action-open:tabedit)
	nnoremap <buffer>o               <Cmd>call <SID>open()<CR>
	nnoremap <buffer>r               <Plug>(fern-action-rename)
	nnoremap <buffer>y               <Plug>(fern-action-yank)
	nnoremap <buffer>x               <Cmd>call <SID>OpenSystem()<CR>
	nnoremap <buffer><leader>x       <Cmd>call <SID>OpenSystem()<CR>
	nnoremap <buffer>D               <Plug>(fern-action-clipboard-move)
	nnoremap <buffer>Y               <Plug>(fern-action-clipboard-copy)
	nnoremap <buffer>P               <Plug>(fern-action-clipboard-paste)
	nnoremap <buffer>i               <Plug>(fern-action-zoom:reset)
	nnoremap <buffer><C-L>           <Plug>(fern-action-reload:all)
	# FZF
	nnoremap <buffer>/               <Cmd>BLines<CR>
	# fern-preview.vim 用
	nnoremap <buffer>p               <Plug>(fern-action-preview:auto:toggle)
	nnoremap <expr><buffer>q         <SID>visible_popup() ? '<Plug>(fern-action-preview:auto:toggle)' : ':bwipeout!<CR>'
	# ↑ quit にすると、再度開いた時に o の <Plug>... が効かなくなる
	# 正しくは BufWinEnter で読み込まれた時
	nnoremap <expr><buffer><Space>   <SID>visible_popup() ? '<Plug>(fern-action-preview:scroll:down:half)' : '<PageDown>'
	nnoremap <expr><buffer><S-Space> <SID>visible_popup() ? '<Plug>(fern-action-preview:scroll:up:half)' : '<PageUp>'
	# fzf-mapping-fzf.vim
	nnoremap <buffer><leader>f       <Plug>(fern-action-fzf-files)
	nnoremap <buffer>f               <Plug>(fern-action-fzf-files)
	# ranger like collapse/expand
	nnoremap <buffer>h               <Plug>(fern-action-focus:parent)
	nnoremap <buffer>l               <Plug>(fern-action-expand)
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
	var helper: dict<any> = fern#helper#new()
	var node: dict<any> = helper.sync.get_cursor_node()

	if &filetype != 'fern'
		return
	endif

	var status: number = node.status
	if status == helper.STATUS_COLLAPSED
		feedkeys("\<Plug>(fern-action-expand)")
	elseif status == helper.STATUS_EXPANDED
		feedkeys("\<Plug>(fern-action-collapse)")
	else
		var mime: string = systemlist('mimetype --brief ' .. resolve(node._path))[0]
		if index(['application/xhtml+xml', 'image/svg+xml', 'application/json'], mime) != -1
				|| mime[0 : 4] ==# 'text/'
			if len(gettabinfo(tabpagenr())[0].windows) == 1
				feedkeys("\<Plug>(fern-action-open:right)")
			else
				feedkeys("\<Plug>(fern-action-open:select)")
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
