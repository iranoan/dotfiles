vim9script
scriptencoding utf-8

export def CloseQf(): void # QuickFix/LocationList だけのときは閉じる
	var wins: list<any> = gettabinfo(tabpagenr())[0].windows->map((_, v) => getwininfo(v)[0])
	if empty(wins) || len(wins) != 1
		return
	endif
	var target = wins[0]
	if target.quickfix == 1 || target.loclist == 1
		if tabpagenr('$') == 1
			quit
		else
			execute 'bwipeout ' .. target.bufnr
		endif
	endif
enddef
