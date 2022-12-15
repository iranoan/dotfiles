scriptencoding utf-8

if exists('g:manage_pack')
	finish
endif
let g:manage_pack = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

command -complete=customlist,manage_pack#CompPackList -nargs=+ ReinstallPackadd call manage_pack#Reinstall(<f-args>)
" ↓引数を補完もいないので、コマンドにしない
" command InstallPackadd call manage_pack#Install()
" command MakeHelpTats call manage_pack#Helptags()

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
