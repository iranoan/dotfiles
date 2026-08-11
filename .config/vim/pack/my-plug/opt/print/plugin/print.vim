vim9script
scriptencoding utf-8

if exists('g:loaded_print')
	finish
endif
g:loaded_print = true

set printencoding=utf-8
if has('pango')
	if has('gui_running')
		&printfont = &guifont
	else
		var fonts: list<string>
		var size: string = ':h11'
		if has('mac')
			fonts = systemlist("system_profiler SPFontsDataType | grep '^[[:space:]]*Family:'")
				->map((_, v) => substitute(v, '^[[:space:]]*Family:[[:space:]]*', '', ''))
		elseif has('unix')
			fonts = systemlist(['fc-list', ':style=Regular'])
				->map((_, v) => substitute(v, '^[^:]\+: \([^:]\+\):style=.\+', '\1', ''))
			size = '\ 11'
		elseif has('win32')
			fonts = systemlist('powershell -NoProfile -Command "Get-ItemProperty ''HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'' | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name"')
				->map((_, v) => substitute(v, '\s*([^)]*)$', '', ''))
				->map((_, v) => split(v, '\s*&\s*'))
				->flattennew()
		endif
		for f in ['UDEV Gothic NF', 'Noto Mono', 'BIZ UDGothic', 'Menlo', 'Cascadia Mono', 'Monaco', 'Consolas', 'Courier', 'MS Gothic', 'Monospace']
			if count(fonts, f) != 0
				execute ($'set printfont={escape(f, " ")}{size}')
				break
			endif
		endfor
	endif
else
	set printmbcharset=UniJIS2004 # ln -s /usr/share/fonts/cmap/adobe-japan1/UniJIS2004-UTF8-H "$HOME/.config/vim/print/UniJIS2004-UTF8-H.ps"
	# set printfont=Japanese-Mincho-Regular:h11 printmbfont=r:Japanese-Mincho-Regular
	# 印刷 hardcopy で Japanese-Mincho-Regular など標準的なフォントが使えない時は、{{{
	# sudo apt install fonts-ipafont
		set printfont=Japanese-Gothic-Regular:h11 printmbfont=r:Japanese-Gothic-Regular # ←ゴチック体
	# /var/lib/ghostscript/fonts/cidfmap に
	# /RictyDiminished-Regular << /FileType /TrueType /Path (/usr/share/fonts/truetype/ricty-diminished/RictyDiminished-Regular.ttf) /SubfontID 0 /CSI [(Japan1) 4] >> ;
	# を使えば、↓で Ricty Diminished 等も使える
	# set printfont=RictyDiminished-Regular:h11 printmbfont=r:RictyDiminished-Regular,b:RictyDiminished-Bold,i:RictyDiminished-Oblique,o:RictyDiminished-Oblique
	# set printfont=UDEVGothicNF-Regular:h11  printmbfont=r:UDEVGothicNF-Regular,b:UDEVGothicNF-Bold,i:UDEVGothicNF-Oblique,o:UDEVGothicNF-Oblique
	# set printfont=JetBrainsMono-Regular:h11  printmbfont=r:BIZUDPGothic-Regular,b:BIZUDPGothic-Bold,i:BIZUDPGothic-Oblique,o:BIZUDPGothic-Oblique
	# }}}
	set printmbfont+=,c:yes,a:yes                   # ASCII 文字の扱い (これ以外の組み合わせは~が化ける)
endif
set printheader=%y%h%<%F%m%=%N
set printoptions=number:y,formfeed:y,left:5mm,right:5mm,top:5mm,bottom:5mm # 行番号印刷、改ページ文字を処理し、現在の行を新しいページに印刷

command! -range=% PrintBuffer call print#Main(<line1>, <line2>)
