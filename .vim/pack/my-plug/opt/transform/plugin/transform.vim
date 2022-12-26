scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

if exists('g:transform')
	finish
endif
let g:transform = 1

command -range=% Zen2han <line1>,<line2>call transform#Zen2hanCmd()
command -range=% InsertSpace <line1>,<line2>call transform#InsertSpaceCmd()

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
