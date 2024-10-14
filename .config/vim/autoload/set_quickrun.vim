scriptencoding utf-8

function set_quickrun#main() abort
	packadd vim-quickrun
	" QuickFix 拡張 https://github.com/osyo-manga/shabadou.vim {{{
	packadd shabadou.vim " }}}
	" 非同期処理 https://github.com/Shougo/vimproc.vim {{{
	packadd vimproc.vim " }}}
	" #include<> に応じてコンパイル・オプション -l 追加 https://github.com/mattn/vim-quickrunex {{{
	packadd vim-quickrunex
	" }}}
	" map
	let g:quickrun_config = {}
	let b:quickrun_config = {} " TeX ではバッファ毎に srcfile を変えたいので予め初期化
	"※vimproc挿入モードで実行すると g が挿入される
	"ウィンドウは上
	let g:quickrun_config['_'] = {
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
				\}
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
	let g:quickrun_config.tex = {
				\ 'outputter/error/success'     : 'quickfix',
				\ 'outputter/quickfix/open_cmd' : 'botright copen 8',
				\ 'command'                     : 'latexmk',
				\ 'cmdopt'                      : '-synctex=1 -file-line-error -interaction=nonstopmode',
				\ 'hook/cd/directory'           : '%S:h',
				\ 'arg'                         : '',
				\ 'exec'                        : ['%c %o %s'],
				\ 'srcfile'                     : substitute(system('texmother.sh ' .. expand('%')), '\n', '', '')
				\}
				" \ 'outputter/error/success': 'null', " ←これだと非同期 vimproc との組み合わせで失敗時も開かない
				" \ 'hook/close_quickfix/enable_success' : 1, 上と同じ
		autocmd!
		" srcfile は最初に QuickRun を使ったときだけに指定されるので、バッファごとの指定にしないと、最初に実行したファイルに固定されてしまう
		autocmd FileType tex let b:quickrun_config.tex = {'srcfile' : substitute(system('texmother.sh ' .. expand('%')), '\n', '', '')}
	augroup END
endfunction
