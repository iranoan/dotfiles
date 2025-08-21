scriptencoding utf-8
" スクリプト・ローカルな関数を置き換える
" 元ネタ https://thinca.hatenablog.com/entry/20111228/1325077104

function hook_function#main(from_f, to_f, from_func, to_func)
	" from_f:    置き換え元の関数が書かれたファイル・パス
	" to_f:      置き換え先の関数が書かれたファイル・パス
	" from_func: 書き換え元の関数名
	" to_func:   書き換え先の関数名
	execute 'function! ' .. '<SNR>' .. getscriptinfo({'name': from_f .. '$'})[0].sid .. '_' .. a:from_func
				\ .. '(...)\nreturn call(''<SNR>' .. getscriptinfo({'name': to_f .. '$'})[0].sid .. '_' .. a:to_func .. ''', a:000)\nendfunction'
endfunction
