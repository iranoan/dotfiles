scriptencoding utf-8
" 印刷の設定と印刷用に色の指定
" 特に GUI だと一部のシンタックスの背景が set background=dark のままになるのをごまかす
" VIM - Vi IMproved 9.1 (2024 Jan 02, compiled Nov 16 2024 12:55:23) の時点で、Normal は問題なくなった

set printencoding=utf-8
set printmbcharset=UniJIS2004 " ln -s /usr/share/fonts/cmap/adobe-japan1/UniJIS2004-UTF8-H "$HOME/.vim/print/UniJIS2004-UTF8-H.ps"
" set printfont=Japanese-Mincho-Regular:h11 printmbfont=r:Japanese-Mincho-Regular
" 印刷 hardcopy で Japanese-Mincho-Regular など標準的なフォントが使えない時は、{{{
" sudo apt install fonts-ipafont
set printfont=Japanese-Gothic-Regular:h11 printmbfont=r:Japanese-Gothic-Regular " ←ゴチック体
" /var/lib/ghostscript/fonts/cidfmap に
" /RictyDiminished-Regular << /FileType /TrueType /Path (/usr/share/fonts/truetype/ricty-diminished/RictyDiminished-Regular.ttf) /SubfontID 0 /CSI [(Japan1) 4] >> ;
" を使えば、↓で Ricty Diminished 等も使える
" set printfont=RictyDiminished-Regular:h11 printmbfont=r:RictyDiminished-Regular,b:RictyDiminished-Bold,i:RictyDiminished-Oblique,o:RictyDiminished-Oblique
" set printfont=UDEVGothicNF-Regular:h11  printmbfont=r:UDEVGothicNF-Regular,b:UDEVGothicNF-Bold,i:UDEVGothicNF-Oblique,o:UDEVGothicNF-Oblique
" set printfont=JetBrainsMono-Regular:h11  printmbfont=r:BIZUDPGothic-Regular,b:BIZUDPGothic-Bold,i:BIZUDPGothic-Oblique,o:BIZUDPGothic-Oblique
" }}}
set printmbfont+=,c:yes,a:yes                   " ASCII 文字の扱い (これ以外の組み合わせは~が化ける)
set printheader=%y%F%m%=%N
set printoptions=number:y,formfeed:y,left:5mm,right:5mm,top:5mm,bottom:5mm " 行番号印刷、改ページ文字を処理し、現在の行を新しいページに印刷

function s:set_none(s) abort
	let s = a:s
	for var in ['ctermfg', 'ctermbg', 'guifg', 'guibg']
		if s !~# '\<' .. var .. '='
			let s ..= ' ' .. var .. '=NONE'
		endif
	endfor
	return s
endfunction

function print#Main(first, last) range abort
	" linewidth=4 で固定されていて変えられない
	" let l:normal = substitute(substitute(substitute(execute('highlight Normal'), '[\n\r]\+', '', 'g'), ' *Normal\s\+xxx *', '', ''), 'font=.*', '', 'g')
	let l:linenr = substitute(substitute(execute('highlight LineNr'), '[\n\r]\+', '', 'g'), ' *LineNr\s\+xxx *', '', '')
	" highlight Normal guifg=#000000 guibg=#FFFFFF gui=NONE cterm=NONE ctermfg=black ctermbg=white
	highlight LineNr guifg=#000000 guibg=#FFFFFF gui=bold cterm=bold ctermfg=black ctermbg=white
	execute a:first .. ',' .. a:last .. 'hardcopy'
	" execute 'highlight Normal ' .. s:set_none(l:normal)
	execute 'highlight LineNr ' .. s:set_none(l:linenr)
endfunction
