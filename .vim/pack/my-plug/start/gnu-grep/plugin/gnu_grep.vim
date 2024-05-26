vim9script
scriptencoding utf-8

command -nargs=+ -complete=customlist,gnu_grep#GrepComp Grep call gnu_grep#Grep(<q-args>)
command -nargs=+ -complete=customlist,gnu_grep#GrepComp LGrep call gnu_grep#Lgrep(<q-args>)
