vim9script

if exists('g:insert_status')
	finish
endif
g:insert_status = 1

g:hi_insert = get(g:, 'hi_insert', hlget('StatusLine'))

augroup InsertStatus
	autocmd!
	autocmd InsertEnter * insert_status#Main('Enter')
	autocmd InsertLeave * insert_status#Main('Leave')
augroup END
