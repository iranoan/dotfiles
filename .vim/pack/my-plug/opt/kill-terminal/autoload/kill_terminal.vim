vim9script
# カレント・タブ・ページ内にじターミナルが有れば、既存のターミナルを残し、新たに開いたターミナルは閉じる
# 欠点
# :terminal +{cmd}
# をしても、そのウィンドウを閉じてしまう

export def Main(): void
	var bufnum: number = bufnr('') # カレント・バッファ (直前に開いたターミナルを想定)
	var terms: list<number> = term_list()
	var terms_in_tab: list<number>
	for buf in tabpagebuflist() # タブ・ページ内のバッファからターミナルを探す
		if match(terms, '^' .. buf .. '$') >= 0
			add(terms_in_tab, buf)
		endif
	endfor
	if match(terms_in_tab, '^' .. bufnum .. '$') == -1 # 現在のバッファが(カレント・タブページの)ターミナルではない
		return
	endif
	if len(terms_in_tab) == 1 # ターミナルが一つ
		for buf in terms
			if getbufinfo(buf)[0]['hidden'] # 隠れバッファのターミナルが有ればそれを開く
				execute 'split +' .. buf .. 'buffer'
				execute 'bwipeout! ' .. bufnum
				return
			endif
		endfor
		return
	endif
	execute 'bwipeout! ' .. bufnum
	terms_in_tab = filter(terms_in_tab, 'v:key != ' .. bufnum)
	win_gotoid(bufwinid(terms_in_tab[0]))
enddef
