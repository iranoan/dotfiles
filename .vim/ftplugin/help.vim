" Vim help 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif

let b:did_ftplugin_user = 1

"--------------------------------
"ファイルタイプ別のグローバル設定
"--------------------------------
if !exists('g:help_plugin')
	let g:help_plugin = 1
	function! HelpFold() abort " 折りたたみ関数
		if v:lnum == 1
			return '>1'
		endif
		let l:c_line=getline(v:lnum)
		if match(l:c_line, '^=\+$') == 0
			return '>1'
		elseif match(l:c_line, '^-\+$') == 0
			return '>2'
		elseif match(l:c_line, '^[^\t ].\+\~$') == 0
			let l:p_line1=getline(v:lnum-1)
			let l:p_line2=getline(v:lnum-2)
			if match(l:p_line1, '^=\+$') == 0 || match(l:p_line1, '^-\+$') == 0
						\ || ( match(l:p_line1, '^[^\s]\+') == 0 && ( match(l:p_line2, '^=\+$') == 0 || match(l:p_line2, '^-\+$') == 0 ) )
				return '='
			else
					return '>3'
			endif
		else
			return '='
		endif
	endfunction
	function! HelpFoldText() abort " 折りたたみテキスト
		let l:line = getline(v:foldstart)
		let l:i = v:foldstart + 1
		if match(l:line,  '^[-=]\+$') == 0
			while l:i < line('$')
				let l:line = getline(l:i)
				if match(l:line,  '^[ \t]') == -1
					break
				endif
				let l:i = l:i + 1
			endwhile
		endif
		return Foldtext_base(substitute(l:line, '\v^[ \t ]*(.+[^ \t])[ \t]*\~$', '\1', ''))
	endfunction
endif

"--------------------------------
"ファイルタイプ別ローカル設定
"--------------------------------
setlocal foldmethod=expr foldexpr=HelpFold() foldtext=HelpFoldText()
setlocal makeprg=textlint\ --format\ compact\ \"%\"
setlocal errorformat=%f:\ line\ %l\\,\ col\ %c\\,\ %trror\ -\ %m
" ~/.vim/pack/my-plug/opt/notmuch-py-vim/doc/notmuch-python.jax: line 41, col 15, Error - 一文に二回以上利用されている助詞 "が" がみつかりました。 (japanese/no-doubled-joshi)
setlocal keywordprg=:help
setlocal commentstring=%s
" ↑コメント書式がない
" キーマップ
nnoremap <buffer><nowait><expr><silent>q  &modifiable ? 'q' : ':bwipeout!<CR>'
nnoremap <buffer><expr>o          &readonly ? "\<C-]>" : 'o'
nnoremap <buffer><expr>i          &readonly ? "\<C-]>" : 'i'
nnoremap <buffer><expr>p          &readonly ? "\<C-o>" : 'p'
