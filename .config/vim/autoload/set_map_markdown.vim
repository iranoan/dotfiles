scriptencoding utf-8

function! set_map_markdown#main() abort
	packadd map-markdown
	" マップの付け直し↓ただし隠しバッファの場合付け直しが行われない制限が有る
	for b in getbufinfo()
		let t = getbufvar(b.bufnr, '&filetype')
		if t ==# 'markdown'
			for w in b.windows
				call win_execute(w, 'inoremap <buffer><expr><Space> map_markdown#Space()')
				call win_execute(w, 'inoremap <buffer><expr><BS>    map_markdown#BackSpace()')
				call win_execute(w, 'inoremap <buffer><expr><Tab>   map_markdown#Tab()')
				call win_execute(w, 'inoremap <buffer><expr><CR>    map_markdown#Enter()')
				break " 複数ウィンドウで開いていても、バッファ単位のマッピングなので
			endfor
		endif
	endfor
	augroup MapMarkdown
		autocmd!
		" 箇条書きと強調の区別→* の後 <Space> ではカーソル右が * ならば箇条書きとして削除
		inoremap <buffer><expr><Space> map_markdown#Space()
		" 強調の取り消しなどのため前後の文字が同じ記号/箇条書きのインデントなら纏めて消す
		inoremap <buffer><expr><BS>    map_markdown#BackSpace()
		" 箇条書きの入れ子のため上の行によって空白文字の入力個数を変える
		inoremap <buffer><expr><Tab>   map_markdown#Tab()
		" マークダウン記法は行末で「半角スペース」を「2個」連続入力すると、以降の文章を改行する→それを踏まえて、箇条書きでは行頭に同じ記号を追加する
		inoremap <buffer><expr><CR>    map_markdown#Enter()
	augroup END
endfunction
