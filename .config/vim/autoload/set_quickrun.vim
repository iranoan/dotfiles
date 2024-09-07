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
				\   executable('cl')    ? 'c/vc'  :
				\   executable('clang') ? 'c/clang' :
				\   executable('gcc')   ? 'c/gcc' :'',
				\ 'cmdopt'                  : '-lm',
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
	" TeX 設定 成功時は出力しない←途中エラーが有っても止めない等のオプション追加 {{{
	" zathura_sync.sh 内部で処理をしようとすると、非同期処理ができないので止めた
	" TeX を素直に latexmk を使う時の設定
	let g:quickrun_config.tex = {
				\ 'outputter'                        : 'multi:buffer:quickfix',
				\ 'outputter/buffer/bufname'         : 'quickrun://TeX-log',
				\ 'outputter/buffer/opener'          : 'rightbelow 4split',
				\ 'outputter/quickfix/open_cmd'      : 'call Quickrn2qf()',
				\ 'hook/close_buffer/enable_failure' : 0,
				\ 'command'                          : 'latexmk',
				\ 'cmdopt'                           : '-synctex=1 -file-line-error -interaction=nonstopmode',
				\ 'hook/cd/directory'                : '%S:h',
				\ 'arg'                              : '',
				\ 'exec'                             : ['%c %o %s'],
				\}
				" \ 'outputter/error/success': 'null', " ←これだと非同期 vimproc との組み合わせで失敗時も開かない
				" \ 'hook/close_quickfix/enable_success' : 1, 上と同じ
				" \ 'cmdopt'                           : '-pv -src-specials -synctex=1 -file-line-error -interaction=nonstopmode', " zathura が複数起動するので、-pv を無くしたものを使う
	" srcfile は最初に QuickRun を使ったときだけに指定されるので、バッファごとの指定にしないと、最初に実行したファイルに固定されてしまう
	let b:quickrun_config.tex = {'srcfile' : substitute(system('texmother.sh ' . expand('%')), '\n', '', ''),}
	function Qf2qucikrun() abort
		let l:qf_b = 0
		let l:qr_b = 0
		for l:i in getwininfo()
			let l:b_i = l:i.bufnr
			if l:i.quickfix
				let l:qf_b = l:b_i
			elseif bufname(l:b_i) ==# 'quickrun://TeX-log'
				let l:qr_b = l:b_i
			endif
		endfor
		if l:qf_b == 0
			QuickRun
			return
		elseif l:qr_b != 0
			cclose
			QuickRun
			return
		endif
		for l:i in getbufinfo()
			if l:i.name ==# 'quickrun://TeX-log'
				let l:c_b = bufnr()
				call win_gotoid(bufwinid(l:qf_b))
				execute 'buffer! ' . l:i.bufnr
				call win_gotoid(bufwinid(l:c_b))
				QuickRun
				return
			endif
		endfor
		cclose
		QuickRun
	endfunction
	function Quickrn2qf() abort
		let l:c_b = bufnr()
		for l:i in getwininfo()
			if bufname(l:i.bufnr) ==# 'quickrun://TeX-log'
				let l:qr_b =  l:i.bufnr
			endif
		endfor
		call win_gotoid(bufwinid(l:qr_b))
		for l:i in getbufinfo()
			if has_key(l:i.variables, 'current_syntax')
				if l:i.variables.current_syntax ==# 'qf'
					execute 'buffer! ' . l:i.bufnr
					call win_gotoid(bufwinid(l:c_b))
					return
				endif
			endif
		endfor
		" qf が無かった
		quit
		execute substitute(g:quickrun_config.tex['outputter/buffer/opener'], '\v(\d+)v?split', 'copen \1', '')
	endfunction
	augroup QuickRnnTeXKeymap
		autocmd!
		autocmd FileType tex nnoremap <silent><buffer><Leader>qr       :call Qf2qucikrun()<CR>
	augroup END
	if &filetype ==# 'tex' " 開いたファイル自身の設定
		nnoremap <silent><buffer><Leader>qr       :call Qf2qucikrun()<CR>
	endif
	" }}}
	" Python は python3 を使う←Ubuntu 21.04 では python コマンドは、python3
	" let g:quickrun_config.python = { 'command'                : 'python3'}
	" vim help
endfunction
