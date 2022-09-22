vim9script
# ポップアップしているときの入力

def pumvisible#insert(str: string): string
	echomsg 1
	if pumvisible()
		asyncomplete#close_popup()
		return "\n\n" .. str # どうやら1つ目の \n が確定の扱い
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
