vim9script
scriptencoding utf-8

export def Lcd(): void # カレントディレクトリをファイルのディレクトリに移動
	if &filetype ==# 'fugitive'
		execute 'lcd ' .. substitute(expand('%:p:h:h'), '^fugitive://', '', '')
	elseif &buftype ==# 'help'
		return
	elseif &filetype ==# 'tex'
		if match(getline(1, 10), '^\s*\\documentclass\>') > 0 # 先頭 10 行の \documentclass の有無確認
			execute 'lcd ' .. expand('%:p:h')
		elseif system('grep -El ' .. '''^\s*\\documentclass\>''' .. ' ' .. expand('%:p:h') .. '/*.tex 2> /dev/null') !=# ''
			# カレント・ディレクトリに記載のあるファイルがある
			# grep コマンドで個数が解れば良いが方法不明
			execute 'lcd ' .. expand('%:p:h')
		else # 機械的に親ディレクトリをカレント・ディレクトリにする
			execute 'lcd ' .. expand('%:p:h:h')
		endif
	elseif isdirectory(expand('%:p:h'))
		execute 'lcd ' .. expand('%:p:h')
	endif
	return
enddef
