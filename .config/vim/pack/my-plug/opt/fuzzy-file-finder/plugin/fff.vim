vim9script
scriptencoding utf-8

augroup FuzzyFileFinder
	autocmd!
	autocmd VimResized * fff#Bridge('VimResized')
	autocmd CmdwinEnter * fff#Bridge('CmdwinEnter')
	autocmd CmdwinLeave * fff#Bridge('CmdwinLeave')
augroup END

		# borderchars: ['─', '│', '─', '│', '┬', '╮', '╯', '┴'],
		# border: [1, 1, 1, 1],
try
	g:fuzzy_file_finder = general_function#ExtendNew({
		cmd: ['find', '-L', '.', '-mindepth', '1', '(', '-type', 'd', '-o', '-type', 'f', '-o', '-type', 'l', ')', '-printf', '%P\n'],
		list_border: [1, 1, 1, 1],
		list_borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
		preview_border: [1, 1, 1, 1],
		preview_borderchars: ['─', '│', '─', '│', '┬', '╮', '╯', '┴'],
		open: 'edit',
		dir: true,
	}, get(g:, 'fuzzy_file_finder', {}), 'cmd')
catch /^Vim\%((\S\+)\)\=:E117/
	g:fuzzy_file_finder = extendnew({
		cmd: ['find', '-L', '.', '-mindepth', '1', '(', '-type', 'd', '-o', '-type', 'f', '-o', '-type', 'l', ')', '-printf', '%P\n'],
		list_border: [1, 1, 1, 1],
		list_borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
		preview_border: [1, 1, 1, 1],
		preview_borderchars: ['─', '│', '─', '│', '┬', '╮', '╯', '┴'],
		open: 'edit',
		dir: true,
	}, get(g:, 'fuzzy_file_finder', {}), 'force')
endtry
