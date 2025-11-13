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

syntax match manURL '\(\<\(\(\(https\=\|ftp\|gopher\)://\|\(mailto\|file\|news\):\)[^'' \t<>"]\+\|\(www\|web\|w3\)[a-z0-9_-]*\.[a-z0-9._-]\+\.[!#-&*-;=?-Z\\^-z|~]\+\)[a-z0-9/]\)' contains=@NoSpell

highlight! default link manBold Special
highlight! default link manUnderline Function
# highlight! default link manBold2 Constant
# highlight! default link manUnderline2 Type
highlight! default link manNone Normal
hlset(
	hlget('Title')->map((_, v) => v->extend({name: 'manSection', cterm: {bold: true, underline: true}, gui: {bold: true, underline: true}}))
	+ hlget('Directory')->map((_, v) => v->extend({name: 'manURL', cterm: {underline: true}, gui: {underline: true}})))
highlight! default link manHeader Statusline
highlight! default link manFooter PreProc

b:current_syntax = 1
