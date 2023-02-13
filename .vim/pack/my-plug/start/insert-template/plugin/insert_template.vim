vim9script

augroup Template
	autocmd!
	autocmd BufNewFile *.sh         insert_template#Insert_template('sh.sh')
	autocmd BufNewFile *.tex        insert_template#Insert_template('TeX.tex')
	autocmd BufNewFile *.htm,*.html insert_template#Insert_template('HTML.html')
	autocmd BufNewFile *.plt        insert_template#Insert_template('Gnuplot.plt')
	autocmd BufNewFile *.py         insert_template#Insert_template('Python.py')
	autocmd BufNewFile *.css        insert_template#Insert_template('CSS.css')
	autocmd BufNewFile *.vim        insert_template#Insert_template('vim.vim')
augroup END
