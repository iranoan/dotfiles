scriptencoding utf-8
scriptversion 4

function set_asyncomplete#main() abort
	" packadd asyncomplete.vim " ←asyncomplete.vim 自体は ~/.vim/pack/*/start に置かないと最初に読み込んだバッファで働かないケースが有る
	" 具体的には notmuch-draft
	" バッファを開き終わった後に
	"     call asyncomplete#enable_for_buffer()
	" をすれば働くが、この関数の最後に追記してもダメだった
	" → FileType notmuch-draft をトリガーも加える
	" let g:asyncomplete_auto_completeopt = 1 " ←デフォルト
	" call asyncomplete#force_refresh()
	" let g:asyncomplete_min_chars = 1
	" 以下 plugin {{{3
	" また 'allowlist': ['*'] を使うと、直ぐ消えてしまうケースが出てくる←vim のコメントで再現
	" snippet https://github.com/hrsh7th/vim-vsnip {{{
		packadd vim-vsnip
		if !exists('g:vsnip_filetypes')
			let g:vsnip_filetypes = {}
		endif
		let g:vsnip_filetypes.xhtml = ['html']
		" let g:vsnip_snippet_dirs = [expand('~/.vim/vsnip')]
		let g:vsnip_snippet_dir = resolve(expand('~/.vim/vsnip'))
		" vim-vsnip/plugin/vsnip.vim s:expand_or_jump() を置き換え←補完後挿入モードにならないケースが有る
		" asyncomplete.vim で snippet と LSP の連携 https://github.com/hrsh7th/vim-vsnip-integ {{{
			packadd vim-vsnip-integ
			call vsnip_integ#integration#attach()
			call asyncomplete#register_source(extend(asyncomplete#get_source_info('vsnip'), #{priority: 10}))
		" }}}
		" snippet のファイル https://github.com/rafamadriz/friendly-snippets {{{
			packadd friendly-snippets
		" }}}
		" キーマップ {{{
			" <C-j> はポップアップ候補の移動に使っている
			" inoremap <expr><C-j>   vsnip#expandable() ? '<Plug>(vsnip-expand)'         : '<C-j>'
			" snoremap <expr><C-j>   vsnip#expandable() ? '<Plug>(vsnip-expand)'         : '<C-j>'
			inoremap <expr><C-Y>   vsnip#available(1) ? (pumvisible() ? '<Plug>(vsnip-expand-or-jump)' : '<Plug>(vsnip-jump-next)') : '<C-Y>'
			snoremap <expr><C-Y>   vsnip#available(1) ? (pumvisible() ? '<Plug>(vsnip-expand-or-jump)' : '<Plug>(vsnip-jump-next)') : '<C-Y>'
			" Jump forward or backward
			inoremap <expr><Tab>   vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-N>' : '<Tab>'
			snoremap <expr><Tab>   vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : pumvisible() ? '<C-N>' : '<Tab>'
			inoremap <expr><S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-P>' : '<S-Tab>'
			snoremap <expr><S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : pumvisible() ? '<C-p>' : '<S-Tab>'
		" }}}
	" }}}
	" LSP との連携する asyncomplete-lsp.vim は vim-lsp 側で行う ← InsertEnter のタイミングではうまく動作しない
	" omni-function https://github.com/yami-beta/asyncomplete-omni.vim {{{
	packadd asyncomplete-omni.vim
	call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
				\ 'name': 'omni',
				\ 'priority': 7,
				\ 'allowlist': ['*'],
				\ 'blocklist': ['c', 'cpp', 'python', 'vim', 'ruby', 'yaml', 'markdown', 'css', 'tex', 'sh', 'go','notmuch-draft'],
				\ 'completor': function('asyncomplete#sources#omni#completor'),
				\ 'config': {
					\   'show_source_kind': 1,
					\ },
				\ }))
				" \ 'blocklist': ['c', 'cpp', 'python', 'vim', 'ruby', 'yaml', 'markdown', 'html', 'css', 'tex', 'sh', 'go','notmuch-draft'],
				" LSP を優先させたいので、ブロックしているが、HTML も含めると inoremap <buffer> </ </<C-x><C-o> が効かなくなる
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
	" spell ~/.vim/pack/my-plug/opt/asyncomplete-spell/ {{{
	packadd asyncomplete-spell
	call asyncomplete#register_source(asyncomplete#sources#spell#get_source_options({
				\ 'priority': 4,
				\ 'allowlist': ['*'],
				\ }))
	" }}}
	let g:asyncomplete_preprocessor = [function('s:asyncomplete_preprocessor')]
endfunction

def s:asyncomplete_preprocessor(options: dict<any>, a_matches: dict<dict<any>>): void
	var items: list<dict<any>>
	var src_items: list<dict<any>>
	var base = options.base
	var priority: number
	def FilterSpell(ls: list<dict<any>>): list<dict<any>>
		if empty(ls)
			return []
		endif
		# var menu = ls[0].menu
		if ls[0].menu ==# '[Fcc]'
			return filter(ls, (key, val) => val.word =~? '^\c' .. escape(base, '\.$*~'))
		endif
		return ls
	enddef
	for [source_name, matches] in items(a_matches)
		priority = get(asyncomplete#get_source_info(source_name), 'priority', 0)
		if source_name ==# 'spell'
			src_items = matches.items
		elseif source_name ==# 'mail'
			src_items = FilterSpell(matches.items)
		elseif source_name =~# '^asyncomplete_lsp_' # LSP は server ごとで異なる
			priority = 6
			src_items = matchfuzzy(matches.items, base, {key: 'word'} )
		else
			src_items = filter(matches.items, (key, val) => val.word =~# '^' .. escape(base, '\.$*~'))
		endif
		for item in src_items
			item.priority = priority
			add(items, item)
		endfor
	endfor
	items = sort(items, (x, y) => y.priority - x.priority)
	asyncomplete#preprocess_complete(options, items)
	return
enddef
