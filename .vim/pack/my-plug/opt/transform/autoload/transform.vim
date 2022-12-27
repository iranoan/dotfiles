vim9script
scriptencoding utf-8
# 文字列変換
# 置換では次の様に使う

# s/[！-～￥]\+/\=transform#Zen2han(submatch(0))/g
# call setline('.', transform#InsertSpace(getline('.')))

export def Zen2han(s: string): string # 全角を半角に変換
	# ￥, ＼ は \ (0x6C:ASCII code) ではなく UNICODE 独自の記号 ¥ (0xA5), ⧵ (0x29F5) に変換
	return map(substitute(substitute(s, '[^　 \t]\zs　', ' ', 'g'),
		'[￥＼]', '\={"￥": "¥", "＼": "⧵"}[submatch(0)]', 'g'),
		'v:val =~# "[！-～]" ? nr2char(strgetchar(v:val, 0) - 65248) : v:val' )
enddef
# 旧来のスクリプトから呼ぶので、|vim9-lambda| が使えない
# var Zen2han = (s: string): string =>
# 	substitute(s, '[^　 \t]\zs　', ' ', 'g')
# 		->substitute('[￥＼]', '\={"￥": "¥", "＼": "⧵"}[submatch(0)]', 'g')
# 		->map('v:val =~# "[！-～]" ? nr2char(strgetchar(v:val, 0) - 65248) : v:val' )

export function Zen2hanCmd() range abort
	let pos = getpos('.')
	execute('silent ' .. a:firstline .. ',' .. a:lastline .. 'global/[！-～　￥＼]/call setline(".", Zen2han(getline(".")))')
	call setpos('.', pos)
endfunction

export def InsertSpace(s: string): string # 英数字と全角の間に空白を入れる
	var top: string
	var end: string
	if &filetype ==# 'tex'
		end = '[[0-9a-zA-Z<(]'
		top = '[]0-9a-zA-Z>)$.,?!%]'
	elseif &filetype ==# 'html' || &filetype ==# 'xhtml'
		end = '[[0-9a-zA-Z{(]'
		top = '[]0-9a-zA-Z})$.,?!%]'
	else
		end = '[[0-9a-zA-Z<{(]'
		top = '[]0-9a-zA-Z>})$.,?!%]'
	endif
	return substitute(s, top .. '\zs\ze[〃-〇〓〠-〾ぁ-ゞゟァ-ヺー-ヿㇰ-ㇿ㐀-䶵一-鿪]', ' ', 'g')
		->substitute('[〃-〇〓〠-〾ぁ-ゞゟァ-ヺー-ヿㇰ-ㇿ㐀-䶵一-鿪]\zs\ze' .. end, ' ', 'g')
enddef

export function InsertSpaceCmd() range abort
	let pos = getpos('.')
	if &filetype ==# 'tex'
		let end = '[[0-9a-zA-Z<(]'
		let top = '[]0-9a-zA-Z>)$.,?!%]'
	elseif &filetype ==# 'html' || &filetype ==# 'xhtml'
		let end = '[[0-9a-zA-Z{(]'
		let top = '[]0-9a-zA-Z})$.,?!%]'
	else
		let end = '[[0-9a-zA-Z<{(]'
		let top = '[]0-9a-zA-Z>})$.,?!%]'
	endif
	let ja_char = '[〃-〇〓〠-〾ぁ-ゞゟァ-ヺー-ヿㇰ-ㇿ㐀-䶵一-鿪]'
	execute('silent ' .. a:firstline .. ',' .. a:lastline .. 's/' .. top .. '\zs\ze' .. ja_char .. '/ /ge')
	execute('silent ' .. a:firstline .. ',' .. a:lastline .. 's/' .. ja_char .. '\zs\ze' .. end .. '/ /ge')
	call setpos('.', pos)
endfunction
