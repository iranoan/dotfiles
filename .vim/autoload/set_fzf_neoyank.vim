scriptencoding utf-8

function set_fzf_neoyank#main() abort
	" yank の履歴 https://github.com/Shougo/neoyank.vim
	packadd neoyank.vim
	call set_fzf_vim#main()
	packadd fzf-neoyank
endfunction
