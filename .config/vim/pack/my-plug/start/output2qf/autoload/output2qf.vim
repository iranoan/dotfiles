vim9script
scriptencoding utf-8

export def Shell2qf(...ls: list<string>): void
	var ret: list<string> = systemlist(join(ls, ' '))->map('v:val .. ":1: "')
	if len(ret) == 0
		echohl WarningMsg
		echo 'Empty Result'
		echohl None
		return
	endif
	cexpr join(ret, "\n")
	copen
enddef
