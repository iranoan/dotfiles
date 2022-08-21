scriptencoding utf-8

function set_vimspector#main() abort
	let g:vimspector_enable_mappings = 'HUMAN' " packadd の前で指定しないと、実際には mapping されない
	" let g:vimspector_variables_display_mode = 'full'
	packadd vimspector
endfunction
