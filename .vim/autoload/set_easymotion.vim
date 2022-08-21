scriptencoding utf-8

function set_easymotion#main(cmd) abort
	let g:EasyMotion_smartcase = 1   " 検索による移動で大文字小文字の区別をしない
	let g:EasyMotion_use_migemo = 1  " 検索による移動でローマ字入力も移動対象にする
	call set_map_plug#main('vim-easymotion', a:cmd, [
				\ {'mode': 'n', 'key': '<leader><leader>f',  'cmd': '(easymotion-f)'},
				\ {'mode': 'n', 'key': '<leader><leader>F',  'cmd': '(easymotion-F)'},
				\ {'mode': 'n', 'key': '<leader><leader>t',  'cmd': '(easymotion-t)'},
				\ {'mode': 'n', 'key': '<leader><leader>T',  'cmd': '(easymotion-T)'},
				\ {'mode': 'n', 'key': '<leader><leader>w',  'cmd': '(easymotion-w)'},
				\ {'mode': 'n', 'key': '<leader><leader>W',  'cmd': '(easymotion-W)'},
				\ {'mode': 'n', 'key': '<leader><leader>b',  'cmd': '(easymotion-b)'},
				\ {'mode': 'n', 'key': '<leader><leader>B',  'cmd': '(easymotion-B)'},
				\ {'mode': 'n', 'key': '<leader><leader>e',  'cmd': '(easymotion-e)'},
				\ {'mode': 'n', 'key': '<leader><leader>E',  'cmd': '(easymotion-E)'},
				\ {'mode': 'n', 'key': '<leader><leader>ge', 'cmd': '(easymotion-ge)'},
				\ {'mode': 'n', 'key': '<leader><leader>gE', 'cmd': '(easymotion-gE)'},
				\ {'mode': 'n', 'key': '<leader><leader>j',  'cmd': '(easymotion-j)'},
				\ {'mode': 'n', 'key': '<leader><leader>k',  'cmd': '(easymotion-k)'},
				\ {'mode': 'n', 'key': '<leader><leader>n',  'cmd': '(easymotion-n)'},
				\ {'mode': 'n', 'key': '<leader><leader>N',  'cmd': '(easymotion-N)'},
				\ {'mode': 'v', 'key': '<leader><leader>f',  'cmd': '(easymotion-f)'},
				\ {'mode': 'v', 'key': '<leader><leader>F',  'cmd': '(easymotion-F)'},
				\ {'mode': 'v', 'key': '<leader><leader>t',  'cmd': '(easymotion-t)'},
				\ {'mode': 'v', 'key': '<leader><leader>T',  'cmd': '(easymotion-T)'},
				\ {'mode': 'v', 'key': '<leader><leader>w',  'cmd': '(easymotion-w)'},
				\ {'mode': 'v', 'key': '<leader><leader>W',  'cmd': '(easymotion-W)'},
				\ {'mode': 'v', 'key': '<leader><leader>b',  'cmd': '(easymotion-b)'},
				\ {'mode': 'v', 'key': '<leader><leader>B',  'cmd': '(easymotion-B)'},
				\ {'mode': 'v', 'key': '<leader><leader>e',  'cmd': '(easymotion-e)'},
				\ {'mode': 'v', 'key': '<leader><leader>E',  'cmd': '(easymotion-E)'},
				\ {'mode': 'v', 'key': '<leader><leader>ge', 'cmd': '(easymotion-ge)'},
				\ {'mode': 'v', 'key': '<leader><leader>gE', 'cmd': '(easymotion-gE)'},
				\ {'mode': 'v', 'key': '<leader><leader>j',  'cmd': '(easymotion-j)'},
				\ {'mode': 'v', 'key': '<leader><leader>k',  'cmd': '(easymotion-k)'},
				\ {'mode': 'v', 'key': '<leader><leader>n',  'cmd': '(easymotion-n)'},
				\ {'mode': 'v', 'key': '<leader><leader>N',  'cmd': '(easymotion-N)'}
				\ ] )
endfunction
