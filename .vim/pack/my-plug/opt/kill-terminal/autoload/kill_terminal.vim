" カレント・タブ・ページ内にじターミナルが有れば、既存のターミナルを残し、新たに開いたターミナルは閉じる
" 欠点
" :terminal +{cmd}
" をしても、そのウィンドウを閉じてしまう

scriptencoding utf-8

function kill_terminal#main() abort
	let bufnum = bufnr('') " カレント・バッファ (直前に開いたターミナルを想定)
	let tabs = tabpagebuflist()
	let terms = term_list()
	let terms_in_tab = []
	for buf in tabs " タブ・ページ内のバッファからターミナルを探す
		if match(terms, buf) >= 0
			call add(terms_in_tab, buf)
		endif
	endfor
	if match(terms_in_tab, bufnum) == -1 " 現在のバッファが(カレント・タブページの)ターミナルではない
		return
	endif
	if len(terms_in_tab) == 1 " ターミナルが一つ
		for buf in terms
			if getbufinfo(buf)[0]['hidden'] " 隠れバッファのターミナルが有ればそれを開く
				execute 'split +' .. buf .. 'buffer'
				execute 'bwipeout! ' .. bufnum
				return
			endif
		endfor
		return
	endif
	execute 'bwipeout! ' .. bufnum
	let terms_in_tab = filter(terms_in_tab, 'v:key !=' . bufnum)
	call win_gotoid(bufwinid(terms_in_tab[0]))
endfunction
