vim9script

def MaxWidthHeight(): dict<number>
	return {
		maxheight: max([min([25, &lines]), &lines / 2]),
		maxwidth: max([min([85, &columns / 2]), &columns / 3]),
		opacity: 0
	}
enddef

var id: number = popup_create('', extendnew({hidden: true, tabpage: -1}, MaxWidthHeight()))

augroup completePopupPreviewImage
	autocmd!
	autocmd CompleteChanged * Change()
	autocmd CompleteDone    * Hide()
	autocmd InsertLeave     * Hide()
	autocmd VimResized      * Resize()
augroup END

def GetPath(): string
	var f: string = extendnew({word: ''}, get(v:event, 'completed_item', {})).word
	var line: string
	var last_quote: number


	if f !~# '/' # 元々のバッファの記載、もしくは補完候補の文字列がファイル名のみ
		line = getline('.')[ : col('.') - 2]
		if line =~# '[[''"(]' # ", ' [], () に挟まれている場合を想定して、カーソル位置より前にその記号があれば、それ以降を取得
			line = line[ max([strridx(line, "'"), strridx(line, '"'), strridx(line, '['), strridx(line, '(')]) + 1 : ]
		else # カーソル位置までの英数, _, - と / のみをパスの記述とする
			line = matchstr(line, '[A-Za-z0-9/_-]\+$')
		endif
		if line =~# '/'
			line = fnamemodify(line, ':h')
			if line !=# '.'
				f = $"{line}/{f}"
			endif
		endif
	endif
	f = simplify(f)->expand()->resolve()
	if !filereadable(f) || index(g:complete_preview_image, fnamemodify(f, ':e')) == -1
		return ''
	endif
	return f
enddef

def SetPosition(event: dict<any>): void
	var col: number
	var line: number = event.row + 1
	var w_h: dict<any> = popup_getoptions(id)->filter((k, _) => k =~# '^max\(width\|height\)')
	var diff: number = (line + w_h.maxheight) - &lines
	var curscol: number = screenpos(0, line('.'), col('.')).curscol

	if event.col + event.width + 2 + w_h.maxwidth > &columns # 右に空きスペースが足りない
		col = max([1, event.col - w_h.maxwidth])
	else
		col = event.col + event.width + 2
	endif
	if diff > 0 # プレビュー画像下に飛び出る
		line -= diff
	endif
	popup_setoptions(id, {col: col, line: line})
	popup_show(id)
enddef

export def Change(): void
	var event: dict<any> = deepcopy(v:event)
	if !pumvisible() || event == {} || index(popup_list(), id) == -1
		return
	endif
	var p: string = GetPath()

	if p ==# ''
		popup_hide(id)
		return
	endif
	popup_image#Preview(id, p, -2, (v) => {
			if v
				SetPosition(event)
			else
				popup_image#WarningMsg(id)
			endif
		})
enddef

def Hide(): void
	if index(popup_list(), id) != -1
		popup_setoptions(id, {image: {}})
		popup_hide(id)
	endif
enddef

def Resize(): void
	if index(popup_list(), id) == -1
		return
	endif
	var opts: dict<any> = getwinvar(id, 'popup_image', {options: {}})

	extend(opts.options, MaxWidthHeight())
	popup_setoptions(id, opts.options)
enddef
