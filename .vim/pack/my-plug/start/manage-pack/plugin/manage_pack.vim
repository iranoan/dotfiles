scriptencoding utf-8

command -complete=customlist,manage_pack#CompPackList -nargs=+ ReinstallPackadd call manage_pack#Reinstall(<f-args>)
" ↓引数を補完もいないので、コマンドにしない
" command -complete=customlist,manage_pack#CompPackList          InstallPackadd   call manage_pack#Install()
" command                                                        MakeHelpTats     call manage_pack#Helptags()
