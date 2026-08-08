scriptencoding utf-8

function set_fff#main(cmd) abort
	let g:popup_image_options = #{pt2px: #{x: 131, y: 154}}
	packadd popup_image
	let g:fuzzy_file_finder = #{
				\ cmd: ['fdfind.sh'],
				\ open: 'TabEdit',
				\ image: [
					\ 'anx', 'asf', 'avi', 'axv', 'flc', 'fli', 'flv', 'gl', 'm2v', 'm4v', 'mkv', 'mov', 'mp4', 'mp4v', 'mpeg', 'mpg',
					\ 'nuv', 'ogm', 'ogv', 'ogx', 'qt', 'rm', 'rmvb', 'swf', 'vob', 'webm', 'wmv',
					\ 'avif', 'bmp', 'cgm', 'cr2', 'cur', 'dl', 'dvi', 'emf', 'eps', 'gif', 'ico', 'j2c', 'j2k', 'jp2', 'jpeg', 'jpg',
					\ 'jpf', 'jpx', 'jxl', 'mng', 'nef', 'pbm', 'pcx', 'pgm', 'png', 'ppm', 'svg', 'svgz', 'tga', 'tiff', 'webp',
					\ 'xcf', 'xbm', 'xpm', 'xwd', 'yuv',
					\ 'pdf', 'ps',
					\ 'epub'
				\ ],
				\ filter: {
					\ 	'zip': ['unzip', '-l'],
					\ 	'cbz': ['unzip', '-l'],
					\ 	'tar.gz': ['tar', '-tvf'], 'tgz': ['tar', '-tvf'],
					\ 	'tar.bz2': ['tar', '-tvf'], 'tbz': ['tar', '-tvf'], 'tbz2': ['tar', '-tvf'], 'tb2': ['tar', '-tvf'],
					\ 	'tar.xz': ['tar', '-tvf'], 'txz': ['tar', '-tvf'],
					\ 	'tar.Z': ['tar', '-tvf'], 'taz': ['tar', '-tvf'],
					\ 	'tar.lzma': ['tar', '-tvf'], 'tlz': ['tar', '-tvf'],
					\ 	'gz': ['gzip', '-l'],
					\ 	'bz2':[ 'bzcat'],
					\ 	'xz': ['xz', '-lv'],
					\ 	'7z': ['7z', 'l'],
					\ 	'rar': ['unrar', 'l'],
					\ 	'lzma': ['lzma', '-l'],
					\ 	'mp3': ['ffprobe', '-hide_banner'],
					\ 	'm4a': ['ffprobe', '-hide_banner'],
					\ 	'pptx': ['pptx2text.sh'],
					\ 	'odp': ['odp2text.sh'],
					\ 	'xlsx': ['xlsx2table.sh'],
					\ 	'ods': ['xlsx2table.sh'],
					\ 	'odt': ['soffice', '--convert-to', '"txt:Text', '(encoded):UTF8"', '--cat'],
					\ 	'docx': ['soffice', '--convert-to', '"txt:Text', '(encoded):UTF8"', '--cat'],
					\ }
				\}
	" packadd fuzzy-file-finder
	call pack_manage#SetMAP('fuzzy-file-finder', a:cmd, [
				\ #{mode: 'n', key: '<silent><Leader>fr', method: 1, cmd: 'call fff#Open("~")'},
				\ #{mode: 'x', key: '<silent><Leader>fr', method: 1, cmd: 'call fff#Open("~")'},
				\ #{mode: 'n', key: '<silent><Leader>ff', method: 1, cmd: 'call fff#Open()'},
				\ #{mode: 'x', key: '<silent><Leader>ff', method: 1, cmd: 'call fff#Open()'},
				\ #{mode: 'n', key: '<silent><Leader>fu', method: 1, cmd: 'call fff#Open("..")'},
				\ #{mode: 'x', key: '<silent><Leader>fu', method: 1, cmd: 'call fff#Open("..")'},
				\ #{mode: 'n', key: '<silent><Leader>f.', method: 1, cmd: 'call fff#Open("~/dotfiles")'},
				\ #{mode: 'x', key: '<silent><Leader>f.', method: 1, cmd: 'call fff#Open("~/dotfiles")'},
				\ #{mode: 'n', key: '<silent><Leader>fv', method: 1, cmd: 'call fff#Open("$MYVIMDIR")'},
				\ #{mode: 'x', key: '<silent><Leader>fv', method: 1, cmd: 'call fff#Open("$MYVIMDIR")'},
				\ #{mode: 'n', key: '<silent><Leader>fs', method: 1, cmd: 'call fff#Open("~/src")'},
				\ #{mode: 'x', key: '<silent><Leader>fs', method: 1, cmd: 'call fff#Open("~/src")'},
				\ #{mode: 'n', key: '<silent><Leader>fx', method: 1, cmd: 'call fff#Open("~/bin")'},
				\ #{mode: 'x', key: '<silent><Leader>fx', method: 1, cmd: 'call fff#Open("~/bin")'},
				\ #{mode: 'n', key: '<silent><Leader>fe', method: 1, cmd: 'call fff#Open("~/book/epub")'},
				\ #{mode: 'x', key: '<silent><Leader>fe', method: 1, cmd: 'call fff#Open("~/book/epub")'},
				\ #{mode: 'n', key: '<silent><Leader>fd', method: 1, cmd: 'call fff#Open("~/downloads")'},
				\ #{mode: 'x', key: '<silent><Leader>fd', method: 1, cmd: 'call fff#Open("~/downloads")'},
				\ #{mode: 'n', key: '<silent><Leader>fD', method: 1, cmd: 'call fff#Open("~/Document")'},
				\ #{mode: 'x', key: '<silent><Leader>fD', method: 1, cmd: 'call fff#Open("~/Document")'},
				\ #{mode: 'n', key: '<silent><Leader>fp', method: 1, cmd: 'call fff#Open("~/public_html/iranoan")'},
				\ #{mode: 'x', key: '<silent><Leader>fp', method: 1, cmd: 'call fff#Open("~/public_html/iranoan")'},
				\ #{mode: 'n', key: '<silent><Leader>fi', method: 1, cmd: 'call fff#Open("~/Information/slide")'},
				\ #{mode: 'x', key: '<silent><Leader>fi', method: 1, cmd: 'call fff#Open("~/Information/slide")'},
				\ ])
	call timer_start(1, {->execute('delfunction set_fff#main')})
endfunction

