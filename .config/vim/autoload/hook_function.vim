scriptencoding utf-8
" スクリプト・ローカルな関数を置き換える
" 元ネタ https://thinca.hatenablog.com/entry/20111228/1325077104

function hook_function#main(from_f, to_f, from_func, to_func)
	" from_f:    置き換え元の関数が書かれたファイル・パス
	" to_f:      置き換え先の関数が書かれたファイル・パス
	" from_func: 書き換え元の関数名
	" to_func:   書き換え先の関数名
	echomsg "function! " .. s:get_func(a:from_f) .. a:from_func .. "(...)\nreturn call('" .. s:get_func(a:to_f) .. a:to_func .. "', a:000)\nendfunction"
	exec "function! " .. s:get_func(a:from_f) .. a:from_func .. "(...)\nreturn call('" .. s:get_func(a:to_f) .. a:to_func .. "', a:000)\nendfunction"
endfunction

def s:get_func(fname: string): string
	var f = resolve(expand(fname)) # シンボリック・リンク展開
		->substitute('^' .. escape(expand('$HOME'), '/\.'), '~', 'g') # $HOME を ~ に置換
	f = execute('filter /\m^\s*\d\+:\s\+' .. escape(f, '/\~.') .. '$/ scriptnames', 'silent!') # スクリプト ID とパス取得
		->substitute('[\n\r]', '', 'g') # 改行削除
		->substitute('^\s*\(\d\+\):.\+', '\1', 'g') # ID のみ取り出し
	return '<SNR>' .. f .. '_'
enddef
