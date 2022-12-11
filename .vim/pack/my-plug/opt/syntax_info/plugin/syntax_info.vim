vim9script

if exists('g:syntax_info')
	finish
endif
let g:syntax_info = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

command! SyntaxInfo syntax_info#Main()

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
