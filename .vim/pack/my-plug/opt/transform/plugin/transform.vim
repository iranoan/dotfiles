scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

if exists('g:transform')
	finish
endif
let g:transform = 1

command -range=% Zen2han     let s:pos = getpos('.') | :<line1>,<line2>call transform#Zen2hanCmd()     | call setpos('.', s:pos)
command -range=% InsertSpace let s:pos = getpos('.') | :<line1>,<line2>call transform#InsertSpaceCmd() | call setpos('.', s:pos)
command -range=% Han2zen     let s:pos = getpos('.') | :<line1>,<line2>call transform#Han2zenCmd()     | call setpos('.', s:pos)
command -range=% Hira2kata   let s:pos = getpos('.') | :<line1>,<line2>call transform#Hira2kataCmd()   | call setpos('.', s:pos)
command -range=% Kata2hira   let s:pos = getpos('.') | :<line1>,<line2>call transform#Kata2hiraCmd()   | call setpos('.', s:pos)
command          Base64      let s:pos = getpos('.') |                :call transform#Base64Cmd()      | call setpos('.', s:pos)

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
