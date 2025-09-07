augroup loadVista
	autocmd!
	autocmd CmdUndefined Vista
				\ call set_vista_voom#Vista()
				\ | call autocmd_delete([#{group: 'loadVista'}])
augroup END

augroup loadVoom
	autocmd!
	autocmd CmdUndefined Voom
				\ call set_vista_voom#VOom()
				\ | call autocmd_delete([#{group: 'loadVoom'}])
augroup END

def set_vista_voom#Switch(): void # Voom に未対応は Vista を使う様に分岐
	var voom_support_list: list<string> = glob('$MYVIMDIR' .. '/pack/*/opt/VOoM/autoload/voom/voom_vimplugin*/voom_mode_*.py', true, true)
	var s: number = matchend(voom_support_list[0], '.\+/voom_mode_')
	map(voom_support_list, (_, v) => v[s : -4 ])
	var name: string = bufname()
	if &filetype ==? 'tex'
		execute 'Voom latex'
	elseif &filetype ==? 'text'
		execute 'Voom markdown'
	elseif &filetype ==? 'vim' # Vista というか LSP vim-language-Server は vim9script 未対応 2023/01/17
		execute 'Voom vimoutliner'
	elseif index( ['c', 'h', 'cpp', 'sh', 'python'], &filetype ) >= 0 # taglist, Voom 両方に対応しているファイルタイプも有るので、取り敢えずこれだけを Vista を使う
		execute 'Vista'
		# for w in gettabinfo(tabpagenr())[0]['windows']
		# 	if has_key(getwininfo(w)[0]['variables'], 'vista_first_line_hi_id') # この時点ではウィンドウがまだ開かれていない
		# 		win_execute(w, 'setlocal statusline=%#StatusLineRight#' .. escape(vista#statusline#(), ' '))
		# 	endif
		# endfor
		return
	elseif &filetype ==? 'xhtml'
		execute 'Voom html'
	elseif index( voom_support_list, &filetype ) >= 0
		execute 'Voom ' .. &filetype
	else
		echomsg 'No Support filetype:''' .. &filetype .. ''''
		return
	endif
	execute 'setlocal statusline=%#StatusLineRight#[%{&filetype}]\ ' .. name
enddef

function set_vista_voom#VOom() abort
	set modelineexpr " ヘルプファイルで使っている
	let g:voom_tree_placement = 'right'
	let g:voom_tree_width = 40
	packadd VOoM
	call timer_start(1, {->execute('delfunction set_vista_voom#VOom')})
endfunction

function set_vista_voom#Vista() abort
	if !pack_manage#IsInstalled('vim-lsp')
		call set_vimlsp#main()
		autocmd! loadvimlsp
		augroup! loadvimlsp
	endif
	" if !pack_manage#IsInstalled('ale') " 通常不要
	" 	call set_ale#main()
	" 	autocmd! loadALE
	" 	augroup! loadALE
	" endif
	packadd vista.vim
	let g:vista_executive_for = {
		\ 'c'     : 'vim_lsp',
		\ 'cpp'   : 'vim_lsp',
		\ 'php'   : 'vim_lsp',
		\ 'python': 'vim_lsp',
		\ 'sh'    : 'vim_lsp',
		\ 'vim'   : 'ale',
		\ }
		let g:vista_fzf_preview = ['right:50%']
		let g:vista#renderer#enable_icon = 1
		" let g:vista#renderer#icons = {
		" 	\   "function": "\uf794",
		" 	\   "variable": "\uf71b",
		" 	\  }
	let g:vista_icon_indent = ['╰─▸ ', '├─▸ ']
	" let g:vista_finder_alternative_executives=['Voom']
	" let g:vista_echo_cursor_strategy='floating_win'
	" let g:vista_fzf_preview = ['right:50%']
	call timer_start(1, {->execute('delfunction set_vista_voom#Vista')})
endfunction
