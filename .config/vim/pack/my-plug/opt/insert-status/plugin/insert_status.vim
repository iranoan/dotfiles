vim9script

if exists('g:insert_status')
	finish
endif
g:insert_status = 1

g:hi_insert = get(g:, 'hi_insert', hlget('WarningMsg')->map((_, v) => v->extend({name: 'StatusLine', term: {bold: true, reverse: true}, cterm: {bold: true, reverse: true}, gui: {bold: true, reverse: true}})))

augroup InsertStatus
	autocmd!
	autocmd InsertEnter * insert_status#Main('Enter')
	autocmd InsertLeave * insert_status#Main('Leave')
augroup END
