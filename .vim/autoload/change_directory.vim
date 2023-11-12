vim9script
scriptencoding utf-8

export def Lcd(): void # カレントディレクトリをファイルのディレクトリに移動
	if get(b:, 'lcd_worked', false)
		return
	endif
	var c_path: string
	var buf_name: string = bufname()
	if buf_name ==# ''
		return
	elseif &filetype ==# 'fugitive' || buf_name =~# '^fugitive://'
		c_path = expand('%:p:h:h')->substitute('^fugitive://', '', '')
	elseif buf_name =~# '^[a-z]\+://' ||
			buf_name =~# '^!' ||
			&buftype ==# 'nofile' ||
			&buftype ==# 'quickfix' ||
			&buftype ==# 'help' ||
			&buftype ==# 'prompt' ||
			&buftype ==# 'popup' ||
			&buftype ==# 'terminal' ||
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
