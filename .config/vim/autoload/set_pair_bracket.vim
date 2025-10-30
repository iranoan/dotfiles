scriptencoding utf-8

function set_pair_bracket#main()
	let g:pairbracket = {
				\ 	'(': #{pair: ')', space: 1, escape: #{tex: 2, vim: 1}, search: {'v\': 0, '\': 2, 'v': 1, '_': 0}},
				\ 	'[': #{pair: ']', space: 1, escape: #{tex: 2, vim: 1},
				\ 		search: {'v\': 0, '\': 0, 'v': 1, '_': 1}},
				\ 	'{': #{pair: '}', space: 1, escape: #{tex: 2, vim: 1},
				\ 		search: {'v\': 0, '\': 1, 'v': 1, '_': 0}},
				\ 	'<': #{pair: '>', space: 1, type: ['tex'], cmap: 0},
				\ 	'/*': #{pair: '*/', space: 1, type: ['c', 'cpp', 'css'], cmap: 0},
				\ 	'「': #{pair: '」'},
				\ 	'『': #{pair: '』'},
				\ 	'【': #{pair: '】'},
				\ }
	let g:pairquote = {
				\ 	'"': {},
				\ 	'''': {},
				\ 	'`': {},
				\ 	'$': #{type: ['tex']},
				\ 	'*': #{type: ['help', 'markdown'], cmap: 0},
				\ 	'|': #{type: ['help'],             cmap: 0},
				\ 	'_': #{type: ['markdown'],         cmap: 0},
				\ 	'~': #{type: ['markdown'],         cmap: 0},
				\ 	'^': #{type: ['markdown'],         cmap: 0},
				\ }
		" ↑
		" 'help', 'markdown 'tag と強調
		" 'help' 'link
		" markdown 強調
		" markdown 下付き添字
		" markdown 上付き添字
		" ↓ ', " 自体の反応が遅くなる
		" "'''": {},
		" '"""': {},
	packadd pair_bracket
	call timer_start(1, {->execute('delfunction set_pair_bracket#main')})
endfunction
