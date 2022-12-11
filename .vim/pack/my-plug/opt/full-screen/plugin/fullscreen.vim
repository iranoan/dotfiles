vim9script

if exists('g:fullscreen')
	finish
endif
let g:fullscreen = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

command Fullscreen fullscreen#Main()

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
