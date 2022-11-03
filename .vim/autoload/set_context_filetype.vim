scriptencoding utf-8

function set_context_filetype#main() abort
	packadd context_filetype.vim
	let g:precious_enable_switchers = {
				\ 	'help': {
				\ 	'setfiletype': 0
				\ },
				\}
	if !exists('g:context_filetype#filetypes')
		let g:context_filetype#filetypes = {}
	endif
	let g:context_filetype#filetypes = {
		\ 'lua': [
		\ {
			\ 	'filetype': 'conkyrc',
			\ 	'start': 'conky.config\s*=\s*{',
			\ 	'end': '}'
		\ },
		\ {
			\ 	'filetype': 'conkyrc',
			\ 	'start': 'conky.text\s*=\s*\[\[',
			\ 	'end': '\]\]'
			\ },
		\ ],
		\ 'html': [
			\ {
			\ 	'filetype': 'css',
			\ 	'start': '<[^>]\+\s\+style="',
			\ 	'end': '"'
		\ },
		\ {
			\ 	'filetype': 'css',
			\ 	'start': '<[^>]\+\s\+style=''',
			\ 	'end': ''''
		\ },
		\ {
			\ 	'filetype': 'css',
			\ 	'start': '<style>',
			\ 	'end': '</style>'
		\ },
		\ ],
		\ 'sh': [
		\ {
			\ 	'filetype': 'awk',
			\ 	'start': '\<[mg]\?awk\s\+.*''{',
			\ 	'end': '}'''
		\ },
		\ {
			\ 	'filetype': 'awk',
			\ 	'start': '\<[mg]\?awk\s\+.*''BEGIN',
			\ 	'end': '}'''
		\ },
		\ {
			\ 	'filetype': 'perl',
			\ 	'start': '\<perl\s\+\-[0-9a-zA-Z]*[ep][0-9a-zA-Z]\(\s\+\-[0-9a-zA-Z]\)*\s\+"',
			\ 	'end': '"'
		\ },
		\ {
			\ 	'filetype': 'perl',
			\ 	'start': '\<perl\s\+\-[0-9a-zA-Z]*[ep][0-9a-zA-Z]\(\s\+\-[0-9a-zA-Z]\)*\s\+''',
			\ 	'end': ''''
		\ },
		\ ],
		\ 'python': []
	\ }
		" ↑Python 中の下のような vim スクリプトにデフォルトで対応されているようだが、折りたたみをしている時に使いにくい
		" \ 'python': [
		" \ {
		" 	\ 	'filetype': 'vim',
		" 	\ 	'start': 'vim\.\(command\|eval\)(''''''',
		" 	\ 	'end': ''''''''
		" \ },
		" \ {
		" 	\ 	'filetype': 'vim',
		" 	\ 	'start': 'vim\.\(command\|\(bind\)\?eval\)(''',
		" 	\ 	'end': ''''
		" \ },
		" \ {
		" 	\ 	'filetype': 'vim',
		" 	\ 	'start': 'vim\.\(command\|\(bind\)\?eval\)("',
		" 	\ 	'end': '"'
		" 	\ },
		" \ ]
	" カーソル位置のコンテキストに合わせて filetype を切り替える https://github.com/osyo-manga/vim-precious {{{2
	" 上の context_filetype.vim はあくまで判定
	augroup loadprecious
		autocmd!
		autocmd CursorMoved,CursorMovedI * call set_precious#main()
					\ | autocmd! loadprecious
					\ | augroup! loadprecious
					\ | delfunction set_precious#main
	augroup END
endfunction
