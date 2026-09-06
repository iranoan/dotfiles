scriptencoding utf-8

function set_popup_preview#init()
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
	" 2}}}"
	" 選択パスのプレビュー $MYVIMDIR/pack/my-plug/opt/popup_preview/ {{{2
	let g:popup_preview = #{
				\ image: ['epub', 'odp', 'pptx'],
				\ filter: #{
				\ 		mp3: ['ffprobe', '-hide_banner'],
				\ 		m4a: ['ffprobe', '-hide_banner'],
				\ 		xlsx: ['xlsx2table.sh'],
				\ 		ods: ['xlsx2table.sh'],
				\ 		odt: ['soffice', '--headless', '--convert-to', '"txt:Text (encoded):UTF8"', '--cat'],
				\ 		docx: ['soffice', '--headless', '--convert-to', '"txt:Text (encoded):UTF8"', '--cat'],
				\ 	}
				\}
	packadd popup_preview
	" 2}}}"
	let g:fuzzy_file_finder = #{
				\ cmd: ['fdfind.sh'],
				\ open: 'TabEdit',
				\ image: ['epub'],
				\}
	call timer_start(1, {->execute('delfunction set_popup_preview#init')})
endfunction
