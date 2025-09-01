scriptencoding utf-8

function set_commentary#main(cmd) abort
	call pack_manage#SetMAP('vim-commentary', a:cmd, [
				\ #{mode: 'n', key: 'gcu', cmd: 'Commentary<Plug>Commentary'},
				\ #{mode: 'n', key: 'gcc', cmd: 'CommentaryLine'},
				\ #{mode: 'o', key: 'gc',  cmd: 'Commentary'},
				\ #{mode: 'n', key: 'gc',  cmd: 'Commentary'},
				\ #{mode: 'x', key: 'gc',  cmd: 'Commentary'}
				\ ] )
	call timer_start(1, {->execute('delfunction set_commentary#main')})
endfunction
