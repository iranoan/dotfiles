vim9script
scriptencoding utf-8
# シンボリック・リンク先を開く

export def Normalize(): void
	var bufname = bufname('%')
	var pos = getpos('.')
	var filetype = &filetype
	var full_path = resolve(expand('%'))
	enew
	execute 'bwipeout ' .. bufname .. ' | edit ' .. full_path
	setpos('.', pos)
	execute 'setlocal filetype=' .. filetype
enddef

