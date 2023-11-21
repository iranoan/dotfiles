scriptencoding utf-8

function! set_speeding#main() abort
	let g:speeddating_no_mappings = 1
	packadd vim-speeddating
	SpeedDatingFormat! %H:%M:%S
	SpeedDatingFormat! %a %b %_d %H:%M:%S %Z %Y
	SpeedDatingFormat! %a %h %-d %H:%M:%S %Y %z
	SpeedDatingFormat! %B %o, %Y
	SpeedDatingFormat! %d%[-/ ]%b%1%y
	SpeedDatingFormat! %d%[-/ ]%b%1%Y
	SpeedDatingFormat! %Y %b %d
	SpeedDatingFormat! %b %d, %Y
	SpeedDatingFormat! %-I%?[ ]%^P
	SpeedDatingFormat %Y/%m/%d(%a)%?[ ]%H:%M:%S
	SpeedDatingFormat %Y/%m/%d(%a)%?[ ]%H:%M
	SpeedDatingFormat %Y/%m/%d%[ T_:]%H:%M:%S
	SpeedDatingFormat %Y/%m/%d%[ T_:]%H:%M
	SpeedDatingFormat %Y/%m/%d
	SpeedDatingFormat %m/%d
	SpeedDatingFormat %^P%?[ ]%I:%M
	SpeedDatingFormat %H:%M:%S
	SpeedDatingFormat %H:%M
	" nnoremap d<C-X> <Plug>SpeedDatingNowLocal←上手く動作していない
	nnoremap d<C-A> <Plug>SpeedDatingNowUTC
	xnoremap <C-X>  <Plug>SpeedDatingDown
	xnoremap <C-A>  <Plug>SpeedDatingUp
	nnoremap <C-X>  <Plug>SpeedDatingDown
	nnoremap <C-A>  <Plug>SpeedDatingUp
endfunction
