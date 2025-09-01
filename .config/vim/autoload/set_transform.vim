scriptencoding utf-8

function set_transform#main(cmd) abort
	call pack_manage#SetMAP('transform', a:cmd, [
				\ #{mode: 'n', key: '<Leader>ha', method: 1, cmd: 'Zen2han'},
				\ #{mode: 'x', key: '<Leader>ha', method: 2, cmd: 'Zen2han'},
				\ #{mode: 'n', key: '<Leader>hh', method: 1, cmd: 'InsertSpace'},
				\ #{mode: 'x', key: '<Leader>hh', method: 2, cmd: 'InsertSpace'},
				\ #{mode: 'n', key: '<Leader>hz', method: 1, cmd: 'Han2zen'},
				\ #{mode: 'x', key: '<Leader>hz', method: 2, cmd: 'Han2zen'},
				\ #{mode: 'n', key: '<Leader>hk', method: 1, cmd: 'Hira2kata'},
				\ #{mode: 'x', key: '<Leader>hk', method: 2, cmd: 'Hira2kata'},
				\ #{mode: 'n', key: '<Leader>hH', method: 1, cmd: 'Kata2hira'},
				\ #{mode: 'x', key: '<Leader>hH', method: 2, cmd: 'Kata2hira'}
				\ ] )
				" #{mode: 'n', key: '<Leader>hb', method: 1, cmd: 'Base64'},
	call timer_start(1, {->execute('delfunction set_transform#main')})
endfunction
