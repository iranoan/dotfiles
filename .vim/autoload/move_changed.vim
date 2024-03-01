vim9script
# カーソルリストの前後に有る変更箇所に移動
# g;, g, は時間軸で移動するが、これは位置を軸として移動

export def Main(move_rear: bool): void
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
	# echomsg change
	if len(change) == 0
		echo 'No Change in ' .. (move_rear ? 'rear' : 'front')
		return
	endif
	if move_rear
		pos = sort(change, BigSmall)[0]
	else
		pos = sort(change, BigSmall)[-1]
	endif
	# echomsg pos
	# echomsg col('.') .. ' ' .. col('$')
	setpos('.', [bufnr(), pos.lnum, pos.col, 0])
	echo ''
enddef
