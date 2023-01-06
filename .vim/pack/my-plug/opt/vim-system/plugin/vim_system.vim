scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

if exists('g:transform')
	finish
endif
let g:transform = 1

command VimSystem call vim_system#Write()
command VimSystemEcho call vim_system#Echo()

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
