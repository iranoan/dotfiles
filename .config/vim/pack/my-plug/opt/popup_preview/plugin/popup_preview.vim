vim9script
scriptencoding utf-8

if exists('g:loaded_poup_preview')
	finish
endif
g:loaded_poup_preview = true

g:popup_preview = general_function#ExtendNew({
	border: [1, 1, 1, 1],
	borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
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
		'xcf', 'xbm', 'xpm', 'xwd', 'yuv',
		# PDF PostScript
		'pdf', 'ps',
	],
	filter: {
		zip: {cmd: ['unzip', '-l'], filetype: 'UnZipOut'},
		cbz: {cmd: ['unzip', '-l'], filetype: 'UnZipOut'},
		'tar.gz': {cmd: ['tar', '-tvf'], filetype: 'TarOut'}, tgz: {cmd: ['tar', '-tvf'], filetype: 'TarOut'},
		'tar.bz2': {cmd: ['tar', '-tvf'], filetype: 'TarOut'}, tbz: {cmd: ['tar', '-tvf'], filetype: 'TarOut'}, tbz2: {cmd: ['tar', '-tvf'], filetype: 'TarOut'}, tb2: {cmd: ['tar', '-tvf'], filetype: 'TarOut'},
		'tar.xz': {cmd: ['tar', '-tvf'], filetype: 'TarOut'}, txz: {cmd: ['tar', '-tvf'], filetype: 'TarOut'},
		'tar.Z': {cmd: ['tar', '-tvf'], filetype: 'TarOut'}, taz: {cmd: ['tar', '-tvf'], filetype: 'TarOut'},
		'tar.lzma': {cmd: ['tar', '-tvf'], filetype: 'TarOut'}, tlz: {cmd: ['tar', '-tvf'], filetype: 'TarOut'},
		gz: {cmd: ['gzip', '-l']},
		bz2: {cmd: ['bzcat']},
		xz: {cmd: ['xz', '-lv']},
		7z: {cmd: ['7z', 'l', '-ba', '-bd'], filetype: '7zOut'},
		rar: {cmd: ['unrar', 'l'], filetype: 'RarOut'},
		lzma: {cmd: ['lzma', '-l']},
	},
}, get(g:, 'popup_preview', {}))
