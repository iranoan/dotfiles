vim9script
scriptencoding utf-8

export def Shell2qf(...ls: list<string>): void
	var ret: list<string> = systemlist(join(ls, ' ') .. '| sed "s/$/:1:1/"')
	if len(ret) == 0
		echohl WarningMsg
		echo 'Empty Result'
		echohl None
		return
	endif
	cgetexpr join(ret, "\n")
	copen
enddef
