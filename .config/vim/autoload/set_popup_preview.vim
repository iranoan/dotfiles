scriptencoding utf-8

function set_popup_preview#init()
	if !pack_manage#IsInstalled('popup_image')
		call set_popup_image#init()
	endif
	" 2}}}"
	" 選択パスのプレビュー $MYVIMDIR/pack/my-plug/opt/popup_preview/ {{{2
	let g:popup_preview = #{
				\ image: ['epub', 'odp', 'pptx', 'pdf', 'eps', 'ps', 'cbz'],
				\ filter: #{
				\ 		mp3: #{cmd: ['ffprobe', '-hide_banner']},
				\ 		m4a: #{cmd: ['ffprobe', '-hide_banner']},
				\ 		xlsx: #{cmd: ['xlsx2table.sh']},
				\ 		ods: #{cmd: ['xlsx2table.sh']},
				\ 		odt: #{cmd: ['soffice', '--headless', '--convert-to', '"txt:Text (encoded):UTF8"', '--cat']},
				\ 		docx: #{cmd: ['soffice', '--headless', '--convert-to', '"txt:Text (encoded):UTF8"', '--cat']},
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
