augroup InsertStatus
	autocmd!
	autocmd InsertEnter * call insert_status#Main('Enter')
	autocmd InsertLeave * call insert_status#Main('Leave')
augroup END
