scriptencoding utf-8

function set_fzf_vim#main() abort
	" if manage_pack#IsInstalled('fzf.vim')
	" 	return
	" endif
	" https://github.com/junegunn/fzf {{{
	packadd fzf
	" }}}
	packadd fzf.vim
	delcommand GitFiles " vim-fugitive の :Git と重なり使いにくくなる
	let s:fzf_options = [
						\ '--multi', '--margin=0%', '--padding=0%',
						\ '--preview', '~/bin/fzf-preview.sh {}',
						\ '--bind', 'ctrl-o:execute-silent(xdg-open {})',
						\ ]
	let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.9, 'xoffset': 0 , 'yoffset': 0 } }
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
					\ 'fdfind --hidden --no-ignore --follow -t f -t l -E .texlive2023/ -E .npm/ -E .thumbnails/ -E thumbnails/ -E .log/ -E .tmp/ -E xapian/ -E .git/ -E cache/ -E .cache/ -E .ecryptfs/ -E .Private/ -E kpeoplevcard/ -E %* -E "*.nav" -E "*.synctex.gz" -E "*.asf" -E "*.bmc" -E "*.bmp" -E "*.cer" -E "*.chm" -E "*.chw" -E "*.crt" -E "*.dll" -E "*.doc" -E "*.docx" -E "*.dvi" -E "*.emf" -E "*.exe" -E "*.fdb_latexmk" -E "*.flv" -E "*.gpg" -E "*.hlp" -E "*.hmereg" -E "*.icc" -E "*.icm" -E "*.ico" -E "*.ics" -E "*.jp2" -E "*.lzh" -E "*.m4a" -E "*.mov" -E "*.mp3" -E "*.mp4" -E "*.mpg" -E "*.o" -E "*.obj" -E "*.odb" -E "*.odg" -E "*.odp" -E "*.ods" -E "*.odt" -E "*.oll" -E "*.opp" -E "*.pfa" -E "*.pl3" -E "*.ppm" -E "*.ppt" -E "*.pptx" -E "*.reg" -E "*.rtf" -E "*.sqlite" -E "*.tfm" -E "*.ttf" -E "*.vf" -E "*.webm" -E "*.wmf" -E "*.wmv" -E "*.xls" -E "*.xlsm" -E "*.xlsx" -E ".*.sw?" -Ea.out -E "*.rm" -E "*.vdi" -E "*.mkv" -E "*.swf" -E "*.avi" -E "*.jar" -E "*.pyc" -E "*.vbox" -E "*.nvram" -E "*.cur" -E "*.class" -E "*.vbox-prev" -E "*.fls" -E .viminfo -E viminfo -E "*.ltjruby" -E "Mail/.*/{cur,new,tmp}/*" . ',
					\ 'options': s:fzf_options + ['--prompt', 'Files> '],
					\ },
					\ <bang>0
				\ )
					" \ 'find -L . -type d \( -name .texlive2023 -o -name .npm -o -name .thumbnails -o -name thumbnails -o -name .log -o -name .tmp -o -name xapian -o -name .git -o -name cache -o -name .cache -o -name .Trash -o -name .ecryptfs -o -name .Private \) -prune -o \( -type f -o -type l \) ! -name "*.nav" ! -name "*.synctex.gz" ! -name "*.asf" ! -name "*.bmc" ! -name "*.bmp" ! -name "*.cer" ! -name "*.chm" ! -name "*.chw" ! -name "*.crt" ! -name "*.dll" ! -name "*.doc" ! -name "*.docx" ! -name "*.dvi" ! -name "*.emf" ! -name "*.exe" ! -name "*.fdb_latexmk" ! -name "*.flv" ! -name "*.gpg" ! -name "*.hlp" ! -name "*.hmereg" ! -name "*.icc" ! -name "*.icm" ! -name "*.ico" ! -name "*.ics" ! -name "*.jp2" ! -name "*.lzh" ! -name "*.m4a" ! -name "*.mov" ! -name "*.mp3" ! -name "*.mp4" ! -name "*.mpg" ! -name "*.o" ! -name "*.obj" ! -name "*.odb" ! -name "*.odg" ! -name "*.odp" ! -name "*.ods" ! -name "*.odt" ! -name "*.oll" ! -name "*.opp" ! -name "*.pfa" ! -name "*.pl3" ! -name "*.ppm" ! -name "*.ppt" ! -name "*.pptx" ! -name "*.reg" ! -name "*.rtf" ! -name "*.sqlite" ! -name "*.tfm" ! -name "*.ttf" ! -name "*.vf" ! -name "*.webm" ! -name "*.wmf" ! -name "*.wmv" ! -name "*.xls" ! -name "*.xlsm" ! -name "*.xlsx" ! -name ".*.sw?" ! -name a.out ! -name "*.rm" ! -name "*.vdi" ! -name "*.mkv" ! -name "*.swf" ! -name "*.avi" ! -name "*.jar" ! -name "*.pyc" ! -name "*.vbox" ! -name "*.nvram" ! -name "*.cur" ! -name "*.class" ! -name "*.vbox-prev" ! -name "*.fls" ! -name .viminfo ! -name viminfo ! -name "*.ltjruby" -regextype posix-extended ! -regex "\./Mail/(\.[^/]+/)+(cur|new|tmp)/[^/]+$" -printf "%P\n"', " {{{
					" バイナリ・ファイルとメールを除隊 (メールはファイル名だけ見ても分らない) " }}}
	" TabEdit が --multi に対応したつもり History そのものは、コマンドや検索履歴で使うので、上書きしない
	command! -bang -nargs=* HISTORY call fzf#run(
				\ fzf#wrap(
					\ {
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
				\ 'ctrl-t': function('set_fzf_vim#FZF_open'),
				\ 'ctrl-s': 'split',
				\ 'ctrl-v': 'vsplit',
				\ 'ctrl-o': function('set_fzf_vim#FZF_open')
				\ } " 他で sink を使うと、この設定は無視されるので注意←:help fzf-global-options-supported-by-fzf#wrap
				" 次の2つは効かない
				" \ 'enter': function('set_fzf_vim#FZF_open'),
				" \ 'ctrl-m': function('set_fzf_vim#FZF_open'),
	" [Buffers] Jump to the existing window if possible
	let g:fzf_buffers_jump = 1
	" let g:fzf_preview_window = ['right:50%', 'ctrl-]'] " FZF_DEFAULT_OPTS で定義済み
	" let g:fzf_vim = {
	" 			\ 'buffers_jump': 1,
	" 			\ 'commits_log_options': '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"',
	" 			\ }
endfunction

def set_fzf_vim#FZF_open(arg: list<string>): void
	for f in arg
		tabedit#Tabedit(f)
	endfor
enddef
defcompile

def set_fzf_vim#solarized(): void
	if g:colors_name ==# 'solarized'
		g:terminal_ansi_colors = [
						'#073642', '#dc322f', '#859900', '#b58900', '#268bd2', '#d33682', '#2aa198', '#eee8d5',
						'#002b36', '#cb4b16', '#586e75', '#657b83', '#839496', '#6c71c4', '#93a1a1', '#fdf6e3'
					]
	endif
enddef
