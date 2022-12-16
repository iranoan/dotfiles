vim9script

if exists('g:manage_pack')
	finish
endif
g:manage_pack = 1

command -complete=customlist,manage_pack#CompPackList -nargs=+ ReinstallPack call manage_pack#Reinstall(<f-args>)
