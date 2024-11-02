vim9script
scriptencoding utf-8

command -nargs=+ -complete=customlist,gnu_grep#GrepComp Grep     gnu_grep#Grep(true,  false, <q-args>)
command -nargs=+ -complete=customlist,gnu_grep#GrepComp LGrep    gnu_grep#Grep(false, false, <q-args>)
command -nargs=+ -complete=customlist,gnu_grep#GrepComp Grepadd  gnu_grep#Grep(true,  true,  <q-args>)
command -nargs=+ -complete=customlist,gnu_grep#GrepComp LGrepadd gnu_grep#Grep(false, true,  <q-args>)
