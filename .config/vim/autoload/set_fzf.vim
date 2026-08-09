scriptencoding utf-8

function set_fzf#main() abort
	" https://github.com/junegunn/fzf {{{
	" do-setup: ./install --bin
	packadd fzf
	" }}}
	let g:fzf_layout = #{ window: #{ width: 1, height: 1, xoffset: 0 , yoffset: 0 } }
	let g:fzf_colors = {
				\ 'fg':       ['fg', 'Pmenu'],
				\ 'bg':       ['bg', 'PmenuSel'],
				\ 'hl':       ['fg', 'PmenuMatch'],
				\ 'fg+':      ['fg', 'PmenuSel'],
				\ 'bg+':      ['bg', 'Pmenu'],
				\ 'hl+':      ['fg', 'PmenuMatch'],
				\ 'gutter':   ['fg', 'LineNr'],
				\ 'pointer':  ['fg', 'Removed'],
				\ 'marker':   ['fg', 'Removed'],
				\ 'border':   ['fg', 'Normal'],
				\ 'header':   ['fg', 'Normal'],
				\ 'info':     ['fg', 'Type'],
				\ 'spinner':  ['fg', 'Added'],
				\ 'query':    ['fg', 'Normal'],
				\ 'disabled': ['fg', 'Comment'],
				\ 'prompt':   ['fg', 'Function'],
				\ }
	let g:fzf_action = #{
				\ ctrl-g: 'edit',
				\ ctrl-t: function('s:fzfOpen'),
				\ ctrl-s: 'split',
				\ ctrl-v: 'vsplit',
				\ enter:  function('s:fzfOpen'),
				\ ctrl-o: function('s:fzfOpen')
				\ } " 他で sink を使うと、この設定は無視されるので注意←:help fzf-global-options-supported-by-fzf#wrap
				" \ ctrl-e: 'edit', カーソルを入力の末尾移動と重なる
	let $FZF_DEFAULT_OPTS = substitute($FZF_DEFAULT_OPTS, '--footer "[^"]\+"', '', 'g')
	call timer_start(1, {->execute('delfunction set_fzf#main')})
endfunction

function set_fzf#help() abort
	if !pack_manage#IsInstalled('fzf')
		call set_fzf#main()
	endif
	let g:fzf_help = ['--footer', '<C-]/R/K/^>:Preview On/Off/Up/Down/[No]Wrap｜<Enter>:Open｜W:[No]Wrap']
	call pack_manage#SetMAP('fzf-help', 'HelpTags', [
				\ #{mode: 'n', key: '<Leader>fH', method: 1, cmd: 'HelpTags'},
				\ #{mode: 'x', key: '<Leader>fH', method: 1, cmd: 'HelpTags'},
				\ ] )
	call timer_start(1, {->execute('delfunction set_fzf#help')})
endfunction

function set_fzf#neoyank_sub() abort
	let g:neoyank#file = $MYVIMDIR .. "cache/neoyank_history.json"
	packadd neoyank.vim
	silent call neoyank#_yankpost()
	silent call neoyank#_append()
	call timer_start(1, {->execute('delfunction set_fzf#neoyank_sub')})
endfunction

function set_fzf#neoyank(cmd) abort
	if !pack_manage#IsInstalled('fzf')
		call set_fzf#main()
	endif
	if !pack_manage#IsInstalled('neoyank.vim')
		call set_fzf#neoyank_sub()
		autocmd! SetNeoyank
		augroup! SetNeoyank
	endif
	call pack_manage#SetMAP('fzf-neoyank', a:cmd, [
				\ #{mode: 'n', key: '<Leader>fy', method: 1, cmd: 'FZFNeoyank'},
				\ #{mode: 'n', key: '<Leader>fY', method: 1, cmd: 'FZFNeoyank " P'},
				\ #{mode: 'x', key: '<Leader>fy', method: 1, cmd: 'FZFNeoyankSelection'},
				\ ] )
	call timer_start(1, {->execute('delfunction set_fzf#neoyank')})
endfunction

function set_fzf#tabs() abort
	if !pack_manage#IsInstalled('fzf')
		call set_fzf#main()
	endif
	let g:fzf_tabs_options = ['--preview', '~/bin/fzf-preview.sh {2}', '--footer', 'Ctrl-]/K/R/^:Preview On/Off/Up/Down/[No]Wrap｜F/B:PageUP/Down｜G:Sxiv｜O:Open｜V:Vim｜W:[No]Wrap']
	call pack_manage#SetMAP('fzf-tabs', 'FZFTabOpen', [
				\ #{mode: 'n', key: '<Leader>ft', method: 1, cmd: 'FZFTabOpen'},
				\ #{mode: 'v', key: '<Leader>ft', method: 1, cmd: 'FZFTabOpen'},
				\ #{mode: 'n', key: '<Leader>fb', method: 1, cmd: 'FZFTabOpen'},
				\ #{mode: 'n', key: '<Leader>fw', method: 1, cmd: 'FZFTabOpen'},
				\ ])
	call timer_start(1, {->execute('delfunction set_fzf#tabs')})
endfunction

function set_fzf#vim(cmd) abort
	if !pack_manage#IsInstalled('fzf')
		call set_fzf#main()
	endif
	let s:fzf_options = [
						\ '--multi', '--margin=0%', '--padding=0%',
						\ '--preview', '~/bin/fzf-preview.sh {}',
						\ '--bind', 'ctrl-o:execute-silent(xdg-open {})',
						\ '--footer', 'Ctrl-]/K/R/^:Preview On/Off/Up/Down/[No]Wrap｜F/B:PageUP/Down｜G:Sxiv｜O:Open｜V:Vim｜W:[No]Wrap'
						\ ]
	let $FZF_DEFAULT_COMMAND = executable("fdfind")
						\ ? 'fdfind.sh .'
						\ : 'find -L . -type d \( -name .texlive2023 -o -name .npm -o -name .thumbnails -o -name thumbnails -o -name .log -o -name .tmp -o -path "$HOME/Mail/.*/new" -o -path "$HOME/Mail/.*/cur" -o -path "$HOME/Mail/.*/tmp" -o -path "$HOME/Mail/.notmuch/xapian" -o -path .local/share/Trash -o -path node_modules -o -path go/pkg -o -path "$HOME/PDF" -o -path "$HOME/img/スクリーンショット" -o -name .git -o -name cache -o -name .cache -o -name .Trash -o -name .ecryptfs -o -name .Private -o -name kpeoplevcard \) -prune -o \( -type f -o -type l \) ! -name "*.aux" ! -name "*.snm" ! -name "*.nav" ! -name "*.synctex.gz" ! -name "*.cer" ! -name "*.chm" ! -name "*.chw" ! -name "*.crt" ! -name "*.dll" ! -name "*.dvi" ! -name "*.exe" ! -name "*.fdb_latexmk" ! -name "*.gpg" ! -name "*.hlp" ! -name "*.hmereg" ! -name "*.o" ! -name "*.obj" ! -name "*.oll" ! -name "*.opp" ! -name "*.pfa" ! -name "*.pl3" ! -name "*.ppm" ! -name "*.reg" ! -name "*.sqlite" ! -name "*.tfm" ! -name "*.ttf" ! -name "*.vf" ! -name ".*.sw?" ! -name a.out ! -name "*.jar" ! -name "*.pyc" ! -name "*.vbox" ! -name "*.nvram" ! -name "*.cur" ! -name "*.class" ! -name "*.vbox-prev" ! -name "*.fls" ! -name .viminfo ! -name viminfo ! -name "*.ltjruby" ! -name ".~lock.*#" -printf "%P\n" 2> /dev/null' "-prune 前の -path が効いていないが、シェルに設定した FZF_DEFAULT_COMMAND に合わせてある
	command! -bang -nargs=? -complete=dir Files call fzf#vim#files( <q-args>, #{options: s:fzf_options + ['--prompt', 'Files> ']}, <bang>0)
					" バイナリ・ファイルとメールを除外 (メールはファイル名だけ見ても分らない)
	" TabEdit が --multi に対応したつもり History そのものは、コマンドや検索履歴で使うので、上書きしない
	command! -bang -nargs=* HISTORY call fzf#run(
				\ fzf#wrap(
					\ #{
						\ options: s:fzf_options + ['--header-lines', !empty(expand('%')), '--prompt', 'Hist> '],
						\ source:  fzf#vim#_recent_files(),
					\ },
					\ <bang>0
					\ )
				\ )
	call filter(v:oldfiles, {_, v -> filereadable(expand(v))}) " 削除・移動ファイルを除外
	let $FZF_DEFAULT_OPTS = substitute($FZF_DEFAULT_OPTS, '--footer \zs\("[^"]\+"\|''[^'']\+''\)', '"<C-]/R/K/^>:Preview On/Off/Up/Down｜<C-F/B>:PageUP/Down｜<C-G>:edit｜<C-T>/<Enter>:tabedit｜<C-S>:split｜<C-V>:vsplit｜<C-O>:Open｜W:[No]Wrap"', 'g')
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
	endif
	call pack_manage#SetMAP('fzf.vim', a:cmd, [
				\ #{mode: 'n', key: '<silent><Leader>fc', method: 1, cmd: 'Commands'},
				\ #{mode: 'x', key: '<silent><Leader>fc', method: 1, cmd: 'Commands'},
				\ #{mode: 'n', key: '<silent><Leader>fg', method: 1, cmd: 'GFiles ?'},
				\ #{mode: 'x', key: '<silent><Leader>fg', method: 1, cmd: 'GFiles ?'},
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
	command! Colors call s:colors(<bang>0)
	call timer_start(1, {->execute('delfunction set_fzf#vim')})
endfunction

function s:colors(...)
	" :Colors 用の関数
	" 本来の関数は罫線の幅や colorscheme の個数を考慮していない幅なので、それを直す
	let colors = split(globpath(&rtp, "colors/*.vim"), "\n")
	if has('packages')
		let colors += split(globpath(&packpath, "pack/*/opt/*/colors/*.vim"), "\n")
	endif
	let colors = fzf#vim#_uniq(map(colors, "fnamemodify(v:val, ':t')[:-5]"))

	" Put the current colorscheme at the top
	if exists('g:colors_name')
		let s:colors_name = g:colors_name
		let colors = [g:colors_name] + filter(colors, 'g:colors_name != v:val')
	endif

	let spec = {
				\ 'source':  colors,
				\ 'sink':    'colo',
				\ 'options': ['+m', '--prompt', 'Colors> ']
				\}

	let snr = $'<SNR>{getscriptinfo(#{name: '/fzf.vim/autoload/fzf/vim.vim$'})[0].sid}_'
	if !a:1 " We can't set up IPC in fullscreen mode in Vim
		let fifo = fzf#vim#ipc#start({ msg -> execute('colo '.msg) })
		let len_colors = len(colors)
		if len(fifo)
			call extend(spec.options, ['--no-tmux', '--no-padding', '--no-margin', '--bind', 'focus:execute-silent:echo {} > '.fifo])
			let spec.exit = function(snr .. 'colors_exit')
			let maxwidth = max(map(copy(colors), 'strwidth(v:val)'))
			let spec.window = { 'width': maxwidth + 8 + 2 + 2 * len('' .. len_colors) + 1, 'height': len(colors) + 5 }
		endif
	endif

	call call(snr .. 'fzf', ['colors', spec, a:000])
endfunction

def s:fzfOpen(arg: list<string>): void
	var dir: string = getcwd() .. '/'
	for f in arg
		if match(f, '^[~/]') != 0
			tabedit#Tabedit(dir .. f)
		else
			tabedit#Tabedit(f)
		endif
	endfor
enddef
