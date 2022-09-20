" 独自の filetype ファイル
scriptencoding utf-8
if exists('s:did_load_filetypes')
	finish
endif
let s:did_load_filetypes = 1
augroup filetypedetect
	autocmd!
	"*.plt は mimetypeが設定されていないことも有り得る
	autocmd BufNewFile,BufRead *.plt          set filetype=gnuplot
	autocmd BufNewFile,BufRead .bash_history,.xprofile,~/dotfiles/.bash/*,~/.bash/* set filetype=sh
	autocmd BufNewFile,BufRead .textlintrc,.stylelintrc set filetype=json
	autocmd BufNewFile,BufRead .msmtprc       set filetype=msmtp | source $VIM/addons/syntax/msmtp.vim | setlocal commentstring=#%s
	autocmd BufNewFile,BufRead tags-??        set filetype=tags
	autocmd BufEnter           */textern/textern-*/*.txt setlocal syntax=mail foldmethod=syntax
	" autocmd BufNewFile,BufRead *.htm,*.html   setlocal filetype=html
	autocmd BufNewFile         *.sh           call <SID>insert_templte('sh.sh')
	autocmd BufNewFile         *.tex          call <SID>insert_templte('TeX.tex')
	autocmd BufNewFile         *.htm,*.html   call <SID>insert_templte('HTML.html')
	autocmd BufNewFile         *.plt          call <SID>insert_templte('Gnuplot.plt')
	autocmd BufNewFile         *.py           call <SID>insert_templte('Python.py')
	autocmd BufNewFile         *.css          call <SID>insert_templte('CSS.css')
	autocmd BufNewFile         *.vim          call <SID>insert_templte('vim.vim')
	autocmd BufEnter           *.sw?          bwipeout!             " スワップファイルは閉じる
	autocmd BufEnter           tags           edit ++encoding=utf-8 " tags ファイルは UTF-8 強制←開き直しているが他にもっと良い方法が解らない
augroup END

function s:insert_templte(s) abort " ~/Templates/ からテンプレート挿入 {{{2
	" 普通に r を使うと空行ができる
	" ついでに適当な位置にカーソル移動
	execute '1r ++encoding=utf-8 ~/Templates/' .. a:s
	-join
	if &filetype ==# 'css' || &filetype ==# 'python'
		execute ':$'
	elseif &filetype ==# 'sh' || &filetype ==# 'tex' || &filetype ==# 'gnuplot'
		execute ':' .. (line('$') - 1)
	elseif &filetype ==# 'html'
		execute ':' .. (line('$') - 2)
	else
		let @/ = '^$' | normal! ggn
		nohlsearch
	endif
endfunction
