function set_previm#main() abort
	packadd previm
	execute 'set filetype=' .. &filetype
	let g:previm_open_cmd='firefox'
	" let g:previm_open_cmd='open -a Google\ Chrome'
	let g:previm_disable_default_css = 1
	let g:previm_custom_css_path = '~/public_html/iranoan/default.css'
endfunction
