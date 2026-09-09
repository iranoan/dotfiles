vim9script
scriptencoding utf-8

export def IsBinary(path: string): bool
	if getfperm(path) ==# ''
		if isdirectory(path)
			return true
		endif
		return false # 存在しないファイル→新規で Vim で開く可能性あり
	elseif !filereadable(path)
		return true
	elseif getfsize(path) == 0
		return false
	endif
	return index(readblob(path, 0, 8192), 0x00) != -1 # 一般的な先頭 8KB で判定方法を使う
enddef

export def ExtendNew(o: any, y: any, over: string = ''): any # extend() の拡張版
	var has_x: bool
	var has_y: bool
	var x: any = deepcopy(o)

	if (type(x) == 0 || type(x) == 1 || type(x) == 5 || type(x) == 6) # 両方、数、文字列、真偽値
	&& (type(y) == 0 || type(y) == 1 || type(y) == 5 || type(y) == 6)
		return y
	elseif ( # 一方、数、文字列、真偽値、もう一方がリスト
			type(x) == 3
			&& (type(y) == 0 || type(y) == 1 || type(y) == 5 || type(y) == 6)
		)
		return x + [y]
	elseif (
			(type(x) == 0 || type(x) == 1 || type(x) == 5 || type(x) == 6)
			&& type(y) == 3
		)
		return [x] + y
	elseif type(x) == 3 && type(y) == 3 # 両方リスト
		if x == y
			return x
		endif
		return x + y
	elseif type(x) != 4 || type(y) != 4 # 少なくとも一方は辞書でない
		echohl WarningMsg
		echo 'Support Only Number/String/List/Dictionary/Float/Boolean'
		echohl None
		return x
	endif
	for k in sort(keys(x) + keys(y))->uniq()
		has_x = has_key(x, k)
		has_y = has_key(y, k)
		if k ==# over
			x[k] = y[k]
		elseif has_x && has_y
			x[k] = ExtendNew(x[k], y[k], over)
		elseif has_y
			x[k] = y[k]
		endif
	endfor
	return x
enddef
