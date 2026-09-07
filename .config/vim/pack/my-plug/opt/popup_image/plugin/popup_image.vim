vim9script
scriptencoding utf-8

if !executable('mimetype')
	|| !executable('ffprobe')
	|| !executable('ffmpeg')
	|| !executable('gs')
	popup_notification([
		'All video/image: ''mimetype'' command',
		'image:           FFmgeg (ffmpeg/ffprobe command)',
		'video:           FFmgeg (ffmpeg/ffprobe command)',
		'PDF/PostScript:  and GhostScript (gs command)',
	], {title: 'Need following tools ', highlight: 'ErrorMsg', borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'], padding: [0, 1, 0, 1]})
	finish
endif

if extendnew(get(g:, 'popup_image_options', {loaded: false}), {loaded: false}).loaded
	finish
endif

try
	g:popup_image_options = general_function#ExtendNew({pt2px: {x: 96, y: 96}, min_size: {x: 5, y: 5}, loaded: true},
		get(g:, 'popup_image_options', {}), 'force')
catch /^Vim\%((\S\+)\)\=:E117/
	g:popup_image_options = extendnew({pt2px: {x: 96, y: 96}, min_size: {x: 5, y: 5}, loaded: true},
		get(g:, 'popup_image_options', {}), 'force')
endtry
