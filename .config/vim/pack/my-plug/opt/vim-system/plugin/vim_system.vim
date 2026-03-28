vim9script

if exists('g:vim_system')
	finish
endif
g:vim_system = 1

command VimSystem      vim_system#VimWrite()
command VimSystemEcho  vim_system#VimEcho()
command GVimSystem     vim_system#GVimWrite()
command GVimSystemEcho vim_system#GVimEcho()
command System         vim_system#EnvWrite()
command SystemEcho     vim_system#EnvEcho()
