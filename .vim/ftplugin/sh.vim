"�V�F���X�N���v�g�p�̐ݒ�
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

"--------------------------------
"�t�@�C���^�C�v�ʂ̃O���[�o���ݒ�
"--------------------------------
if !exists('g:is_bash')
	let g:sh_fold_enabled=7
	let g:is_bash=1
endif
" if !exists('g:sh_plugin')
" 	let g:sh_plugin = 1
" 	" augroup mySh
" 	" 	autocmd!
" 	" augroup END
" endif
"--------------------------------
"�t�@�C���^�C�v�ʃ��[�J���ݒ�
"--------------------------------
setlocal foldmethod=syntax
" �w���v
" setlocal keywordprg=man
