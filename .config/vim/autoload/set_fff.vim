scriptencoding utf-8

function set_fff#main() abort
	let g:popup_image_pt2px = #{x: 131, y: 154}
	packadd popup_image
	let g:fuzzy_file_finder = #{cmd: ['fdfind.sh'], open: 'TabEdit'}
	packadd fuzzy-file-finder
	call timer_start(1, {->execute('delfunction set_fff#main')})
endfunction

