vim9script

export def Insert_template(s: string): void # ~/Templates/ からテンプレート挿入 {{{2
	# 普通に r を使うと空行ができる
	# ついでに適当な位置にカーソル移動
	execute ':1r ++encoding=utf-8 ~/Templates/' .. s
	:-join
	if &filetype ==# 'css' || &filetype ==# 'python'
		execute ':$'
	elseif index(['sh', 'tex', 'gnuplot'], &filetype) != -1
		execute ':' .. (line('$') - 1)
	elseif &filetype ==# 'html'
		execute ':' .. (line('$') - 2)
	else
		normal! gg}
	endif
enddef
