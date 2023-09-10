function set_vim_tex_fold#main() abort
	packadd vim-tex-fold
	let g:tex_fold_additional_envs = ['itemize', 'description', 'enumerate', 'center', 'gather', 'minipage']
	" To disable matching environments at all set: >
	" let g:tex_fold_ignore_envs = 1
endfunction
