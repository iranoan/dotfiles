scriptencoding utf-8

function set_fff#main() abort
	let g:popup_image_options = #{pt2px: #{x: 131, y: 154}}
	packadd popup_image
	let g:fuzzy_file_finder = #{
				\ cmd: ['fdfind.sh'],
				\ open: 'TabEdit',
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
	packadd fuzzy-file-finder
	call timer_start(1, {->execute('delfunction set_fff#main')})
endfunction

