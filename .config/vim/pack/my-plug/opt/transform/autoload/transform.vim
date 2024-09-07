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

def CheckBase64(s: string): bool
	if len(s) % 4 != 0 || s !~? '^[0-9A-Za-z+/]\+=\{0,2}$'
		echohl ErrorMsg | echo "Don't BASE64!" | echohl None
		return false
	endif
	return true
enddef

export def Base64(str: string): string # BASE64 をデコード
	var base64: dict<number> = {
			'A': 0x00, 'B': 0x01, 'C': 0x02, 'D': 0x03, 'E': 0x04, 'F': 0x05, 'G': 0x06, 'H': 0x07,
			'I': 0x08, 'J': 0x09, 'K': 0x0A, 'L': 0x0B, 'M': 0x0C, 'N': 0x0D, 'O': 0x0E, 'P': 0x0F,
			'Q': 0x10, 'R': 0x11, 'S': 0x12, 'T': 0x13, 'U': 0x14, 'V': 0x15, 'W': 0x16, 'X': 0x17,
			'Y': 0x18, 'Z': 0x19, 'a': 0x1A, 'b': 0x1B, 'c': 0x1C, 'd': 0x1D, 'e': 0x1E, 'f': 0x1F,
			'g': 0x20, 'h': 0x21, 'i': 0x22, 'j': 0x23, 'k': 0x24, 'l': 0x25, 'm': 0x26, 'n': 0x27,
			'o': 0x28, 'p': 0x29, 'q': 0x2A, 'r': 0x2B, 's': 0x2C, 't': 0x2D, 'u': 0x2E, 'v': 0x2F,
			'w': 0x30, 'x': 0x31, 'y': 0x32, 'z': 0x33, '0': 0x34, '1': 0x35, '2': 0x36, '3': 0x37,
			'4': 0x38, '5': 0x39, '6': 0x3A, '7': 0x3B, '8': 0x3C, '9': 0x3D, '+': 0x3E, '/': 0x3F
		}
	var i: number = 0
	var s_len = len(str)
	var decode: string
	var s: string
	var code: number

	if !CheckBase64(str)
		return str
	endif
	while i < s_len
		s = str[i : i + 3]
		if s[2 : ] ==# '=='
			decode ..= nr2char((base64[s[0]] * 0x40 + base64[s[1]]) / 0x10)
		elseif s[3] ==# '='
			code = (base64[s[0]] * 0x1000 + base64[s[1]] * 0x40 + base64[s[2]]) / 0x04
			decode = decode .. nr2char(and(code, 0xFF00) / 0x100) ..  nr2char(and(code, 0x00FF))
		else
			code = base64[s[0]] * 0x40000 + base64[s[1]] * 0x1000 + base64[s[2]] * 0x40 + base64[s[3]]
			decode = decode .. nr2char(and(code, 0xFF0000) / 0x10000) ..  nr2char(and(code, 0x00FF00) / 0x100) ..  nr2char(and(code, 0x0000FF))
		endif
		i += 4
	endwhile
	return decode
enddef

export def Base64Cmd(): void
	var ls: list<string> = getline(1, '$')
	var s: string
	var b: number
	var c: number = line('.') - 1
	var l: number = line('$') - 1
	var i: number

	i = c
	while true
		if ls[i] == ''
			i += 1
			break
		elseif i == 0
			break
		endif
		i -= 1
	endwhile
	b = i
	i = c
	while true
		if ls[i] == ''
			i -= 1
			break
		elseif i == l
			break
		endif
		i += 1
	endwhile
	s = join(ls[b : i], '')
	if !CheckBase64(s)
		return
	endif
	silent execute ':' .. (b + 1) .. ',' .. (i + 1) .. 'delete _'
	append(b, Base64(s)->split('\(\r\n\|\r\|\n\)'))
enddef
