scriptencoding utf-8

function set_page_down#main() abort
	nnoremap <silent><space> <Cmd>call page_down#Main()<CR>
	packadd page-down
	call page_down#Main()
	call timer_start(1, {->execute('delfunction set_page_down#main')})
endfunction
