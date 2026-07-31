vim9script
scriptencoding utf-8

g:fuzzy_file_finder = extendnew({
	cmd: ['fdfind', '--hidden', '--follow', '--type', 'file', '--type', 'symlink', '--type', 'directory', '--search-path'],
	type: {
		ext: {
			awk: 'awk',
			c: 'c',
			cc: 'cpp',
			cpp: 'cpp',
			csv: 'csv',
			tsv: 'tsv',
			go: 'go',
			h: 'c',
			htm: 'html',
			html: 'html',
			xhtml: 'xhtml',
			java: 'java',
			js: 'javascript',
			json: 'json',
			md: 'markdown',
			py: 'python',
			rs: 'rust',
			ru: 'ruby',
			sh: 'sh',
			tex: 'tex',
			vim: 'vim',
			vue: 'vue',
		},
		name: {
			'.bashrc': 'bash',
			'bashrc': 'bash',
			'.cshrc': 'csh',
			'.profile': 'sh',
			'.xprofile': 'sh',
			latexmkrc: 'perl',
			'.texlintrc': 'json',
			'.inputrc': 'readline',
			'.fbignore': 'gitignore',
			'.gitignore': 'gitignore',
			'.gitattributes': 'gitattributes',
			'.gitconfig': 'gitconfig',
			'.Xresources': 'xdefaults',
			'tmux.conf': 'tmux',
			vimrc: 'vim',
			gvimrc: 'vim',
		},
		path: [
			{reg: '^\~/.config/fd/[^/]\+$', type: 'gitignore'},
			{reg: '^\~/.config/bash/[^/]\+$', type: 'bash'},
			{reg: '/.git/attributes$', type: 'gitattributes'},
			{reg: '/.git/config$', type: 'gitconfig'},
			{reg: '/.git/ignore$', type: 'gitignore'},
		]
	},
	image: [
		# Video
		'anx', 'asf', 'avi', 'axv', 'flc', 'fli', 'flv', 'gl', 'm2v', 'm4v', 'mkv', 'mov', 'mp4', 'mp4v', 'mpeg', 'mpg',
		'nuv', 'ogm', 'ogv', 'ogx', 'qt', 'rm', 'rmvb', 'swf', 'vob', 'webm', 'wmv',
		# Image
		'avif', 'bmp', 'cgm', 'cr2', 'cur', 'dl', 'dvi', 'emf', 'eps', 'gif', 'ico', 'j2c', 'j2k', 'jp2', 'jpeg', 'jpg',
		'jpf', 'jpx', 'jxl', 'mng', 'nef', 'pbm', 'pcx', 'pgm', 'png', 'ppm', 'svg', 'svgz', 'tga', 'tiff', 'webp',
		'xbm', 'xcf', 'xpm', 'xwd', 'yuv',
		# PDF
		'pdf'
	],
	filter: {
		zip: 'unzip -l',
		cbz: 'unzip -l',
		'tar.gz': 'tar -tvf', tgz: 'tar -tvf',
		'tar.bz2': 'tar -tvf', tbz: 'tar -tvf', tbz2: 'tar -tvf', tb2: 'tar -tvf',
		'tar.xz': 'tar -tvf', txz: 'tar -tvf',
		'tar.Z': 'tar -tvf', taz: 'tar -tvf',
		'tar.lzma': 'tar -tvf', tlz: 'tar -tvf',
		gz: 'gzip -l',
		bz2: 'bzcat',
		xz: 'xz -lv',
		7z: '7z l',
		rar: 'unrar l',
		lzma: 'lzma -l',
	},
	open: 'edit',
	dir: true,
}, get(g:, 'fuzzy_file_finder', {}), 'force')

