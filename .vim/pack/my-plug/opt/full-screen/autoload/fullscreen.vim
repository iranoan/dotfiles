vim9script
# Linux では wmctrl を使ってフル・スクリーンをトグル
# →$ sudo apt install wmctrl

scriptencoding utf-8

def fullscreen#main(): void
	if !has('gui_running')
		echohl WarningMsg | echo "Don't GUI Running!" | echohl None
		return
	elseif !executable('wmctrl')
		echohl WarningMsg | echo "Don't execute wmctrl!" | echohl None
		return
	endif
	var win = bufnr('')
	if has('unix')
		var wmctrl = system('wmctrl -lp')
		wmctrl = matchstr(wmctrl, '\m\C0x[0-9a-fA-F]\+ \+[0-9-]\+ \+' .. getpid())
		wmctrl = matchstr(wmctrl, '\m\C0x[0-9a-fA-F]\+')
		system('wmctrl -ir ' .. wmctrl .. ' -b toggle,fullscreen')
	# elseif has('win32') || has('win32unix')
	# 	simalt ~x
	endif
	windo redraw | redrawstatus
	win_gotoid(bufwinid(win))
enddef
