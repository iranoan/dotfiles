vim9script

if exists('g:syntax_info')
	finish
endif
g:syntax_info = 1

command! SyntaxInfo syntax_info#Main()
