scriptencoding utf-8

function set_fzf_neoyank#main(cmd) abort
	" yank の履歴 https://github.com/Shougo/neoyank.vim {{{
	packadd neoyank.vim " }}}
	if !pack_manage#IsInstalled('fzf.vim')
		call set_fzf_vim#main('')
		delfunction set_fzf_vim#main
	endif
	call pack_manage#SetMAP('fzf-neoyank', a:cmd, [
				\ #{mode: 'n', key: '<Leader>fy', method: 1, cmd: 'FZFNeoyank'},
				\ #{mode: 'n', key: '<Leader>fY', method: 1, cmd: 'FZFNeoyank # P'},
				\ #{mode: 'x', key: '<Leader>fy', method: 1, cmd: 'FZFNeoyankSelection'},
				\ ] )
endfunction
