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
	packadd fern-git-status.vim " }}}
	" プレビュー  https://github.com/yuki-yano/fern-preview.vim {{{
	packadd fern-preview.vim " }}}
	" netfw を入れ替え https://github.com/lambdalisue/fern-hijack.vim {{{
	packadd fern-hijack.vim "}}}
	" fzf と連携 https://github.com/LumaKernel/fern-mapping-fzf.vim {{{
	packadd fern-mapping-fzf.vim
	let g:fern#mapping#fzf#disable_default_mappings = 1
	" g:fern#mapping#fzf#fzf_options を指定すると、b:fzf_action, g:fzf_action が無視され開けなくなる
	" let b:fzf_action = get(g:, 'fzf_action', {
	" 			\ 'ctrl-t': 'tab split',
	" 			\ 'ctrl-x': 'split',
	" 			\ 'ctrl-v': 'vsplit'
	" 			\ })
	" let b:fzf_action.enter = function('s:fern_fzf')
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
	setlocal nonumber foldcolumn=0
	glyph_palette#apply()     # バッファ毎に呼ばないと効かない
	b:fzf_action = get(g:, 'fzf_action', {
				\ 'ctrl-t': 'tab split',
				\ 'ctrl-x': 'split',
				\ 'ctrl-v': 'vsplit'
				\ })
	b:fzf_action.enter = s:fern_fzf
	# キー・マップ
	nmap <buffer><C-K>           <Plug>(fern-action-leave)
	nmap <buffer><C-C>           <Plug>(fern-action-cancel)
	nmap <buffer><C-L>           <Plug>(fern-action-redraw)
	# nmap <buffer><Enter>         <Plug>(fern-action-open:select)
	nmap <buffer><F5>            <Plug>(fern-action-reload)
	nmap <buffer>!               <Plug>(fern-action-hidden:toggle)
	nmap <buffer><C-H>           <Plug>(fern-action-hidden:toggle)
	nmap <buffer>-               <Plug>(fern-action-mark:toggle)
	nmap <buffer>.               <Plug>(fern-action-repeat)
	# nmap <buffer>?               <Plug>(fern-action-help)
	nmap <buffer>?               <Cmd>echo join(filter(filter(split(execute('map'), '\n'), 'v:val =~? "\(fern-"' ), 'v:val !~? "^[nvxsoilct] *<plug"'), "\n")<CR>
	nmap <buffer>a               <Plug>(fern-action-choice)
	nmap <buffer>c               <Plug>(fern-action-copy)
	nmap <buffer>d               <Plug>(fern-action-trash=)y<CR>
	nmap <buffer>s               <Plug>(fern-action-open:right)
	nmap <expr><buffer>O         fern#smart#leaf("\<Plug>(fern-action-collapse)", "\<Plug>(fern-action-expand)", "\<Plug>(fern-action-collapse)")
	nmap <expr><buffer>o         set_fern#open()
	nmap <buffer>r               <Plug>(fern-action-rename)
	nmap <buffer>y               <Plug>(fern-action-yank)
	nmap <buffer>x               <Plug>(fern-action-open:system)
	nmap <buffer><leader>x       <Plug>(fern-action-open:system)
	nmap <buffer>D               <Plug>(fern-action-clipboard-move)
	nmap <buffer>Y               <Plug>(fern-action-clipboard-copy)
	nmap <buffer>P               <Plug>(fern-action-clipboard-paste)
	nmap <buffer>i               <Plug>(fern-action-zoom:reset)
	# FZF
	nmap <buffer>f               <Cmd>BLines<CR>
	nmap <buffer>/               <Cmd>BLines<CR>
	# fern-preview.vim 用
	nmap <buffer>p               <Plug>(fern-action-preview:auto:toggle)
	nmap <expr><buffer>q         popup_list() != [] ? '<Plug>(fern-action-preview:auto:toggle)' : ':quit<CR>'
	nmap <expr><buffer><Space>   popup_list() != [] ? '<Plug>(fern-action-preview:scroll:down:half)' : '<PageDown>'
	nmap <expr><buffer><S-Space> popup_list() != [] ? '<Plug>(fern-action-preview:scroll:up:half)' : '<PageUp>'
	# fzf-mapping-fzf.vim
	nmap <buffer><leader>f       <Plug>(fern-action-fzf-files)
enddef

function set_fern#open() abort
	if &filetype != 'fern'
		return
	endif
	let f = getline('.')
	if match(f, '^ \+ .\+[\u001F]') !=# -1
		call feedkeys("\<Plug>(fern-action-expand)")
	elseif match(f, '^ \+ .\+[\u001F]') !=# -1
		call feedkeys("\<Plug>(fern-action-collapse)")
	elseif match(['asf', 'aux', 'avi', 'bmc', 'bmp', 'cer', 'chm', 'chw', 'class', 'crt', 'cur', 'dll', 'doc', 'docx', 'dvi', 'emf', 'eps', 'exe', 'fdb_latexmk', 'fls', 'flv', 'gif', 'gpg', 'hlp', 'hmereg', 'icc', 'icm', 'ico', 'ics', 'jar', 'jp2', 'jpeg', 'jpg', 'lzh', 'm4a', 'mkv', 'mov', 'mp3', 'mp4', 'mpg', 'nav', 'nvram', 'o', 'obj', 'odb', 'odg', 'odp', 'ods', 'odt', 'oll', 'opf', 'opp', 'out', 'pdf', 'pfa', 'pl3', 'png', 'ppm', 'ppt', 'pptx', 'ps', 'pyc', 'reg', 'rm', 'rtf', 'snm', 'sqlite', 'svg', 'swf', 'swp', 'tfm', 'toc', 'ttf', 'vbox', 'vbox-prev', 'vdi', 'vf', 'webm', 'wmf', 'wmv', 'xls', 'xlsm', 'xlsx'], '^' .. matchstr(f, '^ \+[^ ] .*\.\zs.\+\ze[\u001F]') .. '$') != -1 " バイナリ
		call feedkeys("\<Plug>(fern-action-open:system)")
	else
		if len(getwininfo()) == 1 && match(bufname(), '^fern://drawer:\d\+/file:///.\+;\$$') == 0
			call feedkeys("\<Plug>(fern-action-open:right)")
			call feedkeys("\<Plug>(fern-action-zoom:reset)")
		else
			call feedkeys("\<Plug>(fern-action-open:select)")
		endif
	endif
endfunction

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
