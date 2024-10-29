vim9script
scriptencoding utf-8
# キーマップ用関数定義
def ItemInfo(line_s: string, le: number): dict<any> # 現在行と上に辿る形でline_sの長さよりインデント量が以下/より少なくなる行の情報を取得
	# le 1: 以下、0: より小さい
	var i: number = line('.') - 1
	var line_n: number = strlen(line_s)
	var item: list<string>
	var diff: number
	var info: dict<any> = {kind: 0, topTab: '', item: '', diff: line_s}
	# {
	# 	kind   箇条書き種類 (0: 箇条書きでない、2: 記号、3:番号 (1 は空き番で箇条書きではインデントに必要な量を種類番号と兼ねさせている)
	# 	topTab 行頭空白文字
	# 	item   行頭記号 (番号の場合も空文字)
	# 	diff   行頭空白文字と line_s との文字数差
	# }

	while true
		item = matchlist(getline(i), '^\(\s*\)\(\([*+-]\|\d\+\.\) \)\?')
		if item == []
			return info
		endif
		diff = line_n - strlen(item[1])
		if diff > le
			break
		endif
		i = i - 1
	endwhile
	info.topTab = item[1]
	info.diff = diff
	if item[2] =~# '^\d\+\. $'
		info.kind = 3
	else
		info.kind = 2
		info.item = item[2]
	endif
	return info
enddef

def GenBack(n: number): string # n 個の <BS> を生成
	var s: string
	for i in range(n)
		s = s .. "\<BS>"
	endfor
	return s
enddef

export def Space(): string # * は強調/箇条書き始まり、2つの可能性があるので、* 直後の空白は、すぐ後ろが * ならばそれを消し箇条書きの始まりにする
	# ** とペアで入れたときの補助用
	var line_s = getline('.')
	if strpart(line_s, 0, col('.') - 1) =~# '^\s*\*$'
			&& strpart(line_s, col('.') - 1, 1) ==# '*'
		return " \<Delete>"
	endif
	return ' '
enddef

export def BackSpace(): string # 箇条書きのインデントや箇条書きのマークをタブストップの位置のように一塊で消す
	if col('.') == 1
		if line('.') == 1 # 現在行頭
			return ''
		endif
		return "\<BS>"
	endif
	var line_s = getline('.')
	# 前後同じ記号 {{{
	# 3つ連続→強調 {{{
	var b: string = strpart(line_s, col('.') - 4, 3)
	var a: string = strpart(line_s, col('.') - 1, 3)
	for s in ['***', '___']
		if b ==# s && a ==# s
			return "\<BS>\<BS>\<BS>\<Delete>\<Delete>\<Delete>"
		endif
	endfor
	# }}}
	# 2つ連続 {{{
	b = strpart(line_s, col('.') - 3, 2)
	a = strpart(line_s, col('.') - 1, 2)
	for s in ['**', '__', '~~'] # 強調や取り消し
		if b ==# s && a ==# s
			return "\<BS>\<BS>\<Delete>\<Delete>"
		endif
	endfor
	# }}}
	# 一文字 {{{
	b = strpart(line_s, col('.') - 2, 1)
	a = strpart(line_s, col('.') - 1, 1)
	for s in ['*', '_', '~', '^'] # 強調、添字
		if b ==# s && a ==# s
			return "\<BS>\<Delete>"
		endif
	endfor
	# }}}
	# }}}
	# 箇条書きか?
	line_s = strpart(line_s, 0, col('.') - 1)
	var diff_tab: number
	if line_s =~# '^\s*\([*+-]\|\d\+\.\) $' # 箇条書きの項目先頭 (数字・記号) 部分
		return GenBack(strlen(matchstr(line_s, '^\s*\zs\([*+-]\|\d\+\.\) $')))
	elseif line_s !~# '^\s\+$' # カーソル前が空白文字ではない
		return "\<BS>"
	endif
	var info: dict<any> = ItemInfo(line_s, 0)
	if info.kind == 0
		if info.topTab !=# ''
			return GenBack(info.diff)
		endif
		return "\<BS>"
	else
		return GenBack(info.diff)
	endif
enddef

export def Tab(): string # 箇条書きのマークに合わせて空白を入れる
	var line_s: string = strpart(getline('.'), 0, col('.') - 1)

	if line_s !~# '^\s*$'
		return "\<Tab>"
	endif
	var info: dict<any> = ItemInfo(line_s, -1)
	if info.kind == 0
		return "\<Tab>"
	elseif info.diff >= info.kind
		return "\<Tab>"
	elseif info.kind == 2
		return '  '[ : 2 - info.diff ]
	else
		return '   '[ : 3 - info.diff ]
	endif
enddef

export def Enter(): string # カレント行の行頭やカーソル直前の空白文字に合わせて次行のインデントや箇条書きのマークを追加する
	# 加えて見出しでは文法に合わせ改行2つの扱いにする
	def GenCRstring(auto: string, noauto: string, s: string): string # 入力データの生成と補完候補が表示中ならそれを確定させる
		# auto:   自動インデントが ON の時に入力するインデント文字
		# noauto: 自動インデントが OFF の時に入力するBS文字
		# s:      自動インデントに関係なく追加で入力する文字
		var indent_f: bool = &autoindent || &smartindent || &cindent
		var cr: string = "\<CR>"

		if indent_f
			cr ..= auto .. s
		else
			cr ..= noauto .. s
		endif
		if pumvisible()
			return "\<CR>" .. cr
		else
			return cr
		endif
	enddef

	var line_s: string = getline('.')
	var item: list<string>

	if line_s =~# '^\(\s*\)\(\([*+-]\|\d\+\.\) \?\)\?$' # 次が空行で今の行がインデントのみや箇条書きの先頭記号や数字のみの時は、インデントや箇条書きを取り消した上で改行←Word の箇条書き取り消しに似せた
			&& getline(line('.') + 1) ==# ''
		return GenBack(strlen(line_s)) .. "\<CR>"
	endif
	line_s = strpart(line_s, 0, col('.') - 1)
	if line_s =~# '^#' # 見出し
		return GenCRstring('', '', "\<CR>")
	elseif line_s !~# '^\s' && line_s !~# '^\(\([*+-]\|\d\+\.\) \)' # 行頭が空白文字でも箇条書きの記号でない
		return GenCRstring('', '', '')
	elseif line_s =~# '  $' # 単純な改行
		item = matchlist(line_s, '^\(\s*\)\(\([*+-]\|\d\+\.\) \)\?')
		if item[2] ==# ''
			return GenCRstring('', item[1], '')
		elseif strlen(item[2]) == 2
			return GenCRstring('', item[1], '  ')
		else
			return GenCRstring('', item[1], '   ')
		endif
	elseif line_s =~# '^\s*\([*+-]\|\d\+\.\) ' # 箇条書きの項目
		item = matchlist(line_s, '^\(\s*\)\(\([*+-]\|\d\+\.\) \)\?')
		if strlen(item[2]) == 2
			return GenCRstring('', item[1], item[2])
		else
			return GenCRstring('', item[1], '1. ')
		endif
	endif
	var info: dict<any> = ItemInfo(matchstr(line_s, '^\(\s*\)\(\([*+-]\|\d\+\.\) \)\?'), 0)
	if info.kind == 0
		return GenCRstring('', info.topTab, '')
	elseif info.kind == 2
		return GenCRstring("\<BS>\<BS>", info.topTab, info.item)
	else
		return GenCRstring("\<BS>\<BS>\<BS>", info.topTab, '1. ')
	endif
enddef

