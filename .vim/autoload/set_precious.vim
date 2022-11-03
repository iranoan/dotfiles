function set_precious#main() abort
	packadd vim-precious
	let g:precious_enable_switchers = {
				\ 'help': {
				\ 	'setfiletype': 0
				\ },
				\}
endfunction
