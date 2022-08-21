" Author:  Iranoan <iranoan+vim@gmail.com>
" License: GPL Ver.3.

scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

if exists('g:pack_helptags')
	finish
endif
let g:pack_helptags = 1

command PackHelpTags call pack_helptags#remakehelptags()

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
