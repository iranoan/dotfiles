scriptencoding utf-8
" スクリプト・ローカルな関数を置き換える

function hook_function#main(from_f, to_f, func)
	" from_f:   置き換え元の関数が書かれたファイル・パス
	" to_f:     置き換え先の関数が書かれたファイル・パス
	" func:     関数名
	exec "function! " .. s:get_func(a:from_f) .. a:func .. "(...)\nreturn call('" .. s:get_func(a:to_f) .. a:func .. "', a:000)\nendfunction"
endfunction

def s:get_func(fname: string): string
	var f = resolve(expand(fname)) # シンボリック・リンク展開
		->substitute('^' .. escape(expand('$HOME'), '/\.'), '~', 'g') # $HOME を ~ に置換
	f = execute('silent! filter /\m^\s\+\d\+:\s\+' .. escape(f, '/\~.') .. '$/ scriptnames') # スクリプト ID とパス取得
		->substitute('[\n\r]', '', 'g') # 改行削除
		->substitute('^\s*\(\d\+\):.\+', '\1', 'g') # ID のみ取り出し
	return '<SNR>' .. f .. '_'
enddef
