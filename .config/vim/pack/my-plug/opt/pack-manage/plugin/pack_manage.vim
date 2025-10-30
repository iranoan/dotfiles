vim9script

if exists('g:pack_manage')
	finish
endif
g:pack_manage = 1

command -complete=customlist,pack_manage#CompPack -nargs=* PackManage call pack_manage#PackManage(<f-args>)
