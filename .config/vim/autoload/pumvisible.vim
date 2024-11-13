vim9script
scriptencoding utf-8
# ポップアップしているときの入力
# 1つ目の \n が確定の扱いになる
# completeopt に noinsert を含まない時は、おそらく意図しない動きになる

export def Insert(str: string): string # str 入力前に改行
	if pumvisible()
		asyncomplete#close_popup()
		return "\n\n" .. str
	endif
	return (getline('.') =~# '^\s*$' ?  '' : "\n") .. str
enddef

export def Insert_after(str: string): string # str 入力後に改行
	if pumvisible()
		asyncomplete#close_popup()
		return "\n" .. str .. "\n"
	endif
	return str .. "\n"
enddef
