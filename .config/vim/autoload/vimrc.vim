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
		filter(change, (_, v) => ( v.lnum == l && v.col > col('.') && v.col < col('$') - 1 )
															|| ( v.lnum > l && v.lnum <= getbufinfo(bufnr())[0].linecount)
		)
	else
		filter(change, (_, v) => ( v.lnum == l && v.col < col('.') - 1 )
															|| v.lnum < l
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

export def Insert_template(s: string): void # ~/Templates/ からテンプレート挿入
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

export def StatusLine(): string # set statusline=%!vimrc#StatusLine() で利用する
	# 表示するのは大雑把に↓
	# tabpagenr()/tabpagenr('$') bufnr filetype modified etc.|git|path|column bytes:number:word-count/file word-count:bytes line current/full % code charset:cr/lf
	# ←区切りに使いたいが、GVim で隙間が空いてしまう
	var bufnr: number = winbufnr(g:statusline_winid)
	var filetype: string = getbufvar(bufnr, '&filetype')
	var buftype: string = getbufvar(bufnr, '&buftype')
	var fileformat: string = getbufvar(bufnr, '&fileformat')
	var fileencoding: string = getbufvar(bufnr, '&fileencoding')
	var win_type: string = win_gettype(g:statusline_winid)
	var curpos: list<any> = getcurpos(g:statusline_winid)
	var curline: string = printf('%3d', curpos[1]) # %3l (:help stl-%! の %l) では中身が空だと 0 になる
	var diff: bool = getwinvar(g:statusline_winid, '&diff')
	var statusGit: string = '%#StatusGit#%{fugitive#Statusline()[5 : -3]->substitute("(", " ", "")}'

	def GetFlag(): string
		var f: string
		if win_type ==# 'preview'
			f ..= ' PRV'
		endif
		if getbufvar(bufnr, '&readonly')
			f ..= ' RO'
		endif
		if getbufvar(bufnr, '&modified')
			f ..= ' +'
			if !getbufvar(bufnr, '&modifiable')
				f ..= '-'
			endif
		elseif !getbufvar(bufnr, '&modifiable')
			if f ==# ''
				f = ' -'
			else
				f ..= '-'
			endif
		endif
		if diff
			if f ==# ''
				return f
			else
				return f[1 : ]
			endif
		elseif f ==# ''
			return ' ' .. filetype
		else
			return ' ' .. filetype .. '[' .. f[1 : ] .. ']'
		endif
	enddef

	def GetPath(): string
		var p: string = getbufinfo(bufnr)[0].name
		if buftype ==# 'help'
			p = substitute(p, '.*/', '', '')
		else
			p = substitute(p, '^' .. $HOME, '~', '')
		endif
		if p ==# ''
			return '[No Name]'
		else
			return ' %<' .. p
		endif
	enddef

	def StatusKind(): string
		var mode: string = mode()
		if g:statusline_winid != win_getid(winnr())
			return '%#StatusLineNC#'
		elseif mode ==# 'i'
			return '%#IncSearch#'
		elseif mode ==# 'c'
			return '%#WildMenu#'
		elseif mode ==# 'R'
			return '%#Error#'
		endif
		return '%#StatusLine#'
	enddef

	def StatusRight(): string
		return '%=%#StatusLineRight# %c:%v:'
			.. strcharlen(strpart(getbufoneline(bufnr, curpos[1]), 0, curpos[2])) .. ' '
			.. strcharlen(join(getbufline(bufnr, 0, '$'), ''))
			.. ':' .. strlen(join(getbufline(bufnr, 0, '$'), fileformat == 'dos' ? '12' : '1'))
			.. ' ' .. curline .. '/%L%4p%% 0x%04B ['
			.. (fileencoding != '' ? fileencoding : &enc) .. ':' .. {dos: 'CR+LF', unix: 'LF', mac: 'CR'}[fileformat] .. ']'
	enddef

	def DiffPostion(id: number): dict<any>
		# vert: id が縦分割の内部か? (親を辿っても)
		# n:    diff の何番目
		# all:  diff が全体で幾つ有る?
		# exist_hor: diff の中で横幅全体が有るか?
		var ret: dict<any> = {exist_hor: false}
		var count: number = 0
		def ColRow(ls: list<any>, vert: bool): void
			if ls[0] ==# 'col'
				for i in ls[1]
					ColRow(i, vert)
				endfor
			elseif ls[0] ==# 'row'
				for i in ls[1]
					ColRow(i, true)
				endfor
			else # leaf
				if ls[1] == id
					count += 1 # 確認するまで泣く diff
					ret = {
						vert: vert,
						n: count,
						exist_hor: ret.exist_hor ? true : !vert
					}
				elseif getwinvar(ls[1], '&diff')
					count += 1
					if !vert
						ret.exist_hor = true
					endif
				endif
			endif
		enddef

		ColRow(winlayout(), false)
		ret.all = count
		return ret
	enddef

	var s: string = '%#StatusLineLeft#%-19.(' .. tabpagenr() .. '/' .. tabpagenr('$') .. ':%n'
	if win_type ==# 'loclist' # quickfix は編集することはないので、表示する情報を減らす
		return s .. ' [Location]%) ' .. StatusKind() .. '%<' .. (exists('w:quickfix_title') ? w:quickfix_title : '') .. '%=%#StatusLineRight#' .. curline .. '/%L%4p%%'
	elseif win_type ==# 'quickfix'
		return s .. ' [QuickFix]%) ' .. StatusKind() .. '%<' .. (exists('w:quickfix_title') ? w:quickfix_title : '') .. '%=%#StatusLineRight#' .. curline .. '/%L%4p%%'
	elseif diff # diff モード縦分割を用いていウィンドウ幅が狭いので表示する情報を減らす
		# echomsg [g:statusline_winid, DiffPostion(g:statusline_winid)]
		var k: dict<any> = DiffPostion(g:statusline_winid)
		var f: string = GetFlag()
		if !(k.vert) # 縦分割されていない
			if f ==# ''
				return s .. ' [Diff]%)' .. statusGit .. ' ' .. StatusKind() .. GetPath() .. StatusRight()
			else
				return s .. ' [Diff:' .. f .. ']%)' .. statusGit .. ' ' .. StatusKind() .. GetPath() .. StatusRight()
			endif
		elseif k.exist_hor # 縦分割されていない diff が他に有る
			if f ==# ''
				return '%#StatusLineLeft#%n ' .. statusGit .. StatusKind() .. GetPath()
			else
				return '%#StatusLineLeft#%n[' .. f .. '] ' .. statusGit .. StatusKind() .. GetPath()
			endif
		elseif k.n == 1 # 最初の diff
			if f ==# ''
				return '%#StatusLineLeft#' .. tabpagenr() .. '/' .. tabpagenr('$')
					.. ':%n [Diff] ' .. statusGit .. StatusKind() .. GetPath()
			else
				return '%#StatusLineLeft#' .. tabpagenr() .. '/' .. tabpagenr('$')
					.. ':%n [Diff:' .. f .. '] ' .. statusGit .. StatusKind() .. GetPath()
			endif
		elseif k.n == k.all # 最後の diff
			if f ==# ''
				return '%#StatusLineLeft#%n ' .. statusGit .. StatusKind() .. GetPath() .. '%=%#StatusLineRight#%3p%% 0x%04B'
			else
				return '%#StatusLineLeft#%n[' .. f .. '] ' .. statusGit .. StatusKind() .. GetPath() .. '%=%#StatusLineRight#%3p%% 0x%04B'
			endif
		endif
		if f ==# ''
			return '%#StatusLineLeft#%n ' .. statusGit .. StatusKind() .. GetPath()
		else
			return '%#StatusLineLeft#%n[' .. f .. '] ' .. statusGit .. StatusKind() .. GetPath()
		endif
	elseif win_type ==# 'command'
		win_type = win_execute(g:statusline_winid, 'echo getcmdwintype()')
		if win_type =~# ':'
			return s .. ' [Command Line Window]%) %#StatusLine#%< Ex command' .. StatusRight()
		elseif win_type =~# '/'
			return s .. ' [Command Line Window]%) %#StatusLine#%< Search forward' .. StatusRight()
		elseif win_type =~# '?'
			return s .. ' [Command Line Window]%) %#StatusLine#%< Search backward' .. StatusRight()
		endif
		return s .. ' [Command Line Window]%) %#StatusLine#%<' .. StatusRight()
	elseif buftype ==# 'terminal'
		s ..= ' [Term]'
	elseif buftype ==# 'help'
		s ..= ' [Help]'
	elseif filetype ==# 'fugitive' || filetype ==# 'git'
		s ..= ' ' .. filetype
	else
		s ..= GetFlag()
	endif
	return s .. '%)' .. statusGit .. ' ' .. StatusKind() .. GetPath() .. StatusRight()
enddef

export def KillTerminal(): void # :terminal は一つに
	var bufnum: number = bufnr('') # カレント・バッファ (直前に開いたターミナルを想定)
	var terms: list<number> = term_list()
	var terms_in_tab: list<number>
	for buf in tabpagebuflist() # タブ・ページ内のバッファからターミナルを探す (コマンド実行済みは除く)
		if match(terms, '^' .. buf .. '$') >= 0
			add(terms_in_tab, buf)
		endif
	endfor
	if match(terms_in_tab, '^' .. bufnum .. '$') == -1 # 現在のバッファが(カレント・タブページの)ターミナルではない
		return
	endif
	if len(terms_in_tab) == 1 # ターミナルが一つ
		for buf in terms
			if getbufinfo(buf)[0]['hidden'] # 隠れバッファのターミナルが有ればそれを開く
				execute 'split +' .. buf .. 'buffer'
				execute 'bwipeout! ' .. bufnum
				return
			endif
		endfor
		return
	endif
	execute 'bwipeout! ' .. bufnum
	terms_in_tab = filter(terms_in_tab, (k, _) => k != bufnum)
	win_gotoid(bufwinid(terms_in_tab[0]))
enddef

export def ChangeScrolloff(): void # /, ? と :s[ubstitute] で c フラグを使った時に scrolloff=2 とする それ以外の : で scrolloff=0 にする
	# 検索や置換では前後を確認したい←一々 <C-E>, <C-Y> をするのが面倒
	def Type(t: string, s: string): bool
		if t ==# '/' || t ==# '?'
			return true
		elseif t == ':'
			var matchl: list<string> = matchlist(s, '^\(\([0-9]\+\|''<\|\.\),\([0-9]\+\|''>\|\$\)\|%\)\?\<s\%[ubstitute]\([][!"#''()-=^,/;:@`]\).\+\4&\?\([cegiInp#lr]*\)$')
			if matchl != [] && matchl[5] =~# 'c'
				return true
			endif
		endif
		return false
	enddef

	if Type(getcmdtype(), getcmdline())
		setlocal scrolloff=2
		return
	elseif Type(getcmdwintype(), getline('.'))
		setlocal scrolloff=2
		return
	endif
	setlocal scrolloff<
	return
enddef

export def ToggleTabLine(): void # タブラインをトグル (色の変更については、autocmd ColorScheme に対応していない)
	def GetCursorLine(r0: number, g0: number, b0: number, r1: number, g1: number, b1: number): string # CursorLine の guibg を取得
		# 無ければ Solarized を基本に Normal 背景色より少し明るい/暗い色を計算
		var hlget_dic: dict<any> = hlget('CursorLine')[0]
		if has_key(hlget_dic, 'guibg')
			return hlget_dic.guibg
		endif
		hlget_dic = hlget('Normal')[0]
		if !has_key(hlget_dic, 'guibg')
			return &background ==? 'light' ? '#eee8d5' : '#073642'
		endif
		var bg: string = hlget_dic.guibg
		return printf('#%02x%02x%02x',      # ↓ Normal - ColorLine の色を引きたいので、-+ 逆転
			str2nr(strpart(bg, 0, 2), 16) - r0 + r1, # Red
			str2nr(strpart(bg, 2, 2), 16) - g0 + g1, # Green
			str2nr(strpart(bg, 4, 2), 16) - b0 + b1  # Blue
		)
	enddef

	var bg: string
	if &showtabline == 0
		if &background ==# 'light'
			bg = GetCursorLine(0xfd, 0xf6, 0xe3, 0xee, 0xe8, 0xd5)
			execute 'highlight TabLineSel   term=bold,underline cterm=bold,underline gui=bold,underline ctermfg=0 ctermbg=7 guifg=#111111 guibg=' .. bg
			         highlight TabLine      term=underline cterm=underline gui=underline ctermfg=8 ctermbg=NONE guifg=#839496 guibg=NONE
			         highlight TabLineFill  term=underline cterm=underline gui=underline ctermfg=8 ctermbg=NONE guifg=#839496 guibg=NONE
		else
			bg = GetCursorLine(0x00, 0x2b, 0x36, 0x07, 0x36, 0x42)
			execute 'highlight TabLineSel   term=bold,underline cterm=bold,underline gui=bold,underline ctermfg=15 ctermbg=0 guifg=#dddddd guibg=' .. bg
			         highlight TabLine      term=underline cterm=underline gui=underline ctermfg=14 ctermbg=NONE guifg=#93a1a1 guibg=NONE
			         highlight TabLineFill  term=underline cterm=underline gui=underline ctermfg=14 ctermbg=NONE guifg=#93a1a1 guibg=NONE
		endif
		set showtabline=2
	else
		set showtabline=0
	endif
enddef

export def BlinkIdleTimer(Blink: func(): number, Stop: func(): number): void # タイマーを再起動してアイドル監視をセット
	BlinkTimerStop(Blink)
	g:blink_idle_timer = timer_start(3000, ((_) => Stop()))
enddef

export def BlinkTimerStop(Blink: func(): number): void # タイマーを止める
	if get(g:, 'blink_idle_timer', -1) == -1
		return
	endif
	Blink()
	timer_stop(g:blink_idle_timer)
	g:blink_idle_timer = -1
enddef

export def BlinkIdleTimerCheckPOS(Blink: func(): number, Stop: func(): number): void
	# <PageUP>/<PageDown> ではカーソルの点滅状況を変えない
	var l: number = line('.')
	var c: number = col('.')
	if ( l - &scrolloff == line('w0') || l + &scrolloff == line('w$') ) # カーソル位置が &scrolloff を加味した表示範囲の最上/下行
			&& ( c == 1 || getline(l)[ : c - 2] =~# '^\s\+$' ) # 先頭桁かカーソル前は空白文字のみ
		return
	elseif &filetype ==# 'notmuch-show' && search('\%^\(\%([A-Za-z-]\+:\s\+\).\+\n\)*.*\%#', 'bcn') == 1 # メール・ヘッダの中
		BlinkTimerStop(Blink)
		return
	endif
	vimrc#BlinkIdleTimer(Blink, Stop)
enddef

export def BackupViminfo(): void # $MYVIMDIR/cache/viminfo をバックアップ
	if systemlist('cmp -s ' .. $MYVIMDIR .. 'cache/viminfo ' .. $MYVIMDIR .. 'cache/viminfo.0 ; echo $?') == ['0']
		return
	endif
	for i in range(1, 9)->reverse()
		if filereadable($MYVIMDIR .. 'cache/viminfo.' .. (i - 1))
			rename($MYVIMDIR .. 'cache/viminfo.' .. (i - 1), $MYVIMDIR .. 'cache/viminfo.' .. i)
		endif
	endfor
	filecopy($MYVIMDIR .. 'cache/viminfo', $MYVIMDIR .. 'cache/viminfo.0')
enddef
