scriptencoding utf-8

function set_fzf_vim#main(cmd) abort
	" if pack_manage#IsInstalled('fzf.vim')
	" 	return
	" endif
	" https://github.com/junegunn/fzf {{{
	" do-setup: ./install --bin
	packadd fzf
	" }}}
	" fzf.vim の Helptas の代わりに HelpTags を使う $MYVIMDIR/pack/my-plug/opt/fzf-help {{{
	" delcommand Helptas←packadd しただけではまだ未定義
	packadd fzf-help
	" }}}
	let s:fzf_options = [
						\ '--multi', '--margin=0%', '--padding=0%',
						\ '--preview', '~/bin/fzf-preview.sh {}',
						\ '--bind', 'ctrl-o:execute-silent(xdg-open {})',
						\ ]
	let g:fzf_layout = { 'window': { 'width': 1, 'height': 1, 'xoffset': 0 , 'yoffset': 0 } }
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
						\ ? 'fdfind --hidden --follow --no-ignore --ignore-file ~/.config/fd/ignore --ignore-file ~/.config/fd/noedit --type file --type symlink --type directory .'
						\ : 'find -L . -type d \( -name .texlive2023 -o -name .npm -o -name .thumbnails -o -name thumbnails -o -name .log -o -name .tmp -o -path "$HOME/Mail/.*/new" -o -path "$HOME/Mail/.*/cur" -o -path "$HOME/Mail/.*/tmp" -o -path "$HOME/Mail/.notmuch/xapian" -o -path .local/share/Trash -o -path node_modules -o -path go/pkg -o -path "$HOME/PDF" -o -path "$HOME/img/スクリーンショット" -o -name .git -o -name cache -o -name .cache -o -name .Trash -o -name .ecryptfs -o -name .Private -o -name kpeoplevcard \) -prune -o \( -type f -o -type l \) ! -name "*.aux" ! -name "*.snm" ! -name "*.nav" ! -name "*.synctex.gz" ! -name "*.cer" ! -name "*.chm" ! -name "*.chw" ! -name "*.crt" ! -name "*.dll" ! -name "*.dvi" ! -name "*.exe" ! -name "*.fdb_latexmk" ! -name "*.gpg" ! -name "*.hlp" ! -name "*.hmereg" ! -name "*.o" ! -name "*.obj" ! -name "*.oll" ! -name "*.opp" ! -name "*.pfa" ! -name "*.pl3" ! -name "*.ppm" ! -name "*.reg" ! -name "*.sqlite" ! -name "*.tfm" ! -name "*.ttf" ! -name "*.vf" ! -name ".*.sw?" ! -name a.out ! -name "*.jar" ! -name "*.pyc" ! -name "*.vbox" ! -name "*.nvram" ! -name "*.cur" ! -name "*.class" ! -name "*.vbox-prev" ! -name "*.fls" ! -name .viminfo ! -name viminfo ! -name "*.ltjruby" ! -name ".~lock.*#" -printf "%P\n" 2> /dev/null' "-prune 前の -path が効いていないが、シェルに設定した FZF_DEFAULT_COMMAND に合わせてある
	command! -bang -nargs=? -complete=dir Files call fzf#vim#files(
				\ <q-args>, {
					\ 'options': s:fzf_options + ['--prompt', 'Files> '],
					\ },
					\ <bang>0
				\ )
					" バイナリ・ファイルとメールを除外 (メールはファイル名だけ見ても分らない)
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
	" let g:fzf_vim = #{
	" 			\ buffers_jump: 1,
	" 			\ preview_window: ['right:50%', 'ctrl-]'],
	" 			\ commits_log_options: '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"',
	" 			\ } " buffers_jump: Buffers 使わず、preview_window: FZF_DEFAULT_OPTS で定義済み
	let v:oldfiles = filter(v:oldfiles, {_, v -> filereadable(expand(v))})
	call pack_manage#SetMAP('fzf.vim', a:cmd, [
				\ #{mode: 'n', key: '<silent><Leader>fr', method: 1, cmd: 'Files ~'},
				\ #{mode: 'x', key: '<silent><Leader>fr', method: 1, cmd: 'Files ~'},
				\ #{mode: 'n', key: '<silent><Leader>ff', method: 1, cmd: 'Files'},
				\ #{mode: 'x', key: '<silent><Leader>ff', method: 1, cmd: 'Files'},
				\ #{mode: 'n', key: '<silent><Leader>fu', method: 1, cmd: 'Files ..'},
				\ #{mode: 'x', key: '<silent><Leader>fu', method: 1, cmd: 'Files ..'},
				\ #{mode: 'n', key: '<silent><Leader>f.', method: 1, cmd: 'Files ~/dotfiles'},
				\ #{mode: 'x', key: '<silent><Leader>f.', method: 1, cmd: 'Files ~/dotfiles'},
				\ #{mode: 'n', key: '<silent><Leader>fv', method: 1, cmd: 'Files $MYVIMDIR'},
				\ #{mode: 'x', key: '<silent><Leader>fv', method: 1, cmd: 'Files $MYVIMDIR'},
				\ #{mode: 'n', key: '<silent><Leader>fs', method: 1, cmd: 'Files ~/src'},
				\ #{mode: 'x', key: '<silent><Leader>fs', method: 1, cmd: 'Files ~/src'},
				\ #{mode: 'n', key: '<silent><Leader>fx', method: 1, cmd: 'Files ~/bin'},
				\ #{mode: 'x', key: '<silent><Leader>fx', method: 1, cmd: 'Files ~/bin'},
				\ #{mode: 'n', key: '<silent><Leader>fe', method: 1, cmd: 'Files ~/book/epub'},
				\ #{mode: 'x', key: '<silent><Leader>fe', method: 1, cmd: 'Files ~/book/epub'},
				\ #{mode: 'n', key: '<silent><Leader>fd', method: 1, cmd: 'Files ~/downloads'},
				\ #{mode: 'x', key: '<silent><Leader>fd', method: 1, cmd: 'Files ~/downloads'},
				\ #{mode: 'n', key: '<silent><Leader>fD', method: 1, cmd: 'Files ~/Document'},
				\ #{mode: 'x', key: '<silent><Leader>fD', method: 1, cmd: 'Files ~/Document'},
				\ #{mode: 'n', key: '<silent><Leader>fp', method: 1, cmd: 'Files ~/public_html/iranoan'},
				\ #{mode: 'x', key: '<silent><Leader>fp', method: 1, cmd: 'Files ~/public_html/iranoan'},
				\ #{mode: 'n', key: '<silent><Leader>fi', method: 1, cmd: 'Files ~/Information/slide'},
				\ #{mode: 'x', key: '<silent><Leader>fi', method: 1, cmd: 'Files ~/Information/slide'},
				\ #{mode: 'n', key: '<silent><Leader>fc', method: 1, cmd: 'Commands'},
				\ #{mode: 'x', key: '<silent><Leader>fc', method: 1, cmd: 'Commands'},
				\ #{mode: 'n', key: '<silent><Leader>fg', method: 1, cmd: 'GFiles?'},
				\ #{mode: 'x', key: '<silent><Leader>fg', method: 1, cmd: 'GFiles?'},
				\ #{mode: 'n', key: '<silent><Leader>fh', method: 1, cmd: 'HISTORY'},
				\ #{mode: 'x', key: '<silent><Leader>fh', method: 1, cmd: 'HISTORY'},
				\ #{mode: 'n', key: '<silent><Leader>fH', method: 1, cmd: 'HelpTags'},
				\ #{mode: 'x', key: '<silent><Leader>fH', method: 1, cmd: 'HelpTags'},
				\ #{mode: 'n', key: '<silent><Leader>fl', method: 1, cmd: 'BLines'},
				\ #{mode: 'x', key: '<silent><Leader>fl', method: 1, cmd: 'BLines'},
				\ #{mode: 'n', key: '<silent><Leader>fm', method: 1, cmd: 'Marks'},
				\ #{mode: 'x', key: '<silent><Leader>fm', method: 1, cmd: 'Marks'},
				\ #{mode: 'n', key: '<silent>m/',         method: 1, cmd: 'Marks'},
				\ #{mode: 'x', key: '<silent>m/',         method: 1, cmd: 'Marks'},
				\ #{mode: 'n', key: '<silent><Leader>f:', method: 1, cmd: 'History:'},
				\ #{mode: 'x', key: '<silent><Leader>f:', method: 1, cmd: 'History:'},
				\ #{mode: 'n', key: '<silent><Leader>f/', method: 1, cmd: 'History/'},
				\ #{mode: 'x', key: '<silent><Leader>f/', method: 1, cmd: 'History/'}
				\ ])
" \ #{mode: 'n, key: '<silent><Leader>fb', method: 1, cmd: 'Buffers'},
" \ #{mode: 'n, key: '<silent><Leader>ft', method: 1, cmd: 'Tags'},
" \ #{mode: 'x, key: '<silent><Leader>ft', method: 1, cmd: 'Tags'},
" \ #{mode: 'n, key: '<silent><Leader>fw', method: 1, cmd: 'Windows'},
" \ #{mode: 'x, key: '<silent><Leader>fw', method: 1, cmd: 'Windows'},
" \ #{mode: 'x, key: '<silent><Leader>fb', method: 1, cmd: 'Buffers'},
" \ ↑ vim-signature のデフォルト・キーマップをこちらに再定義
	delcommand GitFiles " vim-fugitive の :Git と重なり使いにくくなる
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
	if get(g:, 'colors_name', '') ==# 'solarized'
		g:terminal_ansi_colors = [
						'#073642', '#dc322f', '#859900', '#b58900', '#268bd2', '#d33682', '#2aa198', '#eee8d5',
						'#002b36', '#cb4b16', '#586e75', '#657b83', '#839496', '#6c71c4', '#93a1a1', '#fdf6e3'
					]
	endif
enddef
