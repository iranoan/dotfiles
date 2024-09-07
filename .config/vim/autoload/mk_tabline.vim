vim9script
scriptencoding utf-8

export def CUI(): string
	var s = ''
	var j: number
	for i in range(tabpagenr('$'))
		j = i + 1
		if j == tabpagenr() # 強調表示グループの選択
			s ..= '%#TabLineSel#'
		else
			s ..= '%#TabLine#'
		endif
		s ..= '%' .. j .. 'T' # タブページ番号の設定 (マウスクリック用)
		var wincount = tabpagewinnr(j, '$')
		if wincount > 1
			s ..= j .. ',' .. wincount
		else
			s ..= j
		endif
		s ..= Label(j) .. '|'
	endfor
	return s .. '%#TabLineFill#%T%=%#TabLine#%999XX' # 最後のタブページの後は TabLineFill で埋め、タブページ番号をリセットする
enddef

export def GUI(): string
	var label: string = '%N|'
	var c_win = tabpagewinnr(v:lnum)
	var info: dict<any>
	# ウィンドウが複数あるときにはその数を追加する
	var wincount = tabpagewinnr(v:lnum, '$')
	if wincount > 1
		label ..= wincount
	endif
	# このタブページに変更のあるバッファは '+' を追加する
	for bufnr in tabpagebuflist(v:lnum)
		if getbufvar(bufnr, '&modified') && !get(getwininfo(getbufinfo(bufnr)[0]['windows'][0])[0], 'terminal', 0)
			label ..= '+'
			break
		endif
	endfor
	if label !~# '+$'
		label ..= '  ' # 空白 1 つでは、+ より幅が狭い
	endif
	# :terminal や filetype 別にを分ける
	for id in gettabinfo(v:lnum)[0]['windows']
		info = getwininfo(id)[0]
		if info.winnr == c_win
			if get(info, 'terminal', 0)
				return label .. substitute(&shell, '^.\+/', '!', '') #.. ' [' .. substitute(getcwd(), '^' .. $HOME, '~', '') .. ']' # ← cd 未対応 pwd もダメ
			endif
			if &filetype =~# '^notmuch-'
				return '%N|  ' .. notmuch_py#GetGUITabline()
			elseif &filetype ==# 'fugitive' || &filetype == 'git'
				return label .. '%y'
			endif
			break
		endif
	endfor
	return label .. ' %t'
enddef

def Label(n: number): string
	var buflist = tabpagebuflist(n)
	var name = substitute(bufname(buflist[tabpagewinnr(n) - 1]), '^.\+/', '', '')
	var change = ''
	for bufnr in buflist
		if getbufvar(bufnr, '&modified') && !get(getwininfo(getbufinfo(bufnr)[0]['windows'][0])[0], 'terminal', 0)
			change = '+'
			break
		endif
	endfor
	if name != ''
		if &filetype ==# 'notmuch-edit'
			return change .. ' ' .. b:notmuch.subject .. ' ' .. b:notmuch.date
		else
			return change .. ' ' .. name
		endif
	else
		if system('echo $LANGUAGE') !~? '^ja:'
			return change .. ' ' .. '[No Name]'
		else
			return change .. ' ' .. '[無題]'
		endif
	endif
enddef
