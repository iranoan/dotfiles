vim9script
# $B%]%C%W%"%C%W$7$F$$$k$H$-$NF~NO(B

def pumvisible#insert(str: string): string
	echomsg 1
	if pumvisible()
		asyncomplete#close_popup()
		return "\n\n" .. str # $B$I$&$d$i(B1$B$DL\$N(B \n $B$,3NDj$N07$$(B
	endif
	return (getline('.') =~# '^\s*$' ?  '' : "\n") .. str
enddef

def pumvisible#insert_after(str: string): string
	if pumvisible()
		asyncomplete#close_popup()
		return "\n" .. str .. "\n"
	endif
	return str .. "\n"
enddef
