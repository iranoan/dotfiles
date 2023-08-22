if exists('g:insert_status')
	finish
endif
let g:insert_status = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

let g:hi_insert = get(g:, 'hi_insert', 'highlight ' .. substitute(substitute(execute('highlight StatusLine'), '[\r\n]', '', 'g'), 'xxx', '', ''))
augroup InsertStatus
	autocmd!
	autocmd InsertEnter * call insert_status#Main('Enter')
	autocmd InsertLeave * call insert_status#Main('Leave')
augroup END

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
