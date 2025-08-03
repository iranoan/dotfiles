scriptencoding utf-8

function set_md_preview#main() abort
	packadd markdown-preview.nvim
	let g:mkdp_markdown_css = expand('$MYVIMDIR/macros/markdown.css')
	let g:mkdp_preview_options = {
				\ 'mkit': {},
				\ 'katex': {},
				\ 'uml': {},
				\ 'maid': {},
				\ 'disable_sync_scroll': 0,
				\ 'sync_scroll_type': 'middle',
				\ 'hide_yaml_meta': 1,
				\ 'sequence_diagrams': {},
				\ 'flowchart_diagrams': {},
				\ 'content_editable': v:false,
				\ 'disable_filename': 1,
				\ 'toc': {}
				\ }
	call mkdp#util#open_preview_page()
	" マップの付け直し↓ただし隠しバッファの場合付け直しが行われない制限が有る
	for b in getbufinfo()
		if getbufvar(b.bufnr, '&filetype') ==# 'markdown'
			for w in b.windows
				call win_execute(w,'nnoremap <silent><buffer><Leader>v <Cmd>call mkdp#util#open_preview_page()<CR>')
				break " 複数ウィンドウで開いていても、バッファ単位のマッピングなので
			endfor
		endif
	endfor
	augroup MyMarkdown
		autocmd!
		autocmd FileType markdown nnoremap <silent><buffer><Leader>v <Cmd>call mkdp#util#open_preview_page()<CR>
	augroup END
	augroup MKDP_REFRESH_INIT1
		" ↓のエラー対策
		" Error detected while processing BufHidden Autocommands for "<buffer=2>"..function mkdp#rpc#preview_close[11]..mkdp#autocmd#clear_buf:
		" line    1:
		" E216: No such group or event: MKDP_REFRESH_INIT1
		autocmd!
		autocmd FileType markdown echo
	augroup END
endfunction
