scriptencoding utf-8

function set_fzf_neoyank#main() abort
	" yank の履歴 https://github.com/Shougo/neoyank.vim {{{
	packadd neoyank.vim " }}}
	if !pack_manage#IsInstalled('fzf.vim')
		call set_fzf_vim#main()
		autocmd! loadFZF_Vim
		augroup! loadFZF_Vim
		delfunction set_fzf_vim#main
	endif
	packadd fzf-neoyank
endfunction
