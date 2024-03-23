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
	" 以下 plugin {{{2
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
	call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options(#{
				\ name: 'omni',
				\ filter: function('FilterOmni'),
				\ priority: 11,
				\ allowlist: ['*'],
				\ blocklist: ['c', 'cpp', 'python', 'vim', 'ruby', 'yaml', 'markdown', 'css', 'tex', 'sh', 'go','notmuch-draft'],
				\ completor: function('asyncomplete#sources#omni#completor'),
				\ config: #{
				\ 	show_source_kind: 1
				\ }
				\ }))
				" \ 'blocklist': ['c', 'cpp', 'python', 'vim', 'ruby', 'yaml', 'markdown', 'html', 'css', 'tex', 'sh', 'go','notmuch-draft'],
				" LSP を優先させたいので、ブロックしているが、HTML も含めると class/id 名の補完や inoremap <buffer> </ </<C-x><C-o> が効かなくなる
	" }}}
	" path https://github.com/prabirshrestha/asyncomplete-file.vim {{{
	packadd asyncomplete-file.vim
	call asyncomplete#register_source(asyncomplete#sources#file#get_source_options(#{
				\ name: 'file',
				\ priority: 5,
				\ allowlist: ['*'],
				\ blocklist: ['notmuch-draft'],
				\ completor: function('asyncomplete#sources#file#completor')
				\ }))
			" }}}
	" buffer https://github.com/prabirshrestha/asyncomplete-buffer.vim {{{
	packadd asyncomplete-buffer.vim
	call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options(#{
				\ name: 'buffer',
				\ priority: 1,
				\ allowlist: ['*'],
				\ blocklist: ['c', 'cpp', 'python', 'vim', 'ruby', 'yaml', 'markdown', 'css', 'tex', 'sh', 'go','notmuch-draft'],
				\ completor: function('asyncomplete#sources#buffer#completor'),
				\ config: #{
				\ 	max_buffer_size: 500000
				\ }
				\ }))
				" とりあえず LSP がある filetype は blocklist にしている
	" }}}
	" mail ~/.vim/pack/my-plug/opt/asyncomplete-mail/ {{{
	packadd asyncomplete-mail
	call asyncomplete#register_source(asyncomplete#sources#mail#get_source_options(#{
				\ filter: function('FilterMail'),
				\ priority: 5,
				\ allowlist: ['notmuch-draft']
				\ }))
	" }}}
	" spell ~/.vim/pack/my-plug/opt/asyncomplete-spell/ {{{
	packadd asyncomplete-spell
	call asyncomplete#register_source(asyncomplete#sources#spell#get_source_options(#{
				\ priority: 4,
				\ allowlist: ['*']
				\ }))
	" }}}
	" ~/.vim/pack/my-plug/opt/asyncomplete-html {{{
	packadd asyncomplete-html
	call asyncomplete#register_source(asyncomplete#sources#html_id#GetSourceOptions(#{priority: 12}))
	call asyncomplete#register_source(asyncomplete#sources#html_url#GetSourceOptions(#{priority: 12}))
	" }}}
	" 2}}}
	let g:asyncomplete_preprocessor = [function('s:asyncomplete_preprocessor')]
endfunction

def s:asyncomplete_preprocessor(a_options: dict<any>, a_matches: dict<dict<any>>): void
	var base: string
	def StripPairCharacters(org: dict<any>): dict<any>
		var item: dict<any> = org
		var lhs: string
		var rhs: string
		var str: string
		if has_key({'"':  '"', '''':  ''''}, base[0])
			[lhs, rhs, str] = [base[0], {'"':  '"', '''':  ''''}[base[0]], item.word]
			if len(str) > 1 && str[0] ==# lhs && str[-1 : ] ==# rhs
				item = extend({}, item)
				item.word = str[ : -2]
			endif
		endif
		return item
	enddef

	var l_items: list<dict<any>>
	var startcols: list<number>
	var has_matchfuzzypos: bool = exists('*matchfuzzypos')
	var options: dict<any> = a_options
	var sources: dict<any>
	var result: list<any>
	var startcol: number
	var priority: number
	for [source_name, matches] in items(a_matches)
		sources = asyncomplete#get_source_info(source_name)
		startcol = matches.startcol
		base = a_options.typed[startcol - 1 : ]
		if source_name =~# '^asyncomplete_lsp_' # LSP は server ごとで異なる
			priority = 6
		else
			priority = get(asyncomplete#get_source_info(source_name), 'priority', 0)
		endif
		if has_key(sources, 'filter')
			result = sources.filter(matches, startcol, base)
			l_items += result[0]
			startcols += result[1]
		else
			if empty(base)
				for item in matches.items
					item.priority = priority
					add(l_items, StripPairCharacters(item))
					startcols += [startcol]
				endfor
			elseif has_matchfuzzypos && g:asyncomplete_matchfuzzy
				for item in matchfuzzypos(matches.items, base, {key: 'word'})[0]
					item.priority = priority
					add(l_items, StripPairCharacters(item))
					startcols += [startcol]
				endfor
			else
				for item in matches.items
					if stridx(item.word, base) == 0
						item.priority = priority
						add(l_items, StripPairCharacters(item))
						startcols += [startcol]
					endif
				endfor
			endif
		endif
	endfor
	l_items = sort(l_items, (x, y) => y.priority - x.priority)
	options.startcol = min(startcols)
	asyncomplete#preprocess_complete(options, l_items)
enddef

def FilterMail(org: dict<any>, col: number, base: string): list<any>
	var matches_org: list<dict<any>> = org.items
	var matches: list<dict<any>>
	var priority: number = get(asyncomplete#get_source_info('mail'), 'priority', 5)

	for m in matches_org
		m.priority = priority
		if m.menu !=# '[Fcc]'
			add(matches, m)
		else
			if base !~# '^\s*$' && m.word =~? '^' .. base
				add(matches, m)
			endif
		endif
	endfor
	return [matches, [col]]
enddef

def FilterOmni(org: dict<any>, col: number, base: string): list<any>
	var matches: list<dict<any>> = org.items
	var priority: number = get(asyncomplete#get_source_info('omni'), 'priority', 5)

	# 候補候補とカーソル前の文字が同じ引用符もしくは#なら候補前の引用符/#を取り除く
	# 候補最後とカーソル次の文字が同じ引用符なら候補最後の引用符を取り除く
	var c_beg: string = getline('.')[col('.') - len(base) - 2]
	var c_end: string = getline('.')[col('.') - 1]
	var quot_beg: bool = c_beg ==# "'" || c_beg ==# '"' || c_beg ==# '#'
	var quot_end: bool = c_end ==# "'" || c_end ==# '"'
	var same_beg: bool
	var same_end: bool

	for m in matches
		m.priority = priority
		same_beg = m.word[0] ==# c_beg
		same_end = m.word[len(m.word) - 1] ==# c_end
		if quot_beg && same_beg
			if quot_end && same_end
				m.word = m.word[1 : -2]
			else
				m.word = m.word[1 : ]
			endif
		elseif quot_end && same_end
			m.word = m.word[0 : -2]
		endif
	endfor
	return [matches, [col]]
enddef
