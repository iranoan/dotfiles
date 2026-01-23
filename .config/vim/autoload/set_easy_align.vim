scriptencoding utf-8

function set_easy_align#main() abort
	call pack_manage#SetMAP('vim-easy-align', '(EasyAlign)', [
			\ #{mode: 'n', key: '<Leader>ea', cmd: '(EasyAlign)'},
			\ #{mode: 'x', key: '<Enter>',    cmd: '(EasyAlign)'},
			\ #{mode: 'x', key: '<Leader>ea', cmd: '(EasyAlign)'}
			\ ] )
	let g:easy_align_delimiters = {
				\ '|': #{ align: 'al*' },
				\ '&': #{ align: 'al*' },
				\ 't': #{
				\        	pattern: '\t',
				\        	left_margin:   0,
				\        	right_margin:  0,
				\        	align: 'al*'
				\       },
				\ 'h': #{
				\        	pattern: '<\(t[hd]\|/tr\)>',
				\        	left_margin:   0,
				\        	right_margin:  0,
				\        	align: 'al*'
				\       },
				\ }
	" t は Tab 文字
	" h は HTML table (<tr>を対象に含めないのは、行頭タブも空白に変換されるため)
	call timer_start(1, {->execute('delfunction set_easy_align#main')})
endfunction
