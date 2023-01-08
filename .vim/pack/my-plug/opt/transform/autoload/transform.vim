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
		'v:val =~# "[！-～]" ? nr2char(strgetchar(v:val, 0) - 65248) : v:val')
enddef
# 旧来のスクリプトから呼ぶので、|vim9-lambda| が使えない
# var Zen2han = (s: string): string =>
# 	substitute(s, '[^　 \t]\zs　', ' ', 'g')
# 		->substitute('[￥＼]', '\={"￥": "¥", "＼": "⧵"}[submatch(0)]', 'g')
# 		->map('v:val =~# "[！-～]" ? nr2char(strgetchar(v:val, 0) - 65248) : v:val' )

export function Zen2hanCmd() range abort
	execute('silent ' .. a:firstline .. ',' .. a:lastline .. 'global/[！-～　￥＼]/call setline(".", Zen2han(getline(".")))')
endfunction

export def InsertSpace(s: string): string # 英数字と全角の間に空白を入れる
	var top: string
	var last: string
	if &filetype ==# 'tex'
		last = '[[0-9a-zA-Z<(]'
		top = '[]0-9a-zA-Z>)$.,?!%]'
	elseif &filetype ==# 'html' || &filetype ==# 'xhtml'
		last = '[[0-9a-zA-Z{(]'
		top = '[]0-9a-zA-Z})$.,?!%]'
	else
		last = '[[0-9a-zA-Z<{(]'
		top = '[]0-9a-zA-Z>})$.,?!%]'
	endif
	return substitute(s, top .. '\zs\ze[〃-〇〓〠-〾ぁ-ゞゟァ-ヺー-ヿㇰ-ㇿ㐀-䶵一-鿪]', ' ', 'g')
		->substitute('[〃-〇〓〠-〾ぁ-ゞゟァ-ヺー-ヿㇰ-ㇿ㐀-䶵一-鿪]\zs\ze' .. last, ' ', 'g')
enddef

export function InsertSpaceCmd() range abort
	if &filetype ==# 'tex'
		let last = '[[0-9a-zA-Z<(]'
		let top = '[]0-9a-zA-Z>)$.,?!%]'
	elseif &filetype ==# 'html' || &filetype ==# 'xhtml'
		let last = '[[0-9a-zA-Z{(]'
		let top = '[]0-9a-zA-Z})$.,?!%]'
	else
		let last = '[[0-9a-zA-Z<{(]'
		let top = '[]0-9a-zA-Z>})$.,?!%]'
	endif
	let ja_char = '[〃-〇〓〠-〾ぁ-ゞゟァ-ヺー-ヿㇰ-ㇿ㐀-䶵一-鿪]'
	execute('silent ' .. a:firstline .. ',' .. a:lastline .. 's/' .. top .. '\zs\ze' .. ja_char .. '/ /ge')
	execute('silent ' .. a:firstline .. ',' .. a:lastline .. 's/' .. ja_char .. '\zs\ze' .. last .. '/ /ge')
endfunction

export def Han2zen(s: string): string # 半角カタカナを全角に変換
	var dic0: dict<string> = {
			'ｶﾞ': 'ガ', 'ｷﾞ': 'ギ', 'ｸﾞ': 'グ', 'ｹﾞ': 'ゲ', 'ｺﾞ': 'ゴ',
			'ｻﾞ': 'ザ', 'ｼﾞ': 'ジ', 'ｽﾞ': 'ズ', 'ｾﾞ': 'ゼ', 'ｿﾞ': 'ゾ',
			'ﾀﾞ': 'ダ', 'ﾁﾞ': 'ヂ', 'ﾂﾞ': 'ヅ', 'ﾃﾞ': 'デ', 'ﾄﾞ': 'ド',
			'ﾊﾞ': 'バ', 'ﾋﾞ': 'ビ', 'ﾌﾞ': 'ブ', 'ﾍﾞ': 'ベ', 'ﾎﾞ': 'ボ',
			'ﾊﾟ': 'パ', 'ﾋﾟ': 'ピ', 'ﾌﾟ': 'プ', 'ﾍﾟ': 'ペ', 'ﾎﾟ': 'ポ'
		}
	var dic1: dict<string> = {
			'｡': '。', '｢': '「', '｣': '」', '､': '、', '･': '・',
			'ｧ': 'ァ', 'ｨ': 'ィ', 'ｩ': 'ゥ', 'ｪ': 'ェ', 'ｫ': 'ォ',
			'ｬ': 'ャ', 'ｭ': 'ュ', 'ｮ': 'ョ',
			'ｯ': 'ッ', 'ｰ': 'ー',
			'ｱ': 'ア', 'ｲ': 'イ', 'ｳ': 'ウ', 'ｴ': 'エ', 'ｵ': 'オ',
			'ｶ': 'カ', 'ｷ': 'キ', 'ｸ': 'ク', 'ｹ': 'ケ', 'ｺ': 'コ',
			'ｻ': 'サ', 'ｼ': 'シ', 'ｽ': 'ス', 'ｾ': 'セ', 'ｿ': 'ソ',
			'ﾀ': 'タ', 'ﾁ': 'チ', 'ﾂ': 'ツ', 'ﾃ': 'テ', 'ﾄ': 'ト',
			'ﾅ': 'ナ', 'ﾆ': 'ニ', 'ﾇ': 'ヌ', 'ﾈ': 'ネ', 'ﾉ': 'ノ',
			'ﾊ': 'ハ', 'ﾋ': 'ヒ', 'ﾌ': 'フ', 'ﾍ': 'ヘ', 'ﾎ': 'ホ',
			'ﾏ': 'マ', 'ﾐ': 'ミ', 'ﾑ': 'ム', 'ﾒ': 'メ', 'ﾓ': 'モ',
			'ﾔ': 'ヤ', 'ﾕ': 'ユ', 'ﾖ': 'ヨ',
			'ﾗ': 'ラ', 'ﾘ': 'リ', 'ﾙ': 'ル', 'ﾚ': 'レ', 'ﾛ': 'ロ',
			'ﾜ': 'ワ', 'ｦ': 'ヺ', 'ﾝ': 'ン',
			'ﾞ': "\u3099", 'ﾟ': "\u309A"
		}
	return substitute(substitute(s,
		'\([ｶ-ﾄﾊ-ﾎ]ﾞ\|[ﾊ-ﾎ]ﾟ\)', '\=dic0[submatch(0)]', 'g'),
		'[｡-ﾟ]', '\=dic1[submatch(0)]', 'g')
enddef

export function Han2zenCmd() range abort
	execute('silent ' .. a:firstline .. ',' .. a:lastline .. 'global/[｡-ﾟ]/call setline(".", Han2zen(getline(".")))')
endfunction

export def Hira2kata(s: string): string # ひらがなをカタカナへ
	return map(s, 'v:val =~# "[ぁ-ゖ]" ? nr2char(strgetchar(v:val, 0) + 96, true) : v:val')
enddef

export function Hira2kataCmd() range abort
	execute('silent ' .. a:firstline .. ',' .. a:lastline .. 'global/[ぁ-ゖ]/call setline(".", Hira2kata(getline(".")))')
endfunction

export def Kata2hira(s: string): string # カタカナをひらがなへ
	return map(s, 'v:val =~# "[ァ-ヶ]" ? nr2char(strgetchar(v:val, 0) - 96, true) : v:val')
enddef

export function Kata2hiraCmd() range abort
	execute('silent ' .. a:firstline .. ',' .. a:lastline .. 'global/[ァ-ヶ]/call setline(".", Kata2hira(getline(".")))')
endfunction
