scriptencoding utf-8

function set_speeddating#main(cmd) abort
	let g:speeddating_no_mappings = 1
	call set_map_plug#Main('vim-speeddating', a:cmd, [
				\ {'mode': 'n', 'key': 'd<C-X>', 'cmd': 'SpeedDatingNowLocal'},
				\ {'mode': 'n', 'key': 'd<C-A>', 'cmd': 'SpeedDatingNowUTC'},
				\ {'mode': 'x', 'key': '<C-X>',  'cmd': 'SpeedDatingDown'},
				\ {'mode': 'x', 'key': '<C-A>',  'cmd': 'SpeedDatingUp'},
				\ {'mode': 'n', 'key': '<C-X>',  'cmd': 'SpeedDatingDown'},
				\ {'mode': 'n', 'key': '<C-A>',  'cmd': 'SpeedDatingUp'}
				\ ] )
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
endfunction
