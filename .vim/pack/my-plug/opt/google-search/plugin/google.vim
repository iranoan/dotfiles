if exists('g:google_plugin')
	finish
endif
let g:google_plugin = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

command -range SearchByGoogle call google#search_by_google(<range>)

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
