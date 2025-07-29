scriptencoding utf-8

function set_fzf_tabs#main(cmd) abort
	if !pack_manage#IsInstalled('fzf.vim')
		call set_fzf_vim#main('')
		delfunction set_fzf_vim#main
	endif
	let g:fzf_tabs_options = ['--preview', '~/bin/fzf-preview.sh {2}']
	call pack_manage#SetMAP('fzf-tabs', a:cmd, [
				\ #{mode: 'n', key: '<Leader>ft', method: 1, cmd: 'FZFTabOpen'},
				\ #{mode: 'v', key: '<Leader>ft', method: 1, cmd: 'FZFTabOpen'},
				\ #{mode: 'n', key: '<Leader>fb', method: 1, cmd: 'FZFTabOpen'},
				\ #{mode: 'n', key: '<Leader>fw', method: 1, cmd: 'FZFTabOpen'},
				\ ])
endfunction
