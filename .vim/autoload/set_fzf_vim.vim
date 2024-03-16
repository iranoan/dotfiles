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
	let $FZF_DEFAULT_COMMAND = executable("fdfind")
						\ ? 'fdfind --hidden --no-ignore --follow -t f -t l --ignore-file ~/.fdignore -E "*.cer" -E "*.chm" -E "*.chw" -E "*.class" -E "*.crt" -E "*.cur" -E "*.dll" -E "*.dvi" -E "*.exe" -E "*.fdb_latexmk" -E "*.fls" -E "*.gpg" -E "*.hlp" -E "*.hmereg" -E "*.jar" -E "*.ltjruby" -E "*.nav" -E "*.nvram" -E "*.o" -E "*.obj" -E "*.oll" -E "*.opp" -E "*.pfa" -E "*.pl3" -E "*.ppm" -E "*.pyc" -E "*.reg" -E "*.sqlite" -E "*.synctex.gz" -E "*.tfm" -E "*.ttf" -E "*.vbox" -E "*.vbox-prev" -E "*.vf" -E a.out . '
						\ : 'find -L . -type d \( -name .texlive2023 -o -name .npm -o -name .thumbnails -o -name thumbnails -o -name .log -o -name .tmp -o -path "$HOME/Mail/.*/new" -o -path "$HOME/Mail/.*/cur" -o -path "$HOME/Mail/.*/tmp" -o -path "$HOME/Mail/.notmuch/xapian" -o -path .local/share/Trash -o -path node_modules -o -path go/pkg -o -path "$HOME/PDF" -o -path "$HOME/img/スクリーンショット" -o -name .git -o -name cache -o -name .cache -o -name .Trash -o -name .ecryptfs -o -name .Private -o -name kpeoplevcard \) -prune -o \( -type f -o -type l \) ! -name "*.nav" ! -name "*.synctex.gz" ! -name "*.cer" ! -name "*.chm" ! -name "*.chw" ! -name "*.crt" ! -name "*.dll" ! -name "*.dvi" ! -name "*.exe" ! -name "*.fdb_latexmk" ! -name "*.gpg" ! -name "*.hlp" ! -name "*.hmereg" ! -name "*.o" ! -name "*.obj" ! -name "*.oll" ! -name "*.opp" ! -name "*.pfa" ! -name "*.pl3" ! -name "*.ppm" ! -name "*.reg" ! -name "*.sqlite" ! -name "*.tfm" ! -name "*.ttf" ! -name "*.vf" ! -name ".*.sw?" ! -name a.out ! -name "*.jar" ! -name "*.pyc" ! -name "*.vbox" ! -name "*.nvram" ! -name "*.cur" ! -name "*.class" ! -name "*.vbox-prev" ! -name "*.fls" ! -name .viminfo ! -name viminfo ! -name "*.ltjruby" ! -name ".~lock.*#" -printf "%P\n" 2> /dev/null' "-prune 前の -path が効いていないが、シェルに設定した FZF_DEFAULT_COMMAND に合わせてある
	command! -bang -nargs=? -complete=dir Files call fzf#vim#files(
				\ <q-args>, {
					\ 'options': s:fzf_options + ['--prompt', 'Files> '],
					\ },
					\ <bang>0
				\ )
					" バイナリ・ファイルとメールを除外 (メールはファイル名だけ見ても分らない) " }}}
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
				\ 'ctrl-g': 'edit',
				\ 'ctrl-t': function('set_fzf_vim#FZF_open'),
				\ 'ctrl-s': 'split',
				\ 'ctrl-v': 'vsplit',
				\ 'enter': function('set_fzf_vim#FZF_open'),
				\ 'ctrl-o': function('set_fzf_vim#FZF_open')
				\ } " 他で sink を使うと、この設定は無視されるので注意←:help fzf-global-options-supported-by-fzf#wrap
				" \ 'ctrl-e': 'edit', カーソルを入力の末尾移動と重なる
	" [Buffers] Jump to the existing window if possible
	let g:fzf_buffers_jump = 1
	" let g:fzf_preview_window = ['right:50%', 'ctrl-]'] " FZF_DEFAULT_OPTS で定義済み
	" let g:fzf_vim = {
	" 			\ 'buffers_jump': 1,
	" 			\ 'commits_log_options': '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"',
	" 			\ }
endfunction

def set_fzf_vim#FZF_open(arg: list<string>): void
	var dir: string = getcwd() .. '/'
	for f in arg
		if match(f, '^[~/]') != 0
			tabedit#Tabedit(dir .. f)
		else
			tabedit#Tabedit(f)
		endif
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
