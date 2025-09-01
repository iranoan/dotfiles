scriptencoding utf-8

function! set_tabedit#main() abort
	packadd tabedit
	let g:tabedit_dir = ['set_fern#FernSync', v:true]
	if !pack_manage#IsInstalled('fern.vim')
		call set_fern#main()
		autocmd! SetFernSync
		augroup! SetFernSync
	endif
	call timer_start(1, {->execute('delfunction set_tabedit#main')})
endfunction
