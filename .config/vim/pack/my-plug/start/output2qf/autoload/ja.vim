vim9script
export var msg: dict<string> = {
	'Error detected while processing %s:': '^\(.\{-}\) の処理中にエラーが検出されました:$',
	'Error detected while compiling %s:': '^\(.\{-}\) のコンパイル中にエラーが検出されました:$',
	'line %4ld:': '^行 \s*\(\d\+\):$',
	'\tLast set from ': '^\t最後にセットしたスクリプト: $',
	'%s line %ld': '^\(.\{-}\) 行 \(\d\+\)$',
	'E123: Undefined function: %s': '^E123: 未定義の関数です: ',
}
