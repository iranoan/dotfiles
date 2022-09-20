scriptencoding utf-8

function set_fern#main() abort
	let g:fern#disable_default_mappings = 1
	let g:fern#disable_drawer_smart_quit = 1 " fern のウィンドウだけに成っても Vim を閉じない
	let g:fern#default_exclude = '^\%\(\(\.git\|node_modules\)\|.\+\(\.o\|\.fls\|\.synctex\.gz\|\.fdb_latexmk\|\.toc\|\.out\|\.dvi\|\.aux\|\.nav\|\.snm\)\)$'
	" *g:fern#comparator*
	" 	A |String| name of comparator used to sort tree items. Allowed value
	" 	is a key of |g:fern#comparators|.
	" 	Default: "default"
	packadd fern.vim
	" https://github.com/lambdalisue/fern-git-status.vim
	packadd fern-git-status.vim      " Git のステータス表示
	" https://github.com/yuki-yano/fern-preview.vim
	packadd fern-preview.vim         " プレビュー
	" https://github.com/lambdalisue/fern-hijack.vim
	packadd fern-hijack.vim          " netfw を入れ替え
	" fzf と連携
	" https://github.com/LumaKernel/fern-mapping-fzf.vim
	packadd fern-mapping-fzf.vim
	let g:fern#mapping#fzf#disable_default_mappings = 1
	call set_fzf_vim#main()
	" zoom:reset
	" アイコン表示
	" https://github.com/lambdalisue/glyph-palette.vim
	packadd glyph-palette.vim
	" https://github.com/lambdalisue/nerdfont.vim
	packadd nerdfont.vim
	" https://github.com/lambdalisue/fern-renderer-nerdfont.vim
	packadd fern-renderer-nerdfont.vim
	let g:fern#renderer = "nerdfont"
	augroup fern-custom
		autocmd!
		autocmd FileType nerdtree,startify call glyph_palette#apply()
		autocmd FileType fern call s:init_fern()
	augroup END
endfunction

function s:init_fern() abort
	setlocal nonumber foldcolumn=0
	call glyph_palette#apply()     " バッファ毎に呼ばないと効かない
	" fzf-mapping-fzf.vim
	let b:fzf_action = get(g:, 'fzf_action', {
				\ 'ctrl-t': 'tab split',
				\ 'ctrl-x': 'split',
				\ 'ctrl-v': 'vsplit'
				\ })
	let b:fzf_action['enter'] = function('s:fern_fzf')
	" キー・マップ
	nmap <buffer><BS>            <Plug>(fern-action-leave)
	nmap <buffer><C-C>           <Plug>(fern-action-cancel)
	nmap <buffer><C-L>           <Plug>(fern-action-redraw)
	nmap <buffer><Enter>         <Plug>(fern-action-open:select)
	nmap <buffer><F5>            <Plug>(fern-action-reload)
	nmap <buffer>!               <Plug>(fern-action-hidden:toggle)
	nmap <buffer><C-H>           <Plug>(fern-action-hidden:toggle)
	nmap <buffer>-               <Plug>(fern-action-mark:toggle)
	nmap <buffer>.               <Plug>(fern-action-repeat)
	nmap <buffer>?               <Plug>(fern-action-help)
	" nmap <buffer>?               <Cmd>echo join(filter(filter(split(execute('map'), '\n'), 'v:val =~? "\(fern-"' ), 'v:val !~? "^[nvxsoilct] *<plug"'), "\n")<CR>
	nmap <buffer>a               <Plug>(fern-action-choice)
	nmap <buffer>c               <Plug>(fern-action-copy)
	nmap <buffer>d               <Plug>(fern-action-trash=)y<CR>
	nmap <buffer>s               <Plug>(fern-action-open:right)
	nmap <buffer>h               <Plug>(fern-action-collapse)
	nmap <buffer>l               <Plug>(fern-action-expand)
	" nmap <buffer>o               <Cmd>call set_fern#open()<CR>
	nmap <expr><buffer>o         (len(getwininfo()) == 1 && match(bufname(), '^fern://drawer:\d\+/file:///.\+;\$$') == 0) ? '<Plug>(fern-action-open:right)' : '<Plug>(fern-action-open:select)'
	nmap <buffer>r               <Plug>(fern-action-rename)
	nmap <buffer>y               <Plug>(fern-action-yank)
	nmap <buffer>x               <Plug>(fern-action-open:system)
	nmap <buffer>D               <Plug>(fern-action-clipboard-move)
	nmap <buffer>Y               <Plug>(fern-action-clipboard-copy)
	nmap <buffer>P               <Plug>(fern-action-clipboard-paste)
	nmap <buffer>i               <Plug>(fern-action-zoom:reset)
	" FZF
	nmap <buffer>f               :BLines<CR>
	" fern-preview.vim 用
	nmap <buffer>p               <Plug>(fern-action-preview:auto:toggle)
	nmap <expr><buffer>q         popup_list() != [] ? '<Plug>(fern-action-preview:auto:toggle)' : ':quit<CR>'
	nmap <expr><buffer><Space>   popup_list() != [] ? '<Plug>(fern-action-preview:scroll:down:half)' : '<PageDown>'
	nmap <expr><buffer><S-Space> popup_list() != [] ? '<Plug>(fern-action-preview:scroll:up:half)' : '<PageUp>'
	" fzf-mapping-fzf.vim
	nmap <buffer><leader>f       <Plug>(fern-action-fzf-files)
endfunction

function set_fern#open() abort
	if &filetype != 'fern'
		return
	endif
	if len(getwininfo()) == 1 && match(bufname(), '^fern://drawer:\d\+/file:///.\+;\$$') == 0
		call feedkeys("\<Plug>(fern-action-open:right)")
		call feedkeys("\<Plug>(fern-action-zoom:reset)")
	else
		call feedkeys("\<Plug>(fern-action-open:select)")
	endif
endfunction

function s:fern_fzf(line) abort
	if match(bufname(), '^fern://drawer:\d\+/file:///.\+;\$$') == 0
		let winids = gettabinfo('.')[0]['windows']
		call filter(winids, function('s:fern_fzf_filter'))
		if winids == []
			" let fern_win = bufwinid(bufnr())
			execute 'rightbelow vsplit ' .. a:line[-1]
			" call win_execute(fern_win, 'feedkeys("\<Plug>(fern-action-zoom:reset)")')
		else
			call win_execute(winids[0], 'edit ' .. a:line[-1])
		endif
	else
		execute 'edit ' .. a:line[-1]
	endif
	call remove(a:line, -1)
	if len(a:line) >= 1
		args join(a:line)
	endif
endfunction

function s:fern_fzf_filter(i, v) abort
	let v_dic = getwininfo(a:v)[0]
	if a:v == bufwinid(bufnr()) || v_dic['loclist'] == 1 || v_dic['quickfix'] == 1 || v_dic['terminal'] == 1
		return v:false
	endif
	return v:true
endfunction
