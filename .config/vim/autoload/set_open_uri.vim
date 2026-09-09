scriptencoding utf-8

function set_open_uri#main() abort
	call pack_manage#SetMAP('open_uri', 'call open_uri#main()', [
				\ #{mode: 'n', key: '<silent><Leader>x', method: 1, cmd: 'call open_uri#main()'},
				\ #{mode: 'x', key: '<2-LeftMouse>',     method: 1, cmd: 'call open_uri#main()'},
				\ ] )
	call timer_start(1, {->execute('delfunction set_open_uri#main')})
endfunction
