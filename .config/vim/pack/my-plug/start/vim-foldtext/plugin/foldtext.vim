vim9script
scriptencoding utf-8
# https://github.com/t9md/vim-foldtext を元の折りたたみ行数の位置がずれる場合が有ることへの対処

if exists('g:foldtext')
	finish
endif
g:foldtext = 1

set foldtext=foldtext#Base()

augroup FoldText
	autocmd!
	autocmd FileType tex setlocal foldtext=foldtext#LaTeX()
	autocmd FileType cpp setlocal foldtext=foldtext#Cpp()
	autocmd FileType perl setlocal foldtext=foldtext#Perl()
augroup END
