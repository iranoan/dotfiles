scriptencoding utf-8

function! set_popup_image#init() abort
	" バイナリ判定+辞書データの子要素も含めてマージ $MYVIMDIR/pack/my-plug/opt/general-function/ {{{2
	packadd general-function
	" 2}}}"
	let g:popup_image_options = #{
				\ pt2px: #{x: 131, y: 154},
				\ plugin: {
				\ 	'application/epub+zip': 'popup_image#epub#SaveCoverImage',
				\ 	'application/vnd.openxmlformats-officedocument.presentationml.presentation': 'popup_image#pptx#SaveCoverImage',
				\ 	'application/vnd.oasis.opendocument.presentation': 'popup_image#pptx#SaveCoverImage',
				\ 	}
				\ }
	" 画像などのプレビュー $MYVIMDIR/pack/my-plug/opt/popup_image/ {{{2
	packadd popup_image
	call timer_start(1, {->execute('delfunction set_popup_image#init')})
endfunction
