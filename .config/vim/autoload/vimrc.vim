vim9script
scriptencoding utf-8
# $MYVIMRC で書かれた/使う関数

set_fugitve#main() # statusline で fugitive#statusline() を使っている

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
	execute 'lcd' c_path
enddef

export def Resolve(): void # シンボリック・リンク先を開く
	var bufname = bufname('%')
	var pos = getpos('.')
	var filetype = &filetype
	var full_path = resolve(expand('%'))
	enew
	execute 'bwipeout' bufname .. ' | edit ' .. full_path
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

export def Insert_template(s: string): void # ~/Templates/ からテンプレート挿入 {{{2
	# 普通に r を使うと空行ができる
	# ついでに適当な位置にカーソル移動
	execute ':1r ++encoding=utf-8 ~/Templates/' .. s
	:-join
	if &filetype ==# 'css' || &filetype ==# 'python'
		execute ':$'
	elseif index(['sh', 'tex', 'gnuplot'], &filetype) != -1
		execute ':' .. (line('$') - 1)
	elseif &filetype ==# 'html'
		execute ':' .. (line('$') - 2)
	else
		normal! gg}
	endif
enddef

export def StatusLine(): string
	# 表示するのは大雑把に↓
	# tabpagenr()/tabpagenr('$') bufnr filetype modified etc.|git|path|column bytes:number:word-count/file bytes:word-count line current/full % code charset:cr/lf
	def GetFlag(): string
		var f: string
		if win_gettype() ==# 'preview'
			f ..= ' PRV'
		endif
		if &readonly
			f ..= ' RO'
		endif
		if &modified
			f ..= ' +'
			if !&modifiable
				f ..= '-'
			endif
		elseif !&modifiable
			f ..= ' -'
		endif
		if f ==# ''
			return ' ' .. &filetype
		else
			return ' ' .. &filetype .. '[' .. f[1 : ] .. ']'
		endif
	enddef

	def GetPath(): string
		var p: string
		if &buftype ==# 'help'
			p = expand('%:t')
		else
			p = expand('%:p')->substitute('^' .. $HOME, '~', '')->substitute('%', '%%', 'g')
		endif
		if win_gettype() ==# 'command'
			return '[Commaand Line]'
		elseif p ==# ''
			return '[No Name]'
		else
			return p
		endif
	enddef

	var t: string = win_gettype()
	var s: string = '%#StatusLineLeft#%-19.(' .. tabpagenr() .. '/' .. tabpagenr('$') .. ':%n'
	if t ==# 'loclist' # quickfix  は編集することはないので、表示する情報を減らす
		return s .. ' [Location]%) %*%<' .. (exists('w:quickfix_title') ? w:quickfix_title : '') .. '%=%#StatusLineRight#%3l/%L%4p%%'
	elseif t ==# 'quickfix'
		return s .. ' [QuickFix]%) %*%<' .. (exists('w:quickfix_title') ? w:quickfix_title : '') .. '%=%#StatusLineRight#%3l/%L%4p%%'
	elseif &diff # diff モード縦分割を用いていウィンドウ幅が狭いので表示する情報を減らす
		return '%#StatusLineLeft#' .. tabpagenr() .. '/' .. tabpagenr('$') .. ':%n' .. GetFlag()
			.. '%#StatusGit#' .. fugitive#statusline()[5 : -3]->substitute('(', '\ ', '')
			.. '%*%<' .. GetPath()
			.. '%=%#StatusLineRight#%3p%%0x%04B'
	elseif &buftype ==# 'terminal'
		s ..= ' [Term]'
	elseif &buftype ==# 'help'
		s ..= ' [Help]'
	elseif &filetype ==# 'fugitive' || &filetype ==# 'git'
		s ..= ' ' .. &filetype
	else
		s ..= GetFlag()
	endif
	return s .. '%)%#StatusGit# ' .. fugitive#statusline()[5 : -3]->substitute('(', ' ', '')
		.. ' %* %<' .. GetPath()
		.. '%=%#StatusLineRight# %c:%v:'
				.. strcharlen(strpart(getline('.'), 0, col('.'))) .. ' ' .. strlen(join(getline(0, line('$')), &ff == 'dos' ? '12' : '1')) .. ':' .. strcharlen(join(getline(0, line('$')), ''))
				.. ' %3l/%L%4p%% 0x%04B ['
				.. (&fenc != '' ? &fenc : &enc) .. ':' .. {dos: 'CR+LF', unix: 'LF', mac: 'CR'}[&ff] .. ']'
enddef

