vim9script
# Vim help 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif

b:did_ftplugin_user = 1

# ファイルタイプ別のグローバル設定 {{{1
if !exists('g:help_plugin')
	g:help_plugin = 1
	# augroup FileTypeHELP
	# 	autocmd!
	# 	autocmd BufWinEnter * setlocal foldlevel=99
	# augroup END

	def g:HelpFold(): string # 折りたたみ関数
		if v:lnum == 1
			return '>1'
		endif
		var c_line: string = getline(v:lnum)
		var p_line1: string
		var p_line2: string
		if match(c_line, '^=\+$') == 0
			return '>1'
		elseif match(c_line, '^-\+$') == 0
			return '>2'
		elseif match(c_line, '^[^\t ].\+\~$') == 0
			p_line1 = getline(v:lnum - 1)
			p_line2 = getline(v:lnum - 2)
			if match(p_line1, '^=\+$') == 0 || match(p_line1, '^-\+$') == 0
						|| ( match(p_line1, '^[^\s]\+') == 0 && ( match(p_line2, '^=\+$') == 0 || match(p_line2, '^-\+$') == 0 ) )
				return '='
			else
					return '>3'
			endif
		else
			return '='
		endif
	enddef

	def g:HelpFoldText(): string # 折りたたみテキスト
		var line: string = getline(v:foldstart)
		var i: number = v:foldstart + 1
		if match(line, '^[-=]\+$') == 0
			while i <= line('$')
				line = getline(i)
				if match(line, '^[ \t]') == -1
					break
				endif
				i += 1
			endwhile
		endif
		var line_width: number = winwidth(0) - &foldcolumn
		var cnt: string = printf('[%' .. len(line('$')) .. 's] ', (v:foldend - v:foldstart + 1))
		if &number
			line_width -= max([&numberwidth, len(line('$'))])
		# sing の表示非表示でずれる分の補正
		elseif &signcolumn ==# 'number'
			cnt ..= '  '
		endif
		if &signcolumn ==# 'auto'
			cnt ..= '  '
		endif
		line_width -= 2 * (&signcolumn ==# 'yes' ? 1 : 0)
		line = strcharpart(printf('%-' .. ( &shiftwidth * (v:foldlevel - 1) + 2) .. 's%s', '▸',
			substitute(line, '\*\(.+\)\*', '\1', 'g')->substitute('|\(.+\)|', '\1', 'g')
			), 0, line_width - len(cnt))
		# 全角文字を使っていると、幅でカットすると広すぎる
		# だからといって strcharpart() の代わりに strpart() を使うと、逆に余分にカットするケースが出てくる
		# ↓末尾を 1 文字づつカットしていく
		while strdisplaywidth(line) > line_width - len(cnt)
			line = slice(line, 0, -1)
		endwhile
		return printf('%s%' .. (line_width - strdisplaywidth(line)) .. 'S', line, cnt)
	enddef
endif

# ファイルタイプ別ローカル設定 {{{1
setlocal foldmethod=expr foldexpr=g:HelpFold() foldtext=g:HelpFoldText()
setlocal makeprg=textlint\ --format\ compact\ \"%\"
setlocal errorformat=%f:\ line\ %l\\,\ col\ %c\\,\ %trror\ -\ %m
# ~/.config/vim/pack/my-plug/opt/notmuch-py-vim/doc/notmuch-python.jax: line 41, col 15, Error - 一文に二回以上利用されている助詞 "が" がみつかりました。 (japanese/no-doubled-joshi)
setlocal keywordprg=:help
setlocal commentstring=%s
# ↑コメント書式がない
# キーマップ
nnoremap <buffer><nowait><expr><silent>q  &modifiable ? 'q' : ':bwipeout!<CR>'
nnoremap <buffer><expr>o          &readonly ? "\<C-]>" : 'o'
nnoremap <buffer><expr>i          &readonly ? "\<C-]>" : 'i'
nnoremap <buffer><expr>p          &readonly ? "\<C-o>" : 'p'
# タグに移動
nnoremap <buffer><tab>            <Cmd>call search('\|\zs.\{-}\|', 'w')<CR>:nohlsearch<CR>
nnoremap <buffer><S-tab>          <Cmd>call search('\|\zs.\{-}\|', 'wb')<CR>:nohlsearch<CR>
nnoremap <buffer><CR>             <C-]>
