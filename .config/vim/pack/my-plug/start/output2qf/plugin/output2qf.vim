command! -nargs=+ -complete=file Shell2Qf call output2qf#Shell(<f-args>)
command! -nargs=0 Vim2Qf                   call output2qf#Vim()
