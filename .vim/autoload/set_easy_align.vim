scriptencoding utf-8

function set_easy_align#main() abort
	call set_map_plug#main('vim-easy-align',  '(EasyAlign)', [
			\ {'mode': 'n', 'key': '<Leader>ea', 'cmd': '(EasyAlign)'},
			\ {'mode': 'v', 'key': '<Enter>',    'cmd': '(EasyAlign)'},
			\ {'mode': 'v', 'key': '<Leader>ea', 'cmd': '(EasyAlign)'}
			\ ] )
	let g:easy_align_delimiters = {
				\ '|': { 'align': 'al*' },
				\ '&': { 'align': 'al*' }
				\ }
endfunction
