scriptencoding utf-8

function set_easymotion#main(cmd) abort
	let g:EasyMotion_smartcase = 1   " 検索による移動で大文字小文字の区別をしない
	let g:EasyMotion_use_migemo = 1  " 検索による移動でローマ字入力も移動対象にする
	call pack_manage#SetMAP('vim-easymotion', a:cmd, [
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
				\ {'mode': 'x', 'key': '<Leader><Leader>f',  'cmd': '(easymotion-f)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>F',  'cmd': '(easymotion-F)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>t',  'cmd': '(easymotion-t)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>T',  'cmd': '(easymotion-T)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>w',  'cmd': '(easymotion-w)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>W',  'cmd': '(easymotion-W)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>b',  'cmd': '(easymotion-b)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>B',  'cmd': '(easymotion-B)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>e',  'cmd': '(easymotion-e)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>E',  'cmd': '(easymotion-E)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>ge', 'cmd': '(easymotion-ge)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>gE', 'cmd': '(easymotion-gE)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>j',  'cmd': '(easymotion-j)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>k',  'cmd': '(easymotion-k)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>n',  'cmd': '(easymotion-n)'},
				\ {'mode': 'x', 'key': '<Leader><Leader>N',  'cmd': '(easymotion-N)'}
				\ ] )
endfunction
