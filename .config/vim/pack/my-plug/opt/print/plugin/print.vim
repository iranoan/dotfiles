vim9script
scriptencoding utf-8

if exists('g:loaded_print')
	finish
endif

command! -range=% PrintBuffer call print#Main(<line1>, <line2>)
