vim9script

if exists('g:fullscreen')
	finish
endif
g:fullscreen = 1

command Fullscreen fullscreen#Main()
