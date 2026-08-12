scriptencoding utf-8

function set_fff#main(cmd) abort
	let g:popup_image_options = #{pt2px: #{x: 131, y: 154}}
	" 画像などのプレビュー $MYVIMDIR/pack/my-plug/opt/popup_image/ {{{2
	packadd popup_image
	" 2}}}"
	" 辞書データの子要素も含めてマージ $MYVIMDIR/pack/my-plug/opt/extend-merge/ {{{2
	packadd extend-merge
	" 2}}}"
	let g:fuzzy_file_finder = #{
				\ cmd: ['fdfind.sh'],
				\ open: 'TabEdit',
				\ image: ['epub'],
				\ filter: {
				\ 		'mp3': ['ffprobe', '-hide_banner'],
				\ 		'm4a': ['ffprobe', '-hide_banner'],
				\ 		'pptx': ['pptx2text.sh'],
				\ 		'odp': ['odp2text.sh'],
				\ 		'xlsx': ['xlsx2table.sh'],
				\ 		'ods': ['xlsx2table.sh'],
				\ 		'odt': ['soffice', '--convert-to', '"txt:Text', '(encoded):UTF8"', '--cat'],
				\ 		'docx': ['soffice', '--convert-to', '"txt:Text', '(encoded):UTF8"', '--cat'],
				\ 	}
				\}
	call pack_manage#SetMAP('fuzzy-file-finder', a:cmd, [
				\ #{mode: 'n', key: '<silent><Leader>fr', method: 1, cmd: 'call fff#FFFiles("~")'},
				\ #{mode: 'x', key: '<silent><Leader>fr', method: 1, cmd: 'call fff#FFFiles("~")'},
				\ #{mode: 'n', key: '<silent><Leader>ff', method: 1, cmd: 'call fff#FFFiles()'},
				\ #{mode: 'x', key: '<silent><Leader>ff', method: 1, cmd: 'call fff#FFFiles()'},
				\ #{mode: 'n', key: '<silent><Leader>fu', method: 1, cmd: 'call fff#FFFiles("..")'},
				\ #{mode: 'x', key: '<silent><Leader>fu', method: 1, cmd: 'call fff#FFFiles("..")'},
				\ #{mode: 'n', key: '<silent><Leader>f.', method: 1, cmd: 'call fff#FFFiles("~/dotfiles")'},
				\ #{mode: 'x', key: '<silent><Leader>f.', method: 1, cmd: 'call fff#FFFiles("~/dotfiles")'},
				\ #{mode: 'n', key: '<silent><Leader>fv', method: 1, cmd: 'call fff#FFFiles("$MYVIMDIR")'},
				\ #{mode: 'x', key: '<silent><Leader>fv', method: 1, cmd: 'call fff#FFFiles("$MYVIMDIR")'},
				\ #{mode: 'n', key: '<silent><Leader>fs', method: 1, cmd: 'call fff#FFFiles("~/src")'},
				\ #{mode: 'x', key: '<silent><Leader>fs', method: 1, cmd: 'call fff#FFFiles("~/src")'},
				\ #{mode: 'n', key: '<silent><Leader>fx', method: 1, cmd: 'call fff#FFFiles("~/bin")'},
				\ #{mode: 'x', key: '<silent><Leader>fx', method: 1, cmd: 'call fff#FFFiles("~/bin")'},
				\ #{mode: 'n', key: '<silent><Leader>fe', method: 1, cmd: 'call fff#FFFiles("~/book/epub")'},
				\ #{mode: 'x', key: '<silent><Leader>fe', method: 1, cmd: 'call fff#FFFiles("~/book/epub")'},
				\ #{mode: 'n', key: '<silent><Leader>fd', method: 1, cmd: 'call fff#FFFiles("~/downloads")'},
				\ #{mode: 'x', key: '<silent><Leader>fd', method: 1, cmd: 'call fff#FFFiles("~/downloads")'},
				\ #{mode: 'n', key: '<silent><Leader>fD', method: 1, cmd: 'call fff#FFFiles("~/Document")'},
				\ #{mode: 'x', key: '<silent><Leader>fD', method: 1, cmd: 'call fff#FFFiles("~/Document")'},
				\ #{mode: 'n', key: '<silent><Leader>fp', method: 1, cmd: 'call fff#FFFiles("~/public_html/iranoan")'},
				\ #{mode: 'x', key: '<silent><Leader>fp', method: 1, cmd: 'call fff#FFFiles("~/public_html/iranoan")'},
				\ #{mode: 'n', key: '<silent><Leader>fi', method: 1, cmd: 'call fff#FFFiles("~/Information/slide")'},
				\ #{mode: 'x', key: '<silent><Leader>fi', method: 1, cmd: 'call fff#FFFiles("~/Information/slide")'},
				\ ])
	call timer_start(1, {->execute('delfunction set_fff#main')})
endfunction

