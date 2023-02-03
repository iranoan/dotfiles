scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

if exists('g:transform')
	finish
endif
let g:transform = 1

command VimSystem call vim_system#Write()
command VimSystemEcho call vim_system#Echo()
command System call vim_system#EnvWrite()
command SystemEcho call vim_system#EnvEcho()

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
