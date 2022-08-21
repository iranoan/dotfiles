scriptencoding utf-8
" 選択範囲もしくは全体をフィルタにかける
" シェルスクリプトは UTF-8 前提なので一度 fileencoding を変える
" カーソル位置は元に戻す
"
function s:main( command, select, opt ) abort " この関数が範囲選択状態で受け取るようにしたいが、別の関数から呼び出された時に既に範囲選択が解除されてしまっている
	let pos=getpos('.')
	let search = @/
	let encodes=&fileencodings
	let &l:fileencodings='utf-8'
	let encode=&fileencoding
	let &l:fenc='utf-8'
	normal! H
	let win_pos = getpos('.')
	if a:select
		silent execute 'silent ' . getcharpos("'<")[1] . ',' . getcharpos("'>")[1] . '!' . a:command . ' ' . a:opt
	else
		silent execute 'silent %!' . a:command . ' ' . a:opt
	endif
	let &l:fenc=encode
	let &l:fileencodings=encodes
	let @/ = search
	call setpos('.', win_pos)
	normal! zt
	call setpos('.', pos)
	echo 'filtering by ' . substitute(a:command, ' .\+','','')
endfunction

function shell_filter#Zen2ASCII( select ) range abort
	call s:main( 'zen2ascii.sh', a:select, '' )
endfunction

function shell_filter#InsertSpace( select ) range abort
	call s:main( 'insert-space.sh', a:select, '' )
endfunction

function shell_filter#han2zen( select ) range abort
	call s:main( 'han2zen.sh', a:select, '' )
endfunction

function shell_filter#hira2kata( select ) range abort
	call s:main( 'hira2kata.sh', a:select, '' )
endfunction
