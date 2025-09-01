scriptencoding utf-8

function set_undotree#main() abort
	nnoremap <silent><Leader>u <Cmd>UndotreeToggle<CR>
	packadd undotree
	let g:undotree_CustomUndotreeCmd  = 'vertical 30 new'
	let g:undotree_CustomDiffpanelCmd = 'botright 10 new'
	execute('UndotreeToggle')
	augroup UndoTreeStatus
		autocmd!
		autocmd FileType undotree setlocal statusline=%#StatusLineLeft#%{t:undotree.GetStatusLine()}
	augroup END
	call timer_start(1, {->execute('delfunction set_undotree#main')})
endfunction
