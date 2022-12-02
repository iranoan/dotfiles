let g:hi_insert = get(g:, 'hi_insert', 'highlight ' .. substitute(substitute(execute('highlight StatusLine'), '[\n\r \t]\+', ' ', 'g'), 'xxx', '', ''))
augroup InsertStatus
	autocmd!
	autocmd InsertEnter * call insert_status#Main('Enter')
	autocmd InsertLeave * call insert_status#Main('Leave')
augroup END
