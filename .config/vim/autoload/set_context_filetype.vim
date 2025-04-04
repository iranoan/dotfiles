scriptencoding utf-8

function set_context_filetype#main() abort
	packadd context_filetype.vim
	let g:precious_enable_switchers = {
				\ 	'help': {
				\ 	'setfiletype': 0
				\ },
				\}
	let add_dic = {
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
		\ {
			\ 	'filetype': 'javascript',
			\ 	'start': '<script>',
			\ 	'end': '</script>'
		\ },
		\ ],
		\ 'xhtml': [
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
		\ {
			\ 	'filetype': 'css',
			\ 	'start': '<style type=\([''"]\)text/css\1>',
			\ 	'end': '</style>'
		\ },
		\ {
			\ 	'filetype': 'javascript',
			\ 	'start': '<script>',
			\ 	'end': '</script>'
		\ },
		\ ],
		\ 'sh': [
		\ {
			\ 	'filetype': 'awk',
			\ 	'start': '\<[mg]\?awk\s\+.*''\ze\(F\?NR\s*==\s*\d\+;\)*BEGIN\s*{',
			\ 	'end': '}\ze\s*[{;'']'
		\ },
		\ {
			\ 	'filetype': 'awk',
			\ 	'start': '\<[mg]\?awk\s\+''.*{',
			\ 	'end': '}\s*[{;'']'
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
	let add_dic.bash = add_dic.sh
	if exists('g:context_filetype#filetypes')
		call extend(g:context_filetype#filetypes, add_dic)
	else
		let g:context_filetype#filetypes = add_dic
	endif
	" カーソル位置のコンテキストに合わせて filetype を切り替える https://github.com/osyo-manga/vim-precious {{{2
	" 上の context_filetype.vim はあくまで判定
	augroup loadprecious
		autocmd!
		autocmd CursorMoved,CursorMovedI * call s:set_precious()
					\ | autocmd! loadprecious
					\ | augroup! loadprecious
					\ | delfunction s:set_precious
	augroup END
endfunction

function s:set_precious() abort
	packadd vim-precious
	let g:precious_enable_switchers = {
				\ 'help': {
				\ 	'setfiletype': 0
				\ },
				\}
	augroup VimPrecious
	autocmd!
		autocmd User PreciousFileType :if &diff && &foldmethod !=# 'diff' | setlocal foldmethod=diff | end
	augroup END
endfunction
