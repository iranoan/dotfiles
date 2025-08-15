scriptencoding utf-8

function set_fzf#main() abort
	" https://github.com/junegunn/fzf {{{
	" do-setup: ./install --bin
	packadd fzf
	" }}}
	let g:fzf_layout = { 'window': { 'width': 1, 'height': 1, 'xoffset': 0 , 'yoffset': 0 } }
	if has('gui_running')
		call set_fzf#solarized()
		augroup FZF_Vim_Solaraized
			autocmd!
			autocmd ColorScheme * call set_fzf#solarized()
		augroup END
	else " CUI では Normal の ctermbg=NOE としているので、そのまま使うと黒色になる
		let g:fzf_colors = {
					\ 'fg':     ['fg', 'Normal'],
					\ 'bg':     ['bg', 'NormalDefault'],
					\ 'fg+':    ['fg', 'CursorLineNr'],
					\ 'bg+':    ['bg', 'CursorLine'],
					\ 'border': ['fg', 'Normal'],
					\ 'info':   ['fg', 'LineNr'],
					\ }
	endif
	let g:fzf_action = {
				\ 'ctrl-g': 'edit',
				\ 'ctrl-t': function('set_fzf#FZF_open'),
				\ 'ctrl-s': 'split',
				\ 'ctrl-v': 'vsplit',
				\ 'enter': function('set_fzf#FZF_open'),
				\ 'ctrl-o': function('set_fzf#FZF_open')
				\ } " 他で sink を使うと、この設定は無視されるので注意←:help fzf-global-options-supported-by-fzf#wrap
				" \ 'ctrl-e': 'edit', カーソルを入力の末尾移動と重なる
	let $FZF_DEFAULT_OPTS = substitute($FZF_DEFAULT_OPTS, '--footer "[^"]\+"', '', 'g')
endfunction

function set_fzf#help() abort
	if !pack_manage#IsInstalled('fzf')
		call set_fzf#main()
		delfunction set_fzf#main
	endif
	call pack_manage#SetMAP('fzf-help', 'HelpTags', [
				\ #{mode: 'n', key: '<Leader>fH', method: 1, cmd: 'HelpTags'},
				\ #{mode: 'x', key: '<Leader>fH', method: 1, cmd: 'HelpTags'},
				\ ] )
endfunction

function set_fzf#neoyank(cmd) abort
	if !pack_manage#IsInstalled('fzf')
		call set_fzf#main()
		delfunction set_fzf#main
	endif
	if !pack_manage#IsInstalled('neoyank.vim')
		packadd neoyank.vim
		silent call neoyank#_append()
		silent call neoyank#_yankpost()
		autocmd! SetNeoyank
		augroup! SetNeoyank
	endif
	call pack_manage#SetMAP('fzf-neoyank', a:cmd, [
				\ #{mode: 'n', key: '<Leader>fy', method: 1, cmd: 'FZFNeoyank'},
				\ #{mode: 'n', key: '<Leader>fY', method: 1, cmd: 'FZFNeoyank " P'},
				\ #{mode: 'x', key: '<Leader>fy', method: 1, cmd: 'FZFNeoyankSelection'},
				\ ] )
endfunction

function set_fzf#tabs() abort
	if !pack_manage#IsInstalled('fzf')
		call set_fzf#main()
		delfunction set_fzf#main
	endif
	let g:fzf_tabs_options = ['--preview', '~/bin/fzf-preview.sh {2}', '--footer', 'Ctrl-]/R/K:Preview On/Off/Up/Down｜F/B:PageUP/Down｜G:Sxiv｜O:Open｜V:Vim']
	call pack_manage#SetMAP('fzf-tabs', 'FZFTabOpen', [
				\ #{mode: 'n', key: '<Leader>ft', method: 1, cmd: 'FZFTabOpen'},
				\ #{mode: 'v', key: '<Leader>ft', method: 1, cmd: 'FZFTabOpen'},
				\ #{mode: 'n', key: '<Leader>fb', method: 1, cmd: 'FZFTabOpen'},
				\ #{mode: 'n', key: '<Leader>fw', method: 1, cmd: 'FZFTabOpen'},
				\ ])
endfunction

function set_fzf#vim(cmd) abort
	if !pack_manage#IsInstalled('fzf')
		call set_fzf#main()
		delfunction set_fzf#main
	endif
	let s:fzf_options = [
						\ '--multi', '--margin=0%', '--padding=0%',
						\ '--preview', '~/bin/fzf-preview.sh {}',
						\ '--bind', 'ctrl-o:execute-silent(xdg-open {})',
						\ '--footer', 'Ctrl-]/R/K:Preview On/Off/Up/Down｜F/B:PageUP/Down｜G:Sxiv｜O:Open｜V:Vim'
						\ ]
	if get(g:, 'colors_name', '') ==# 'solarized'
		let s:fzf_options += ['--color', &background] " ↑上の色指定が無視される
	endif
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
	let $FZF_DEFAULT_OPTS = substitute($FZF_DEFAULT_OPTS, '--footer \zs\("[^"]\+"\|''[^'']\+''\)', '"<C-]/R/K>:Preview On/Off/Up/Down｜<C-F/B>:PageUP/Down｜<C-G>:edit｜<C-T>/<Enter>:tabedit｜<C-S>:split｜<C-V>:vsplit｜<C-O>:Open"', 'g')
	" let g:fzf_vim = #{
	" 			\ buffers_jump: 1,
	" 			\ preview_window: ['right:50%', 'ctrl-]'],
	" 			\ commits_log_options: '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"',
	" 			\ } " buffers_jump: Buffers 使わず、preview_window: FZF_DEFAULT_OPTS で定義済み
	let v:oldfiles = filter(v:oldfiles, {_, v -> filereadable(expand(v))})
	if !pack_manage#IsInstalled('tabedit')
		" 各種コマンドから tabedit#Tabedit を使っているが、
		" autocmd FuncUndefined tabedit#Tabedit packadd tabedit をしても
		" function 12[30]..<SNR>62_callback[25]..function 12[30]..<SNR>62_callback の処理中にエラーが検出されました:
		" 行   23:
		" Vim(return):E117: 未知の関数です: tabedit#Tabedit
		" のエラーになる
		call set_tabedit#main()
		autocmd! TabEdit
		augroup! TabEdit
		delfunction set_tabedit#main
	endif
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
				\ #{mode: 'n', key: '<silent><Leader>fl', method: 1, cmd: 'BLines'},
				\ #{mode: 'x', key: '<silent><Leader>fl', method: 1, cmd: 'BLines'},
				\ #{mode: 'n', key: '<silent><Leader>fm', method: 1, cmd: 'Marks'},
				\ #{mode: 'x', key: '<silent><Leader>fm', method: 1, cmd: 'Marks'},
				\ #{mode: 'n', key: '<silent>m/',         method: 1, cmd: 'Marks'},
				\ #{mode: 'x', key: '<silent>m/',         method: 1, cmd: 'Marks'},
				\ #{mode: 'n', key: '<silent><Leader>f:', method: 1, cmd: 'History :'},
				\ #{mode: 'x', key: '<silent><Leader>f:', method: 1, cmd: 'History :'},
				\ #{mode: 'n', key: '<silent><Leader>f/', method: 1, cmd: 'History /'},
				\ #{mode: 'x', key: '<silent><Leader>f/', method: 1, cmd: 'History /'}
				\ ])
" \ #{mode: 'n, key: '<silent><Leader>fb', method: 1, cmd: 'Buffers'},
" \ #{mode: 'n, key: '<silent><Leader>ft', method: 1, cmd: 'Tags'},
" \ #{mode: 'x, key: '<silent><Leader>ft', method: 1, cmd: 'Tags'},
" \ #{mode: 'n, key: '<silent><Leader>fw', method: 1, cmd: 'Windows'},
" \ #{mode: 'x, key: '<silent><Leader>fw', method: 1, cmd: 'Windows'},
" \ #{mode: 'x, key: '<silent><Leader>fb', method: 1, cmd: 'Buffers'},
" \ ↑ vim-signature のデフォルト・キーマップをこちらに再定義
	delcommand GitFiles " vim-fugitive の :Git と重なり使いにくくなる
	delcommand Helptags
endfunction

def set_fzf#FZF_open(arg: list<string>): void
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

def set_fzf#solarized(): void
	if get(g:, 'colors_name', '') ==# 'solarized'
		g:terminal_ansi_colors = [
						'#073642', '#dc322f', '#859900', '#b58900', '#268bd2', '#d33682', '#2aa198', '#eee8d5',
						'#002b36', '#cb4b16', '#586e75', '#657b83', '#839496', '#6c71c4', '#93a1a1', '#fdf6e3'
					]
	endif
enddef
