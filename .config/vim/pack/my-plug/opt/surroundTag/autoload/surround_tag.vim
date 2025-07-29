vim9script
scriptencoding utf-8

export def SurroundTag(...tag: list<string>): void
	# add_tag: 追加タグ <ruby><rp>(</rp><rt></rt><rp>)</rp></ruby> 等
	if mode() =~? '^v'
		execute "normal! \<Esc>"
	else
		execute "normal! viw\<Esc>"
	endif
	var close: string
	for s in split(tag[0],  '[<>/]\+')
		close = '</' .. matchstr(s, '[^ ]\+') .. '>' .. close
	endfor
	var open_pos: list<number> = getpos("'<")
	var close_pos: list<number> = getpos("'>")
	var line: string = getline("'>")
	var shift_close: number = strlen(matchstr(line, '.', close_pos[2] - 1))
	if len(tag) > 1
		close = tag[1] .. close
	endif
	setline("'>", strpart(line, 0, close_pos[2] + shift_close - 1) .. close .. strpart(line, close_pos[2] + shift_close - 1))
	line = getline("'<")
	setline("'<", strpart(line, 0, open_pos[2] - 1) .. tag[0] .. strpart(line, open_pos[2] - 1))
	if len(tag) > 1 # 追加タグが有る場合
		setpos('.', [0, close_pos[1], close_pos[2] + len(tag[0]) + shift_close, 0])
	elseif getpos("'<")[1] == close_pos[1] # 選択開始・最後が同一行
		setpos('.', [0, close_pos[1], close_pos[2] + len(tag[0]) + len(close) + shift_close, 0])
	else
		setpos('.', [0, close_pos[1], close_pos[2] + len(close), 0])
	endif
enddef
