scriptencoding utf-8

function set_asyncomplete#main() abort
	" packadd asyncomplete.vim " ←asyncomplete.vim 自体は ~/.vim/pack/*/start に置かないと最初に読み込んだバッファで働かない
	" let g:asyncomplete_auto_completeopt = 1 " ←デフォルト
	" call asyncomplete#enable_for_buffer()
	" call asyncomplete#force_refresh()
	" let g:asyncomplete_min_chars = 1
	" 以下 plugin {{{3
	" また 'allowlist': ['*'] を使うと、直ぐ消えてしまうケースが出てくる←vim のコメントで再現
	" snippet https://github.com/hrsh7th/vim-vsnip {{{
		packadd vim-vsnip
		" let g:vsnip_snippet_dirs = [expand('~/.vim/vsnip')]
		let g:vsnip_snippet_dir = resolve(expand('~/.vim/vsnip'))
		" vim-vsnip/plugin/vsnip.vim s:expand_or_jump() を置き換え←補完後挿入モードにならないケースが有る
		" asyncomplete.vim で snippet と LSP の連携 https://github.com/hrsh7th/vim-vsnip-integ {{{
			packadd vim-vsnip-integ
			call vsnip_integ#integration#attach()
		" }}}
		" snippet のファイル https://github.com/rafamadriz/friendly-snippets {{{
			packadd friendly-snippets
		" }}}
		" キーマップ {{{
			imap <expr> <C-Y> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-Y>'
			smap <expr> <C-Y> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-Y>'
			" Jump forward or backward
			imap <expr> <C-H> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)'      : '<Left>'
			smap <expr> <C-H> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)'      : '<Left>'
			imap <expr> <C-L> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)'      : '<Right>'
			smap <expr> <C-L> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)'      : '<Right>'
		" }}}
	" }}}
	" LSP との連携する asyncomplete-lsp.vim は vim-lsp 側で行う ← InsertEnter のタイミングではうまく動作しない
	" " omni-function https://github.com/yami-beta/asyncomplete-omni.vim {{{
	packadd asyncomplete-omni.vim
	call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
				\ 'name': 'omni',
				\ 'priority': 7,
				\ 'allowlist': ['*'],
				\ 'blocklist': ['c', 'cpp', 'python', 'vim', 'ruby', 'yaml', 'markdown', 'html', 'css', 'tex', 'sh', 'go','notmuch-draft'],
				\ 'completor': function('asyncomplete#sources#omni#completor'),
				\ 'config': {
					\   'show_source_kind': 1,
					\ },
				\ }))
				" \ 'blocklist': ['c', 'cpp', 'python', 'vim', 'ruby', 'yaml', 'markdown', 'html', 'css', 'tex', 'sh', 'go'],
	" }}}
	" path https://github.com/prabirshrestha/asyncomplete-file.vim {{{
	packadd asyncomplete-file.vim
	call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
				\ 'name': 'file',
				\ 'priority': 5,
				\ 'allowlist': ['*'],
				\ 'blocklist': ['notmuch-draft'],
				\ 'completor': function('asyncomplete#sources#file#completor')
				\ }))
	" }}}
	" buffer https://github.com/prabirshrestha/asyncomplete-buffer.vim {{{
	packadd asyncomplete-buffer.vim
	call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
				\ 'name': 'buffer',
				\ 'priority': 1,
				\ 'allowlist': ['*'],
				\ 'blocklist': ['c', 'cpp', 'python', 'vim', 'ruby', 'yaml', 'markdown', 'html', 'css', 'tex', 'sh', 'go','notmuch-draft'],
				\ 'completor': function('asyncomplete#sources#buffer#completor'),
				\ 'config': {
					\    'max_buffer_size': 500000,
					\  },
					\ }))
				" とりあえず LSP がある filetype は blocklist にしている
	" }}}
	" mail ~/.vim/pack/my-plug/opt/asyncomplete-mail/ {{{
	packadd asyncomplete-mail
	call asyncomplete#register_source(asyncomplete#sources#mail#get_source_options({
				\ 'priority': 5,
				\ 'allowlist': ['notmuch-draft'],
				\ }))
	" }}}
	" " spell ~/.vim/pack/my-plug/opt/asyncomplete-spell.vim/ {{{
	" packadd asyncomplete-spell.vim
	" call asyncomplete#register_source(asyncomplete#sources#spell#get_source_options({
	" 			\ 'priority': 5,
	" 			\ 'allowlist': ['*'],
	" 			\ }))
	" " }}}
endfunction
