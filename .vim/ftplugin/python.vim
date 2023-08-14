" Python 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

"--------------------------------
"ファイルタイプ別のグローバル設定
"--------------------------------
if !exists('g:py_plugin')
	let g:py_plugin = 1
	augroup myPython " 通常はローカル設定で良いが、vim スクリプト内で書かれていた時/逆に python スクリプト内の vim スクリプトにカーソル移動して設定が変更後に改めてカーソル移動した時に元に戻すため
		autocmd!
		" 本当にタブ文字が有れば2文字幅、それ以外では4文字空白の扱い 80桁に線を入れる
		autocmd FileType python setlocal tabstop=4 softtabstop=0 expandtab shiftwidth=4 colorcolumn=80
					\ errorformat=%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
					\ foldexpr=PythonFold() foldmethod=expr
					\ iskeyword-=? " Vim スクリプト の is?, isnot? を syntax highlight で有効にするために追加した ? を除く
		" --------------------------------
		" ヘルプ
		" autocmd FileType python setlocal keywordprg=:terminal\ ++close\ pydoc3
	augroup END
endif
"--------------------------------
"ファイルタイプ別ローカル設定
"--------------------------------
" autocmd のダブらせている分
setlocal tabstop=4 softtabstop=4 expandtab shiftwidth=0 colorcolumn=80
" setlocal keywordprg=pydoc3 だと os.path などの選択状態で思った動作をしない←コマンドラインに出てしまう
setlocal errorformat=%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
"--------------------------------
" setlocal makeprg=python3\ \"%\"
" ↑標準入力からの入力待ちが有る場合いつまで経っても終わらない←素直に QuickRun を使えば良い
"--------------------------------
" デバッガ
" nnoremap <silent><buffer><Leader>db :terminal pdb3 "%"<CR><C-w>x
" ひとつ下にターミナルで起動する
" ↓Web ページをヘルプ使うバージョン上の keywordprg の設定とペア
" function! s:pyhelp(word) abort
" 	execute 'terminal ++close w3m -o confirm_qq=0 https://docs.python.org/ja/3/library/functions.html\#' . a:word
" endfunction
" command! -nargs=1 PyHelp call <SID>pyhelp(<f-args>)
" 整形
" nnoremap <buffer>= :call Autopep8(0)<CR>
" vnoremap <buffer>= :call Autopep8(1)<CR>
" function Autopep8( select ) range abort " autopep8 format
" 	" equalprg では変換後に日本語部分が文字化けする
" 	call s:FilterShell( 'autopep8 --max-line-length 95 -', a:select, a:firstline, a:lastline, '' )  " ~/.config/pep8
" endfunction
setlocal equalprg=autopep8\ -
setlocal formatprg=autopep8\ -
" --max-line-length\ 100 " ~/.config/pep8
" setlocal formatexpr=
"--------------------------------
" context_filetype を使っていて、setfiletype=vim の切り替えをするをするか
" if exists('g:context_filetype#filetypes.python')
" 	let b:context_filetype = g:context_filetype#filetypes.python
" else
" 	let b:context_filetype = []
" endif
" nnoremap <silent><buffer><leader><leader>c :call <SID>change_context_filetype()<CR>
" function s:change_context_filetype() abort
" 	if g:context_filetype#filetypes.python == []
" 		let g:context_filetype#filetypes.python = b:context_filetype
" 	else
" 		let g:context_filetype#filetypes.python = []
" 	endif
" endfunction
"--------------------------------
" fold 折り畳み
" autocmd FileType python set foldmethod=indent
" https://habamax.github.io/2020/02/03/vim-folding-for-python.html
setlocal foldexpr=PythonFold() foldmethod=expr
function PythonFold() abort
	let l:line = getline(v:lnum)
	let l:next = getline(v:lnum + 1)
	" if l:line ==? '' && getline(v:lnum+1) ==? '' " 連続する空行はトップに含める
	if l:line ==? '' " 空行は一つ前のレベル
		return '='
	elseif match(l:line, '^#\s\?\(def\s\+\w\+([^)]*)\|class\s\+\w\+\):') != -1  " コメント化されたクラス/関数はトップ扱い
		return '>1'
	endif
	" 以下インデントの深さ
	let l:indent = indent(v:lnum)/&shiftwidth
	if v:lnum == 1
		let l:indent_pre = 0
	elseif getline(v:lnum-1) ==# ''
		return '>' . (l:indent+1)
	else
		let l:indent_pre = indent(nextnonblank(v:lnum-1))/&shiftwidth
	endif
	if l:indent_pre + 1 < l:indent
		let l:indent = l:indent_pre + 1
	endif
	let l:indent_next = indent(nextnonblank(v:lnum+1))/&shiftwidth
	if l:indent_next > l:indent && l:line !~# '^\s*$'
		return '>' . (l:indent+1)
	" 連続するコメント行
	elseif match(l:line, '^\s*#') != -1 " コメント行
		if v:lnum == 0
			if match(getline(v:lnum+1), '^\s*#') != -1   " 次行もコメント行
				return '>1'
			else
				return '0'
			end
		elseif match(getline(v:lnum-1), '^\s*#') == -1 " 前行非コメント
			if match(l:next, '^\s*#') != -1              " 次行コメント行
				return '>' . (l:indent+1)                  " コメントの始まり
			else                                         " 次行非コメント行
				return '<' . (l:indent+1)
			endif
		else                                           " 前行コメント
			if match(l:next, '^\s*#') == -1              " 次行非コメント行
				return '<' . (l:indent+1)
			endif
			return '='
		endif
	elseif l:indent != 0
		if l:indent_pre == l:indent
			return '='
		endif
		return l:indent
	else
		return 0
	endif
endfunc
