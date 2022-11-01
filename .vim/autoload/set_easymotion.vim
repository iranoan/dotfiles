scriptencoding utf-8

function set_easymotion#main(cmd) abort
	let g:EasyMotion_smartcase = 1   " 検索による移動で大文字小文字の区別をしない
	let g:EasyMotion_use_migemo = 1  " 検索による移動でローマ字入力も移動対象にする
	call set_map_plug#Main('vim-easymotion', a:cmd, [
				\ {'mode': 'n', 'key': '<Leader><Leader>f',  'cmd': '(easymotion-f)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>F',  'cmd': '(easymotion-F)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>t',  'cmd': '(easymotion-t)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>T',  'cmd': '(easymotion-T)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>w',  'cmd': '(easymotion-w)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>W',  'cmd': '(easymotion-W)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>b',  'cmd': '(easymotion-b)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>B',  'cmd': '(easymotion-B)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>e',  'cmd': '(easymotion-e)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>E',  'cmd': '(easymotion-E)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>ge', 'cmd': '(easymotion-ge)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>gE', 'cmd': '(easymotion-gE)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>j',  'cmd': '(easymotion-j)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>k',  'cmd': '(easymotion-k)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>n',  'cmd': '(easymotion-n)'},
				\ {'mode': 'n', 'key': '<Leader><Leader>N',  'cmd': '(easymotion-N)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>f',  'cmd': '(easymotion-f)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>F',  'cmd': '(easymotion-F)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>t',  'cmd': '(easymotion-t)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>T',  'cmd': '(easymotion-T)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>w',  'cmd': '(easymotion-w)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>W',  'cmd': '(easymotion-W)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>b',  'cmd': '(easymotion-b)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>B',  'cmd': '(easymotion-B)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>e',  'cmd': '(easymotion-e)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>E',  'cmd': '(easymotion-E)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>ge', 'cmd': '(easymotion-ge)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>gE', 'cmd': '(easymotion-gE)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>j',  'cmd': '(easymotion-j)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>k',  'cmd': '(easymotion-k)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>n',  'cmd': '(easymotion-n)'},
				\ {'mode': 'v', 'key': '<Leader><Leader>N',  'cmd': '(easymotion-N)'}
				\ ] )
endfunction
