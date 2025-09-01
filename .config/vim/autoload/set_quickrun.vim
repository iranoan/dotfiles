scriptencoding utf-8

function set_quickrun#main() abort
	" QuickFix 拡張 https://github.com/osyo-manga/shabadou.vim {{{
	packadd shabadou.vim " }}}
	" 非同期処理 https://github.com/Shougo/vimproc.vim {{{
	" do-setup: make
	packadd vimproc.vim
	" }}}
	" #include<> に応じてコンパイル・オプション -l 追加 https://github.com/mattn/vim-quickrunex {{{
	packadd vim-quickrunex
	" }}}
	" map
	let g:quickrun_config = {}
	let b:quickrun_config = {} " TeX ではバッファ毎に srcfile を変えたいので予め初期化
	"※vimproc挿入モードで実行すると g が挿入される
	"ウィンドウは上
	let g:quickrun_config._ = {
				\ 'runmode'                         : 'async:remote:vimproc',
				\ 'runner'                          : 'vimproc',
				\ 'runner/vimproc/updatetime'       : 40,
				\ 'outputter'                       : 'error',
				\ 'outputter/quickfix/open_cmd'     : 'topleft copen 8',
				\ 'outputter/buffer/opener'         : 'aboveleft 8split',
				\ 'outputter/buffer/split'          : 'topleft 8sp',
				\ 'outputter/buffer/close_on_empty' : 0,
				\ 'outputter/error/success'         : 'buffer',
				\ 'outputter/error/error'           : 'quickfix',
				\} "outputter/quickfix/into		デフォルト: 0 0 以外を指定すると、結果が出た際に |quickfix-window| へカーソルを移動します。
	" 言語毎の設定
	"C コンパイラは clang 優先 (*.cpp に対しては、おそらく既にそうなっている) {{{
	let g:quickrun_config.c = {
				\ 'type':
				\   executable('clang') ? 'c/clang' :
				\   executable('gcc')   ? 'c/gcc' :
				\                         ' ',
				\ 'cmdopt':
				\   executable('clang') ? '-lm -W -Wall' :
				\   executable('gcc')   ? '-lm -Wall' :
				\                         ' ',
				\ 'runner'                : 'system'
				\}" vimproc のままだと成功時、コンパイル・エラー時のファイル名:行番号の出力の取り込みの両対応ができない
	" }}}
	"gnuplot 成功時は出力しない {{{
	let g:quickrun_config.gnuplot = {
				\ 'outputter/error/success' : 'quickfix',
				\ 'command'                 : 'gnuplot.sh',
				\ 'exec'                    : ['%c %s']
				\}
				" --persist はシェル・スクリプト内でつけている
				" \ 'exec'                    : ['%c %o %s']
				" \ 'cmdopt'                  : '--persist',
	" }}}
	" HTML 使用しているスクリプトは元々エラー以外は何も出力しない {{{
	let g:quickrun_config.html = {
				\ 'outputter/error/success' : 'quickfix',
				\ 'command'                 : 'html-check.sh',
				\ 'cmdopt'                  : '',
				\ 'exec'                    : ['%c %s']
				\}
	" }}}
	" TeX 設定 途中エラーが有っても止めない+zathura が複数起動するので、-pv 無しオプション{{{
	" zathura_sync.sh 内部で処理をしようとすると、非同期処理ができないので止めた
	" 設定が煩雑になるので成功時も失敗時も QuickFix で開いたままにする
	let g:quickrun_config.tex = {
				\ 'outputter/error/success'     : 'quickfix',
				\ 'outputter/quickfix/open_cmd' : 'botright copen 8',
				\ 'command'                     : 'latexmk',
				\ 'cmdopt'                      : '-synctex=1 -file-line-error -interaction=nonstopmode',
				\ 'hook/cd/directory'           : '%S:h',
				\ 'arg'                         : '',
				\ 'exec'                        : ['%c %o %s'],
				\}
				" ↓以下は非同期 vimproc との組み合わせで失敗時も開かない
				" \ 'outputter/error/success': 'null',
				" \ 'hook/close_quickfix/enable_success' :
	augroup SetQuickRun
		autocmd!
		" srcfile は最初に QuickRun を使ったときだけに指定されるので、バッファごとの指定にしないと、最初に実行したファイルに固定されてしまう
		autocmd FileType tex let b:quickrun_config= {'srcfile' : s:GetTeXfile(expand('%:p'))}
		autocmd FileType quickrun nnoremap <buffer><nowait><silent>q  <Cmd>bwipeout!<CR>
	augroup END
	for b in getbufinfo() " 既に開かれている TeX の srcfile を設定する
		let nr = b.bufnr
		let name = b.name
		if name !=# ''
			if getbufvar(nr, '&filetype') ==# 'tex'
				call setbufvar(nr, 'quickrun_config', {'srcfile' : s:GetTeXfile(name)})
			endif
		endif
	endfor
	call pack_manage#SetMAP('vim-quickrun', 'QuickRun', [
				\ #{mode: 'n', key: '<silent><Leader>qr', method: 1, cmd: 'QuickRun'},
				\ #{mode: 'x', key: '<silent><Leader>qr', method: 2, cmd: 'QuickRun'},
				\ #{mode: 'i', key: '<silent><C-\>qr', method: 1, cmd: 'QuickRun'},
				\ ])
	call timer_start(1, {->execute('delfunction set_quickrun#main')})
endfunction

def s:GetTeXfile(f: string): string
	# TeX では \documentclass のないファイルはタイプセットしても意味がない
	# \input によって読み込まれるファイルで、ファイルのカレント・ディレクトリにも \documentclass の書かれたファイルの場合、vimrc#Lcd() によって機械的にバッファのカレント・ディレクトリを親ディレクトリにしている
	# ↑\input や \includegraphics はあくまで読み込み元ファイルを基準に書く必要がるため
	# →シェル・スクリプトと組み合わせてタイプセット対象のフルパスを得る
	# arg f: full path
	var dir: string
	var name: string
	[dir, name] = matchlist(f, '\(.\+/\)\([^/]\+\)')[1 : 2]
	return substitute(dir .. system('cd "' .. dir .. '" && texmother.sh "' .. name .. '"')[ : -2 ], '[^/]\+/\.\./', '', 'g')
					->substitute('/\zs\./', '', 'g')
enddef
