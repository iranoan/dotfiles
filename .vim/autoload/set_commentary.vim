scriptencoding utf-8

function set_commentary#main(cmd) abort
	call set_map_plug#main('vim-commentary', a:cmd, [
				\ {'mode': 'n', 'key': 'gcu', 'cmd': 'Commentary<Plug>Commentary'},
				\ {'mode': 'n', 'key': 'gcc', 'cmd': 'CommentaryLine'},
				\ {'mode': 'o', 'key': 'gc',  'cmd': 'Commentary'},
				\ {'mode': 'n', 'key': 'gc',  'cmd': 'Commentary'},
				\ {'mode': 'x', 'key': 'gc',  'cmd': 'Commentary'}
				\ ] )
endfunction
