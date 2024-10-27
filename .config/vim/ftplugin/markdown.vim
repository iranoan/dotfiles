scriptencoding utf-8
" Markdown の設定
" 幾つかはデフォルトで上書きされるので $MYVIMDIR/after/ftplugin/markdown.vim

" ファイルタイプ別のグローバル設定 {{{1
if !exists('g:did_ftplugin_html')
	let g:did_ftplugin_markdown = 1
	let g:markdown_folding = 1  " Markdown で折りたたみ
	" augroup Markdown
	" 	autocmd!
	" augroup END
endif
