scriptencoding utf-8

function set_popup_preview#init()
	" バイナリ判定+辞書データの子要素も含めてマージ $MYVIMDIR/pack/my-plug/opt/general-function/ {{{2
	packadd general-function
	" 2}}}"
	let g:popup_image_options = #{pt2px: #{x: 131, y: 154}}
	" 画像などのプレビュー $MYVIMDIR/pack/my-plug/opt/popup_image/ {{{2
	packadd popup_image
	" 2}}}"
	" 選択パスのプレビュー $MYVIMDIR/pack/my-plug/opt/popup_preview/ {{{2
	let g:popup_preview = #{
				\ image: ['epub'],
				\ filter: #{
				\ 		mp3: ['ffprobe', '-hide_banner'],
				\ 		m4a: ['ffprobe', '-hide_banner'],
				\ 		pptx: ['pptx2text.sh'],
				\ 		odp: ['odp2text.sh'],
				\ 		xlsx: ['xlsx2table.sh'],
				\ 		ods: ['xlsx2table.sh'],
				\ 		odt: ['soffice', '--convert-to', '"txt:Text', '(encoded):UTF8"', '--cat'],
				\ 		docx: ['soffice', '--convert-to', '"txt:Text', '(encoded):UTF8"', '--cat'],
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
