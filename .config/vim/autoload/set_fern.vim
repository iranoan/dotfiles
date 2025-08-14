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
	return
enddef

def set_fern#undo_ftplugin(): void
	setlocal number< foldcolumn<
	nunmap <buffer>!
	nunmap <buffer>-
	nunmap <buffer>.
	nunmap <buffer>/
	nunmap <buffer><C-C>
	nunmap <buffer><C-H>
	nunmap <buffer><C-K>
	nunmap <buffer><C-L>
	nunmap <buffer><F5>
	nunmap <buffer><S-Space>
	nunmap <buffer><Space>
	nunmap <buffer><leader>f
	nunmap <buffer><leader>x
	nunmap <buffer>?
	nunmap <buffer>D
	nunmap <buffer>P
	nunmap <buffer>Y
	nunmap <buffer>a
	nunmap <buffer>c
	nunmap <buffer>d
	nunmap <buffer>f
	nunmap <buffer>h
	nunmap <buffer>i
	nunmap <buffer>l
	nunmap <buffer>o
	nunmap <buffer>p
	nunmap <buffer>q
	nunmap <buffer>r
	nunmap <buffer>s
	nunmap <buffer>t
	nunmap <buffer>x
	nunmap <buffer>y
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
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
	nnoremap <expr><buffer>o         set_fern#open(1)
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
	nnoremap <expr><buffer>q         popup_list() != [] ? '<Plug>(fern-action-preview:auto:toggle)' : ':quit<CR>'
	nnoremap <expr><buffer><Space>   popup_list() != [] ? '<Plug>(fern-action-preview:scroll:down:half)' : '<PageDown>'
	nnoremap <expr><buffer><S-Space> popup_list() != [] ? '<Plug>(fern-action-preview:scroll:up:half)' : '<PageUp>'
	# fzf-mapping-fzf.vim
	nnoremap <buffer><leader>f       <Plug>(fern-action-fzf-files)
	nnoremap <buffer>f               <Plug>(fern-action-fzf-files)
	# ranger like collapse/expand
	nnoremap <expr><buffer>h         set_fern#open(-1)
	nnoremap <expr><buffer>l         set_fern#open(0)
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

def set_fern#open(cd: number): string
	if &filetype != 'fern'
		return ''
	endif

	var helper: dict<any> = fern#helper#new()
	var node: dict<any> = helper.sync.get_cursor_node()

	execute('lcd ' .. node._path, 'silent!')
	if cd == -1
		execute('lcd ' .. substitute(node._path, '/[^/]\+$', '', ''), 'silent!')
		return "\<Plug>(fern-action-focus:parent)"
	elseif cd == 0
		return "\<Plug>(fern-action-expand)"
	endif
	if &filetype != 'fern'
		return ''
	endif

	var status: number = node.status
	if status == helper.STATUS_COLLAPSED
		return "\<Plug>(fern-action-expand)"
	elseif status == helper.STATUS_EXPANDED
		return "\<Plug>(fern-action-collapse)"
	else
		var mime: string = systemlist('file --mime-type --brief ' .. resolve(node._path))[0]
		if mime =~# '^application/xhtml+xml$'
				|| mime =~# '^image/svg+xml$'
			if len(gettabinfo(tabpagenr())[0].windows) == 1
				return "\<Plug>(fern-action-open:right)"
			else
				return "\<Plug>(fern-action-open:select)"
			endif
		elseif mime[0 : 4] !=# 'text/'
			if executable(node._path)
				execute 'topleft terminal ' .. node._path
			else
				system('xdg-open ' .. node._path .. ' &')
			endif
			return ''
		else
			if len(gettabinfo(tabpagenr())[0].windows) == 1
				return "\<Plug>(fern-action-open:right)"
			else
				return "\<Plug>(fern-action-open:select)"
			endif
		endif
	endif
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
