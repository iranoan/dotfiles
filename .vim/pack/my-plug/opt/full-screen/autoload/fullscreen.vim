vim9script
# Linux では wmctrl を使ってフル・スクリーンをトグル
# →$ sudo apt install wmctrl

scriptencoding utf-8

export def Main(): void
	if !has('gui_running')
		echohl WarningMsg | echo "Don't GUI Running!" | echohl None
		return
	elseif !executable('wmctrl')
		echohl WarningMsg | echo "Don't execute wmctrl!" | echohl None
		return
	endif
	var win = bufnr('')
	if has('unix')
		var wmctrl: string = (matchstrlist(systemlist('wmctrl -lp'), '^\(\c0x[0-9a-f]\+\) \+\(-1\|\d\+\) \+' .. getpid(), {submatches: true})[0].submatches)[0]
		system('wmctrl -ir ' .. wmctrl .. ' -b toggle,fullscreen')
	# elseif has('win32') || has('win32unix')
	# 	simalt ~x
	endif
	windo redraw | redrawstatus
	win_gotoid(bufwinid(win))
enddef
