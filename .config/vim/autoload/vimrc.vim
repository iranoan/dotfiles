vim9script
scriptencoding utf-8
# $MYVIMRC で書かれた/使う関数

export def Lcd(): void # カレントディレクトリをファイルのディレクトリに移動
	if get(b:, 'lcd_worked', false)
		return
	endif
	var c_path: string
	var buf_name: string = bufname()
	if buf_name ==# ''
		return
	elseif &filetype ==# 'fugitive' || buf_name =~# '^fugitive://'
		if buf_name !~# '/\.git//'
				|| buf_name =~# '/\.git//[^/]\+/[^/]\+' # Gdiffsplit のウィンドウ
			return
		endif
		c_path = expand('%:p:h:h')->substitute('^fugitive://', '', '')
	elseif buf_name =~# '^[a-z]\+://' ||
			buf_name =~# '^!' ||
			index(['nofile', 'quickfix', 'help', 'prompt', 'popup', 'terminal'], &buftype) != -1 ||
			&filetype ==# 'terminal' ||
			&filetype ==# 'qf'
		return
	elseif &filetype ==# 'tex'
		if match(getline(1, 10), '^\s*\\documentclass\>') > 0 # 先頭 10 行の \documentclass の有無確認
			c_path = expand('%:p:h')
		elseif system('grep -El ' .. '''^\s*\\documentclass\>''' .. ' ' .. expand('%:p:h') .. '/*.tex 2> /dev/null') !=# ''
			# カレント・ディレクトリに記載のあるファイルがある
			# grep コマンドで個数が解れば良いが方法不明
			c_path = expand('%:p:h')
		else # 機械的に親ディレクトリをカレント・ディレクトリにする
			c_path = expand('%:p:h:h')
		endif
	else
		c_path = expand('%:p:h')
	endif
	if !isdirectory(c_path)
		var make: number = confirm("No exist '" .. simplify(c_path)->escape('\')->substitute('^' .. $HOME .. '\ze[/\\]', '~', '')
			# .. "\nfiletype: " .. &filetype .. " bufname: " .. bufname() .. " buttype: " .. &buftype
			.. "'\nDo you make?", "(&Y)es\n(&N)o", 1, 'Question')
		if make == 1
			mkdir(c_path, 'p', 0o700)
		else
			b:lcd_worked = true
			return
		endif
	endif
	execute 'lcd ' .. c_path
enddef

export def Resolve(): void # シンボリック・リンク先を開く
	var bufname = bufname('%')
	var pos = getpos('.')
	var filetype = &filetype
	var full_path = resolve(expand('%'))
	enew
	execute 'bwipeout ' .. bufname .. ' | edit ' .. full_path
	setpos('.', pos)
	execute 'setlocal filetype=' .. filetype
enddef

export def MoveChanged(move_rear: bool): void # カーソルリストの前後に有る変更箇所に移動
	# g;, g, は時間軸で移動するが、これは位置を軸として移動
	var BigSmall = (a, b) => ( a.lnum == b.lnum ?
		( a.col > b.col ? 1 : ( a.col < b.col ? -1 : 0) )
		: (a.lnum > b.lnum ? 1 : -1 ) )

	var change: list<dict<number>> = getchangelist()[0]
	var pos: dict<number>
	var l: number = line('.')

	if move_rear
		change = filter(change, (idx, val) => ( val.lnum == l && val.col > col('.') && val.col < col('$') - 1 )
																			 || ( val.lnum > l && val.lnum <= getbufinfo(bufnr())[0].linecount)
		)
	else
		change = filter(change, (idx, val) => ( val.lnum == l && val.col < col('.') - 1 )
																			 ||   val.lnum < l
		)
	endif
	if len(change) == 0
		echo 'No Change in ' .. (move_rear ? 'rear' : 'front')
		return
	endif
	if move_rear
		pos = sort(change, BigSmall)[0]
	else
		pos = sort(change, BigSmall)[-1]
	endif
	setpos('.', [bufnr(), pos.lnum, pos.col, 0])
	echo ''
enddef
