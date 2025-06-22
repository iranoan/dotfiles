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
endfunction
