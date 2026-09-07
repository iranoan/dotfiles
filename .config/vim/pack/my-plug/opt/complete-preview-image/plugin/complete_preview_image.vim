vim9script
scriptencoding utf-8

if exists('g:loaded_complete_preview_image')
	finish
endif
g:loaded_complete_preview_image = true

try
	g:complete_preview_image = general_function#ExtendNew([
		# Video
		'anx', 'asf', 'avi', 'axv', 'flc', 'fli', 'flv', 'gl', 'm2v', 'm4v', 'mkv', 'mov', 'mp4', 'mp4v', 'mpeg', 'mpg',
		'nuv', 'ogm', 'ogv', 'ogx', 'qt', 'rm', 'rmvb', 'swf', 'vob', 'webm', 'wmv',
		# Image
		'avif', 'bmp', 'cgm', 'cr2', 'cur', 'dl', 'dvi', 'emf', 'eps', 'gif', 'ico', 'j2c', 'j2k', 'jp2', 'jpeg', 'jpg',
		'jpf', 'jpx', 'jxl', 'mng', 'nef', 'pbm', 'pcx', 'pgm', 'png', 'ppm', 'svg', 'svgz', 'tga', 'tiff', 'webp',
		'xcf', 'xbm', 'xpm', 'xwd', 'yuv',
		# PDF PostScript
		'pdf', 'ps',
	], get(g:, 'complete_preview_image', []), 'force')
catch /^Vim\%((\S\+)\)\=:E117/
	g:complete_preview_image = extendnew([
		# Video
		'anx', 'asf', 'avi', 'axv', 'flc', 'fli', 'flv', 'gl', 'm2v', 'm4v', 'mkv', 'mov', 'mp4', 'mp4v', 'mpeg', 'mpg',
		'nuv', 'ogm', 'ogv', 'ogx', 'qt', 'rm', 'rmvb', 'swf', 'vob', 'webm', 'wmv',
		# Image
		'avif', 'bmp', 'cgm', 'cr2', 'cur', 'dl', 'dvi', 'emf', 'eps', 'gif', 'ico', 'j2c', 'j2k', 'jp2', 'jpeg', 'jpg',
		'jpf', 'jpx', 'jxl', 'mng', 'nef', 'pbm', 'pcx', 'pgm', 'png', 'ppm', 'svg', 'svgz', 'tga', 'tiff', 'webp',
		'xcf', 'xbm', 'xpm', 'xwd', 'yuv',
		# PDF PostScript
		'pdf', 'ps',
	], get(g:, 'complete_preview_image', []), 'force')
endtry

augroup completePopupPreviewImage
	autocmd!
	autocmd CompleteChanged * complete_preview_image#Change()
augroup END
