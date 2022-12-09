vim9script
scriptencoding utf-8
# 文字列変換
# 置換では次の様に使う
# s/[！-～￥]\+/\=reform#Zen2han(submatch(0))/g

export def Zen2han(s: string): string # 全角を半角に変換
	# ￥, ＼ は \ (0x6C:ASCII code) ではなく UNICODE 独自の記号 ¥ (0xA5), ⧵ (0x29F5) に変換
	return substitute(s, '￥', '¥', 'g') # 円記号の変換
		->substitute('＼', '⧵', 'g') # ＼ をUNICODE で定義された ⧵ (0x29F5) に変換 \ (0x6C:ASCII code) ではない
		->substitute('＆', '\&', 'g') # エスケープが必要な & への変換
		->map('v:val =~ "[！-～]" ? nr2char(strgetchar(v:val, 0) - 65248) : v:val' )
enddef

export function Zen2hanCmd() range abort
	for i in range(a:firstline, a:lastline)
		call setline(i, Zen2han(getline(i)))
	endfor
endfunction
