scriptencoding utf-8

function set_fzf_tabs#main() abort
	packadd fzf-tabs
	if !is_plugin_installed#Main('fzf.vim')
		call set_fzf_vim#main()
		autocmd! loadFZF_Vim
		augroup! loadFZF_Vim
		delfunction set_fzf_vim#main
	endif
	packadd fzf-neoyank
endfunction
