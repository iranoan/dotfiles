vim9script
scriptencoding utf-8

export def Main(): string
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
		s ..= '%{mk_tabline#Label(' .. j .. ')} | '
	endfor
	return s .. '%#TabLineFill#%T%=%#TabLine#%999XX' # 最後のタブページの後は TabLineFill で埋め、タブページ番号をリセットする
enddef

export def Label(n: number): string
	var buflist = tabpagebuflist(n)
	var name = substitute(bufname(buflist[tabpagewinnr(n) - 1]), '^.\+/', '', '')
	var change = ''
	for bufnr in buflist
		if getbufvar(bufnr, '&modified')
					\ && !( match(getbufinfo(bufnr)[0].name, '!/') == 0 && swapname(bufnr) ==# '' )
			# 名前が !/bin/bash 等で !/ ではじまり、スワップ・ファイルがなければ :terminal の可能性が高い
			change = '+'
			break
		endif
	endfor
	if name != ''
		return change .. ' ' .. name
	else
		if system('echo $LANGUAGE') !~? '^ja:'
			return change .. ' ' .. '[No Name]'
		else
			return change .. ' ' .. '[無題]'
		endif
	endif
enddef
