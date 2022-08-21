augroup InsertStatus
	autocmd!
	autocmd InsertEnter * call insert_status#main('Enter')
	autocmd InsertLeave * call insert_status#main('Leave')
augroup END
