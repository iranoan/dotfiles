scriptencoding utf-8

function set_expand_region#main(cmd) abort
	call set_map_plug#Main('vim-expand-region', a:cmd, [
				\ {'mode': 'x', 'key': 'v',  'cmd': '(expand_region_expand)'},
				\ {'mode': 'x', 'key': 'V',  'cmd': '(expand_region_shrink)'}
				\ ] )
	let g:expand_region_text_objects = {
				\ 'iw': 0,
				\ 'iy': 0,
				\ 'ay': 0,
				\ 'iW': 0,
				\ 'i"': 0,
				\ 'a"': 0,
				\ "i'": 0,
				\ "a'": 0,
				\ 'i)': 1,
				\ 'a)': 1,
				\ 'i]': 1,
				\ 'a]': 1,
				\ 'i>': 1,
				\ 'a>': 1,
				\ 'i}': 1,
				\ 'a}': 1,
				\ 'is': 0,
				\ 'ii': 1,
				\ 'ai': 1,
				\ 'iz': 0,
				\ 'az': 0,
				\ 'ip': 0,
				\ 'ap': 0,
				\ }
	call expand_region#custom_text_objects('c', {
				\ 'i>': 1,
				\ 'a>': 1,
				\ 'if': 0,
				\ 'af': 0,
				\ 'i#': 1,
				\ 'a#': 1,
				\ })
	call expand_region#custom_text_objects('cpp', {
				\ 'iy': 0,
				\ 'ay': 0,
				\ 'i>': 1,
				\ 'a>': 1,
				\ 'if': 0,
				\ 'af': 0,
				\ 'i#': 1,
				\ 'a#': 1,
				\ })
	call expand_region#custom_text_objects('tex', {
				\ 'i\\': 0,
				\ 'a\\': 0,
				\ 'i$': 0,
				\ 'a$': 0,
				\ 'iq': 0,
				\ 'aq': 0,
				\ 'iQ': 0,
				\ 'aQ': 0,
				\ })
	call expand_region#custom_text_objects('html', {
				\ 'it': 1,
				\ 'at': 1,
				\ })
	"環境は時間がかかりすぎる
	"\ 'ae': 1,
	"\ 'ie': 1,
endfunction
