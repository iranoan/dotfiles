vim9script

if exists("b:current_syntax")
	finish
endif

syntax clear
syntax case ignore

syntax match manConceal     contained conceal /\e\[\(\d*;\)*\d*[A-Za-z]/
syntax match manSuppress              conceal /\e\[[0-9;]*[A-Za-z]/
syntax match manSuppress              conceal /\e\[?\d*[A-Za-z]/

# syntax region manNone       start=/\e\[0m/  skip=/\e\[K/ end=/\e\[/me=e-2 contains=manConceal
# syntax region manNone       start=/\e\[22m/ skip=/\e\[K/ end=/\e\[/me=e-2 contains=manConceal
# syntax region manNone       start=/\e\[24m/ skip=/\e\[K/ end=/\e\[/me=e-2 contains=manConceal

syntax region manBold       start=/\e\[1m/  skip=/\e\[K/ end=/\ze\(\e\[\d\+m\)*\e\[22m/ end=/\ze\(\e\[\d\+m\)*\e\[0m/ contains=manConceal,manHeader
syntax region manUnderline  start=/\e\[4m/  skip=/\e\[K/ end=/\ze\(\e\[\d\+m\)*\e\[24m/ end=/\ze\(\e\[\d\+m\)*\e\[0m/ contains=manConceal,manHeader
# --option=value の value 部分だけ色を別にすることは可能だが、説明部分と色が異なることになる
# syntax region manBold2      start=/\e\[1m\e\[24m/  skip=/\e\[K/ end=/\ze\e\[22m/ end=/\ze\(\e\[\d\+m\)*\e\[0m/ contains=manConceal
# syntax region manBold2      start=/\e\[24m\e\[1m/  skip=/\e\[K/ end=/\ze\e\[22m/ end=/\ze\(\e\[\d\+m\)*\e\[0m/ contains=manConceal
# syntax region manUnderline2 start=/\e\[4m\e\[22m/  skip=/\e\[K/ end=/\ze\e\[24m/ end=/\ze\(\e\[\d\+m\)*\e\[0m/ contains=manConceal
# syntax region manUnderline2 start=/\e\[22m\e\[4m/  skip=/\e\[K/ end=/\ze\e\[24m/ end=/\ze\(\e\[\d\+m\)*\e\[0m/ contains=manConceal

syntax region manSection    start=/^\s\{,4}\zs\e\[1m/ end=/\ze\e\[\(22\|0\)m$/ oneline contains=manConceal
# syntax region manHeader     start=/\%^\%(.*\n\)\{-}\zs\e\[\dm/ end=/$/ contains=manConceal
syntax region manHeader start=/^\e\[4m[A-Z0-9_:.+@-]\+\e\[24m(\d)/ end=/\e\[4m[A-Z0-9_:.+@-]\+\e\[24m(\d)/ oneline contains=manConceal
syntax match manFooter /^[^\s\e].\+\e\[4m[A-Z0-9_:.+@-]\+\e\[24m(\d)$/ contains=manConceal

syntax match manURL '\%(\<\%(\%(\%(https\=\|ftp\|gopher\)://\|\%(mailto\|file\|news\):\)[^'' \t<>"]\+\)[A-Za-z0-9/]\)' contains=@NoSpell
syntax match manEmail '[_=A-Za-z./+0-9-]\+@[A-Za-z0-9._-]\+\.\a\{2,3}' contains=@NoSpell

highlight! link manBold Special
highlight! link manUnderline Function
# highlight! link manBold2 Constant
# highlight! link manUnderline2 Type
highlight! link manNone Normal
hlset([
	hlget('Title')[0]->extend({name: 'manSection', font: '', tterm: {bold: true, underline: true}, cterm: {bold: true, underline: true}, gui: {bold: true, underline: true}}),
	hlget('Title')[0]->extend({name: 'manHeader', font: '', term: {bold: true, reverse: true}, cterm: {bold: true, reverse: true}, gui: {bold: true, reverse: true}}),
	hlget('Directory')[0]->extend({name: 'manURL', font: '', term: {underline: true}, cterm: {underline: true}, gui: {underline: true}}),
	hlget('Constant')[0]->extend({name: 'manEmail', font: '', term: {underline: true}, cterm: {underline: true}, gui: {underline: true}})
])
highlight! link manFooter PreProc

b:current_syntax = 1
