scriptencoding utf-8

function set_page_down#main() abort
	nnoremap <silent><space> <Cmd>call page_down#Main()<CR>
	packadd page-down
	call page_down#Main()
endfunction
