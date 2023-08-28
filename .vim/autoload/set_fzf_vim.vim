scriptencoding utf-8

function set_fzf_vim#main() abort
	" if manage_pack#IsInstalled('fzf.vim')
	" 	return
	" endif
	" https://github.com/junegunn/fzf {{{
	packadd fzf
	" }}}
	packadd fzf.vim
	delcommand GitFiles " vim-fugitive の :Git となり使いにくくなる
	let s:fzf_options = [
						\ '--multi', '--no-unicode', '--margin=0%', '--padding=0%',
						\ '--preview', '~/bin/fzf-preview.sh {}',
						\ ]
	let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.9 } }
	if has('gui_running')
		call set_fzf_vim#solarized()
		augroup FZF_Vim_Solaraized
			autocmd!
			autocmd ColorScheme * call set_fzf_vim#solarized()
		augroup END
	endif
	" CUI では Normal の ctermbg=NOE としているので、そのまま使うと黒色になる
	let g:fzf_colors = {
				\ 'fg':     ['fg', 'Normal'],
				\ 'bg':     ['bg', 'NormalDefault'],
				\ 'fg+':    ['fg', 'CursorLineNr'],
				\ 'bg+':    ['bg', 'CursorLine'],
				\ 'border': ['fg', 'Normal'],
				\ 'info':   ['fg', 'LineNr'],
				\ }
	" if g:colors_name ==# 'solarized'
	" 	" let s:fzf_options += ['--color', &background] " ↑上の色指定が無視される
	" endif
	command! -bang -nargs=? -complete=dir Files call fzf#vim#files(
				\ <q-args>, {
					\ 'source':
					\ 'find . -type d \( -name ".texlive2023" -o -name ".npm" -o -name ".thumbnails" -o -name "thumbnails" -o -name .log -o -name .tmp -o -name xapian -o -name ".git" -o -name "cache" -o -name ".cache" -o -name ".Trash" -o -name ".ecryptfs" \) -prune -o -type f \( ! -name "*.nav" ! -name "*.synctex.gz" ! -name "*.asf" ! -name "*.bmc" ! -name "*.bmp" ! -name "*.cer" ! -name "*.chm" ! -name "*.chw" ! -name "*.crt" ! -name "*.dll" ! -name "*.doc" ! -name "*.docx" ! -name "*.dvi" ! -name "*.emf" ! -name "*.exe" ! -name "*.fdb_latexmk" ! -name "*.flv" ! -name "*.gpg" ! -name "*.hlp" ! -name "*.hmereg" ! -name "*.icc" ! -name "*.icm" ! -name "*.ico" ! -name "*.ics" ! -name "*.jp2" ! -name "*.lzh" ! -name "*.m4a" ! -name "*.mov" ! -name "*.mp3" ! -name "*.mp4" ! -name "*.mpg" ! -name "*.o" ! -name "*.obj" ! -name "*.odb" ! -name "*.odg" ! -name "*.odp" ! -name "*.ods" ! -name "*.odt" ! -name "*.oll" ! -name "*.opf" ! -name "*.opp" ! -name "*.pfa" ! -name "*.pl3" ! -name "*.ppm" ! -name "*.ppt" ! -name "*.pptx" ! -name "*.reg" ! -name "*.rtf" ! -name "*.sqlite" ! -name "*.tfm" ! -name "*.ttf" ! -name "*.vf" ! -name "*.webm" ! -name "*.wmf" ! -name "*.wmv" ! -name "*.xls" ! -name "*.xlsm" ! -name "*.xlsx" ! -name ".*.sw?" ! -name a.out ! -name "*.rm" ! -name "*.vdi" ! -name "*.mkv" ! -name "*.swf" ! -name "*.avi" ! -name "*.jar" ! -name "*.pyc" ! -name "*.vbox" ! -name "*.nvram" ! -name "*.cur" ! -name "*.class" ! -name "*.vbox-prev" ! -name "*.fls" ! -name "viminfo" ! -name "*.ltjruby" \) -regextype posix-extended ! -regex "\./Mail/(\.[^/]+/)+(cur|new|tmp)/[^/]+$" -printf "%P\n"',
					\ 'sink': 'silent TabEdit',
					\ 'options': s:fzf_options + ['--prompt', 'Files> '],
					\ },
					\ <bang>0
				\ )
				" バイナリ・ファイルとメールを除隊 (メールはファイル名だけ見ても分らない)
	" TabEdit が --multi に対応したつもり History そのものは、コマンドや検索履歴で使うので、上書きしない
	command! -bang -nargs=* HISTORY call fzf#run(
				\ fzf#wrap(
					\ {
						\ 'sink': 'TabEdit',
						\ 'options': s:fzf_options + [
							\ '--header-lines', !empty(expand('%')),
							\ '--prompt', 'Hist> ',
						\ ],
						\ 'source':  fzf#vim#_recent_files(),
					\},
					\ <bang>0
					\ )
				\ )
	let g:fzf_action = {
				\ 'ctrl-e': 'edit',
				\ 'ctrl-t': 'tab split',
				\ 'ctrl-s': 'split',
				\ 'ctrl-v': 'vsplit'
				\ }
	" [Buffers] Jump to the existing window if possible
	let g:fzf_buffers_jump = 1
	let g:fzf_preview_window = ['right:50%', 'ctrl-]']
endfunction

def set_fzf_vim#solarized(): void
	if g:colors_name ==# 'solarized'
		g:terminal_ansi_colors = [
						'#073642', '#dc322f', '#859900', '#b58900', '#268bd2', '#d33682', '#2aa198', '#eee8d5',
						'#002b36', '#cb4b16', '#586e75', '#657b83', '#839496', '#6c71c4', '#93a1a1', '#fdf6e3'
					]
	endif
enddef
