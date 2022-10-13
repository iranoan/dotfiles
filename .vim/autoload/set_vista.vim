function set_vista#main() abort
	if !is_plugin_installed#main('vim-lsp')
		call set_vimlsp#main()
		autocmd! loadvimlsp
		augroup! loadvimlsp
		delfunction set_vimlsp#main
	endif
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
endfunction
