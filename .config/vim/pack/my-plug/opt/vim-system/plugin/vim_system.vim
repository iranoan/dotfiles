vim9script

if exists('g:transform')
	finish
endif
g:transform = 1

command VimSystem     vim_system#Write()
command VimSystemEcho vim_system#Echo()
command System        vim_system#EnvWrite()
command SystemEcho    vim_system#EnvEcho()
