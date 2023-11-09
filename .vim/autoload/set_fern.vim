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
	" netfw を入れ替え https://github.com/lambdalisue/fern-hijack.vim {{{
	packadd fern-hijack.vim "}}}
	" fzf と連携 https://github.com/LumaKernel/fern-mapping-fzf.vim {{{
	packadd fern-mapping-fzf.vim
	let g:fern#mapping#fzf#disable_default_mappings = 1
	" g:fern#mapping#fzf#fzf_options を指定すると、b:fzf_action, g:fzf_action が無視され開けなくなる
	" let g:fern#mapping#fzf#fzf_options = {'options': '--multi --no-unicode --margin=0% --padding=0% --preview=''~/bin/fzf-preview.sh {}'' --bind=''ctrl-]:change-preview-window(hidden|)'''}
	if !manage_pack#IsInstalled('fzf.vim')
		call set_fzf_vim#main()
		autocmd! loadFZF_Vim
		augroup! loadFZF_Vim
		delfunction set_fzf_vim#main
	endif
	" }}}
	" アイコン表示 {{{
		" https://github.com/lambdalisue/glyph-palette.vim {{{
		packadd glyph-palette.vim " }}}
		" https://github.com/lambdalisue/nerdfont.vim {{{
		packadd nerdfont.vim " }}}
		" https://github.com/lambdalisue/fern-renderer-nerdfont.vim {{{
		packadd fern-renderer-nerdfont.vim
		let g:fern#renderer = "nerdfont"
		augroup fern-custom
			autocmd!
			autocmd FileType nerdtree,startify call glyph_palette#apply()
			autocmd FileType fern call s:init_fern()
		augroup END
		" }}}
	" }}}
endfunction

def s:init_fern(): void
	setlocal nonumber foldcolumn=0 statusline=%#StatusLineLeft#[%{&filetype}]
	glyph_palette#apply()     # バッファ毎に呼ばないと効かない
	b:fzf_action.enter = s:fern_fzf
	# キー・マップ
	nnoremap <buffer><C-K>           <Plug>(fern-action-leave)
	nnoremap <buffer><C-C>           <Plug>(fern-action-cancel)
	nnoremap <buffer><C-L>           <Plug>(fern-action-redraw)
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
	nnoremap <expr><buffer>o         set_fern#open()
	nnoremap <buffer>r               <Plug>(fern-action-rename)
	nnoremap <buffer>y               <Plug>(fern-action-yank)
	nnoremap <buffer>x               <Plug>(fern-action-open:system)
	nnoremap <buffer><leader>x       <Plug>(fern-action-open:system)
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
	nnoremap <buffer>h               <Plug>(fern-action-collapse)
	nnoremap <buffer>l               <Plug>(fern-action-expand)
enddef

def set_fern#open(): string
	if &filetype != 'fern'
		return ''
	endif
	var f: string = getline('.')
	if match(f, '^ \+ .\+[\u001F]') !=# -1
		feedkeys("\<Plug>(fern-action-expand)")
	elseif match(f, '^ \+ .\+[\u001F]') !=# -1
		feedkeys("\<Plug>(fern-action-collapse)")
	elseif match(['asf', 'aux', 'avi', 'bmc', 'bmp', 'cer', 'chm', 'chw', 'class', 'crt', 'cur', 'dll', 'doc', 'docx', 'dvi', 'emf', 'eps', 'exe', 'fdb_latexmk', 'fls', 'flv', 'gif', 'gpg', 'hlp', 'hmereg', 'icc', 'icm', 'ico', 'ics', 'jar', 'jp2', 'jpeg', 'jpg', 'lzh', 'm4a', 'mkv', 'mov', 'mp3', 'mp4', 'mpg', 'nav', 'nvram', 'o', 'obj', 'odb', 'odg', 'odp', 'ods', 'odt', 'oll', 'opf', 'opp', 'out', 'pdf', 'pfa', 'pl3', 'png', 'ppm', 'ppt', 'pptx', 'ps', 'pyc', 'reg', 'rm', 'rtf', 'snm', 'sqlite', 'svg', 'swf', 'swp', 'tfm', 'toc', 'ttf', 'vbox', 'vbox-prev', 'vdi', 'vf', 'webm', 'wmf', 'wmv', 'xls', 'xlsm', 'xlsx'], '^' .. matchstr(f, '^ \+[^ ] .*\.\zs.\+\ze[\u001F]') .. '$') != -1 # バイナリ
		feedkeys("\<Plug>(fern-action-open:system)")
	else
		if len(gettabinfo(tabpagenr())[0].windows) == 1
			feedkeys("\<Plug>(fern-action-open:right)")
		else
			feedkeys("\<Plug>(fern-action-open:select)")
		endif
	endif
	return ''
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
