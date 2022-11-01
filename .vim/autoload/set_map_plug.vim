vim9script
scriptencoding utf-8
# nmap k <Plug>... の要領で <Plug> にマッピングするプラグインを遅延読み込み

export def Main(plug: string, cmd: string, map_ls: list<dict<string>>): void
	# plug: 読み込むプラグイン名
	# cmd: 実際に実行するコマンド (先頭の <Plug> は省略)
	#      <Plug>Commentary<Plug>Commentary のように複数の場合は 'Commentary<Plug>Commentary' の様に先頭の <Plug> のみ除く
	# map_ls: マッピングの内容の辞書リスト
	# {
	# 	mode: n, x, o などのモード
	# 	map: 割り当てるキーマップ
	# 	cmd: 割り当てるコマンド (<Plug> を除く)
	# }
	var extra: string
	var c: number
	while 1
		c = getchar(0)
		if c == 0
			break
		endif
		extra ..= nr2char(c)
	endwhile
	for i in map_ls
		execute i['mode'] .. 'map ' .. i['key'] .. ' <Plug>' .. i['cmd']
	endfor
	var exe_cmd = substitute(cmd, ' ', "\<Plug>", 'g')
	execute 'packadd ' .. plug
	feedkeys("\<Plug>" .. exe_cmd .. extra)
enddef
