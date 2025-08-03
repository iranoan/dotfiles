scriptencoding utf-8

function set_surround#main(cmd) abort
	" カッコ以外に次のアルファベットが使える
	" ) b
	" } B
	" ] r
	" > a
	" 標準の S など一部を削除し小文字の s にマップ (元々 v_c, v_s はダブっている)
	" S は前後改行
	call pack_manage#SetMAP('vim-surround', a:cmd, [
				\ #{mode: 'x', key: 's',   cmd: 'VSurround'},
				\ #{mode: 'n', key: 'ysS', cmd: 'YSsurround'},
				\ #{mode: 'n', key: 'yss', cmd: 'Yssurround'},
				\ #{mode: 'n', key: 'yS',  cmd: 'YSurround'},
				\ #{mode: 'n', key: 'ys',  cmd: 'Ysurround'},
				\ #{mode: 'n', key: 'cS',  cmd: 'CSurround'},
				\ #{mode: 'n', key: 'cs',  cmd: 'Csurround'},
				\ #{mode: 'n', key: 'ds',  cmd: 'Dsurround'},
				\ #{mode: 'x', key: 'gS',  cmd: 'VgSurround'}
				\ ] )
	" 使用する記号の追加 (ただしできるのは追加のみ)
	" 全角
	let g:surround_{char2nr('「')} = "「\r」"
	let g:surround_{char2nr('」')} = "「\r」"
	let g:surround_{char2nr('『')} = "『\r』"
	let g:surround_{char2nr('』')} = "『\r』"
	" 数字や一部の記号を置き換え
	let g:surround_44 = "< \r >" " ,→<
	let g:surround_46 = "<\r>"   " .→>
	let g:surround_50 = "\"\r\"" " 2→"
	let g:surround_55 = "'\r'"   " @→'
	let g:surround_56 = "( \r )" " 8→(
	let g:surround_57 = "(\r)"   " 9→)
	let g:surround_64 = "`\r`"   " @→`
	" let g:surround_99 = "{\r}"   " c→}
	xunmap S
	nunmap ySS
	nunmap ySs
	" <Shift> を押すのが面倒
	for [n, q] in items({ 2: '"', 7: "'", 8: '(', 9: ')', '@': '`', ',': '<', '.': '>'})
		execute 'nmap ds' .. n .. ' ds' .. q
		execute 'nmap ys$' .. n .. ' ys$' .. q
		execute 'nmap ys4' .. n .. ' ys$' .. q
		execute 'nmap ys4' .. q .. ' ys$' .. q
	endfor
	for [n1, q1] in items({ 2: '"', 7: "'", 8: '(', 9: ')', '@': '`', ',': '<', '.': '>', '"': '"', "'": "'", '(': '(', ')': ')', '`': '`', '<': '<', '>': '>', '[': '[', ']': ']', '{': '{', '}': '}' })
		for [n2, q2] in items({ 2: '"', 7: "'", 8: '(', 9: ')', '@': '`', ',': '<', '.': '>', '"': '"', "'": "'", '(': '(', ')': ')', '`': '`', '<': '<', '>': '>', '[': '[', ']': ']', '{': '{', '}': '}' })
			execute 'nmap ysi' .. n1 .. n2 .. ' ysi' .. q1 .. q2
			execute 'nmap ysa' .. n1 .. n2 .. ' ysa' .. q1 .. q2
			if n1 !=# n2 && q1 !=# q2 && n1 !=# q2 && q1 !=# n2
				execute 'nmap cs'  .. n1 .. n2 .. ' cs'  .. q1 .. q2
			endif
		endfor
	endfor
endfunction
