vim9script
scriptencoding utf-8
# ポップアップしているときの入力
# どうやら1つ目の \n が確定の扱いになる

def pumvisible#insert(str: string): string # str 入力前に改行
	if pumvisible()
		asyncomplete#close_popup()
		return "\n\n" .. str
	endif
	return (getline('.') =~# '^\s*$' ?  '' : "\n") .. str
enddef

def pumvisible#insert_after(str: string): string # str 入力後に改行
	if pumvisible()
		asyncomplete#close_popup()
		return "\n" .. str .. "\n"
	endif
	return str .. "\n"
enddef
