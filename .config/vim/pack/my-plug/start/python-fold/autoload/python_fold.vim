vim9script
scriptencoding utf-8
# Python の foldexpr 用関数

export def Fold(): any
	var line: string = getline(v:lnum)
	var next: string = getline(v:lnum + 1)
	var indent_cur: number
	var indent_pre: number
	var indent_next: number
	# if line ==? '' && getline(v:lnum + 1) ==? '' # 連続する空行はトップに含める
	if line ==? '' # 空行は一つ前のレベル
		return '='
	elseif match(line, '^#\s\?\(def\s\+\w\+([^)]*)\|class\s\+\w\+\):') != -1  # コメント化されたクラス/関数はトップ扱い
		return '>1'
	endif
	# 以下インデントの深さ
	indent_cur = indent(v:lnum) / &shiftwidth
	if v:lnum == 1
		indent_pre = 0
	elseif getline(v:lnum - 1) ==# ''
		return '>' .. (indent_cur + 1)
	else
		indent_pre = indent(nextnonblank(v:lnum - 1)) / &shiftwidth
	endif
	if indent_pre + 1 < indent_cur
		indent_cur = indent_pre + 1
	endif
	indent_next = indent(nextnonblank(v:lnum + 1)) / &shiftwidth
	if indent_next > indent_cur && line !~# '^\s*$'
		return '>' .. (indent_cur + 1)
	# 連続するコメント行
	elseif match(line, '^\s*#') != -1 # コメント行
		if v:lnum == 0
			if match(getline(v:lnum + 1), '^\s*#') != -1   # 次行もコメント行
				return '>1'
			else
				return '0'
			endif
		elseif match(getline(v:lnum - 1), '^\s*#') == -1 # 前行非コメント
			if match(next, '^\s*#') != -1              # 次行コメント行
				return '>' .. (indent_cur + 1)                  # コメントの始まり
			else                                         # 次行非コメント行
				return '<' .. (indent_cur + 1)
			endif
		else                                           # 前行コメント
			if match(next, '^\s*#') == -1              # 次行非コメント行
				return '<' .. (indent_cur + 1)
			endif
			return '='
		endif
	elseif indent_cur != 0
		if indent_pre == indent_cur
			return '='
		endif
		return indent_cur
	else
		return 0
	endif
enddef

