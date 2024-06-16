scriptencoding utf-8

function set_fzf_tabs#main() abort
	packadd fzf-tabs
	if !pack_manage#IsInstalled('fzf.vim')
		call set_fzf_vim#main()
		autocmd! loadFZF_Vim
		augroup! loadFZF_Vim
		delfunction set_fzf_vim#main
	endif
	let g:fzf_tabs_options = ['--preview', '~/bin/fzf-preview.sh {2}']
endfunction
