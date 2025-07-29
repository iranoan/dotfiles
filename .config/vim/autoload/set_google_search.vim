scriptencoding utf-8

function set_google_search#main() abort
	call pack_manage#SetMAP('google-search', 'SearchByGoogle', [
			\ #{mode: 'n', key: '<silent><Leader>s', method: 1, cmd: 'SearchByGoogle'},
			\ #{mode: 'x', key: '<silent><Leader>s', method: 2, cmd: 'SearchByGoogle'},
			\ ])
endfunction
