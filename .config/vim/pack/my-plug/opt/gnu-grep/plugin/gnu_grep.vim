vim9script
scriptencoding utf-8

command -nargs=1 -complete=customlist,gnu_grep#GrepComp -bang Grep     gnu_grep#Grep(true,  false, '<bang>', <q-args>)
command -nargs=1 -complete=customlist,gnu_grep#GrepComp -bang LGrep    gnu_grep#Grep(false, false, '<bang>', <q-args>)
command -nargs=1 -complete=customlist,gnu_grep#GrepComp -bang Grepadd  gnu_grep#Grep(true,  true,  '<bang>', <q-args>)
command -nargs=1 -complete=customlist,gnu_grep#GrepComp -bang LGrepadd gnu_grep#Grep(false, true,  '<bang>', <q-args>)
