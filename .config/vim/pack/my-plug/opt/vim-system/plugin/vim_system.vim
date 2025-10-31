vim9script

if exists('g:vim_system')
	finish
endif
g:vim_system = 1

command VimSystem     vim_system#Write()
command VimSystemEcho vim_system#Echo()
command System        vim_system#EnvWrite()
command SystemEcho    vim_system#EnvEcho()
