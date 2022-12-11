scriptencoding utf-8
" https://github.com/t9md/vim-foldtext を元の折りたたみ行数の位置がずれる場合が有ることへの対処

if exists('g:foldtext')
	finish
endif
let g:foldtext = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

set foldtext=foldtext#base()

augroup FoldText
	autocmd!
	autocmd FileType tex setlocal foldtext=foldtext#latex()
	autocmd FileType cpp setlocal foldtext=foldtext#cpp()
	autocmd FileType perl setlocal foldtext=foldtext#perl()
augroup END

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
