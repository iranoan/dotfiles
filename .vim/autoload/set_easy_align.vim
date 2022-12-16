scriptencoding utf-8

function set_easy_align#main() abort
	call manage_pack#SetMAP('vim-easy-align',  '(EasyAlign)', [
			\ {'mode': 'n', 'key': '<Leader>ea', 'cmd': '(EasyAlign)'},
			\ {'mode': 'x', 'key': '<Enter>',    'cmd': '(EasyAlign)'},
			\ {'mode': 'x', 'key': '<Leader>ea', 'cmd': '(EasyAlign)'}
			\ ] )
	let g:easy_align_delimiters = {
				\ '|': { 'align': 'al*' },
				\ '&': { 'align': 'al*' }
				\ }
endfunction
