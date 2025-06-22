scriptencoding utf-8

function set_undotree#main() abort
	packadd undotree
	let g:undotree_CustomUndotreeCmd  = 'vertical 30 new'
	let g:undotree_CustomDiffpanelCmd = 'botright 10 new'
	augroup UndoTreeStatus
		autocmd!
		autocmd FileType undotree setlocal statusline=%#StatusLineLeft#%{t:undotree.GetStatusLine()}
	augroup END
endfunction
