scriptencoding utf-8

function set_web_search#main(cmd) abort
	call pack_manage#SetMAP('web-search', a:cmd, [
			\ #{mode: 'n', key: '<silent><Leader>s', method: 1, cmd: 'SearchByGoogle'},
			\ #{mode: 'x', key: '<silent><Leader>s', method: 2, cmd: 'SearchByGoogle'},
			\ #{mode: 'n', key: '<silent><Leader>sa', method: 1, cmd: 'SearchByAmazon'},
			\ #{mode: 'x', key: '<silent><Leader>sa', method: 2, cmd: 'SearchByAmazon'},
			\ #{mode: 'n', key: '<silent><Leader>sw', method: 1, cmd: 'SearchByWikiPedia'},
			\ #{mode: 'x', key: '<silent><Leader>sw', method: 2, cmd: 'SearchByWikiPedia'},
			\ ])
	call timer_start(1, {->execute('delfunction set_web_search#main')})
endfunction
