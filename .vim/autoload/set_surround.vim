scriptencoding utf-8

function set_surround#main(cmd) abort
	call set_map_plug#main('vim-surround', a:cmd, [
				\ {'mode': 'x', 'key': 's',   'cmd': 'VSurround'},
				\ {'mode': 'n', 'key': 'ysS', 'cmd': 'YSsurround'},
				\ {'mode': 'n', 'key': 'yss', 'cmd': 'Yssurround'},
				\ {'mode': 'n', 'key': 'yS',  'cmd': 'YSurround'},
				\ {'mode': 'n', 'key': 'ys',  'cmd': 'Ysurround'},
				\ {'mode': 'n', 'key': 'cS',  'cmd': 'CSurround'},
				\ {'mode': 'n', 'key': 'cs',  'cmd': 'Csurround'},
				\ {'mode': 'n', 'key': 'ds',  'cmd': 'Dsurround'},
				\ {'mode': 'x', 'key': 'gS',  'cmd': 'VgSurround'}
				\ ] )
	" 全角への対応 (ただしできるのは追加のみ)
	let g:surround_{char2nr('「')} = "「\r」"
	let g:surround_{char2nr('」')} = "「\r」"
	let g:surround_{char2nr('『')} = "『\r』"
	let g:surround_{char2nr('』')} = "『\r』"
	" 標準の S など一部を削除し小文字の s にもマップ(キー割り当て)
	xunmap S
	nunmap ySS
	nunmap ySs
endfunction
