scriptencoding utf-8

function! set_popup_image#init() abort
	if !pack_manage#IsInstalled('general-function')
		call set_general_function#init()
	endif
	let g:popup_image_options = #{
				\ pt2px: #{x: 131, y: 154},
				\ raw: {'application/epub+zip': 'popup_image#stdout#Epub'},
				\ plugin: {
				\ 	'application/vnd.openxmlformats-officedocument.presentationml.presentation': 'popup_image#save#PptxOdp',
				\ 	'application/vnd.oasis.opendocument.presentation': 'popup_image#save#PptxOdp',
				\ 	}
				\ }
	" 画像などのプレビュー $MYVIMDIR/pack/my-plug/opt/popup_image/ {{{2
	packadd popup_image
	call timer_start(1, {->execute('delfunction set_popup_image#init')})
endfunction
