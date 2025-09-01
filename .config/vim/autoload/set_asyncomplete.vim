scriptencoding utf-8
scriptversion 4

function set_asyncomplete#main() abort
	" packadd asyncomplete.vim " start に置かないと、最初のバッファの最初の入力で補完が効かない
	" let g:asyncomplete_auto_completeopt = 1 " ←デフォルト
	" call asyncomplete#force_refresh()
	" let g:asyncomplete_min_chars = 1
	let g:asyncomplete_auto_completeopt = 0
	" 以下 plugin {{{
	" また 'allowlist': ['*'] を使うと、直ぐ消えてしまうケースが出てくる←vim のコメントで再現
	" snippet https://github.com/hrsh7th/vim-vsnip {{{
		packadd vim-vsnip
		if !exists('g:vsnip_filetypes')
			let g:vsnip_filetypes = {}
		endif
		let g:vsnip_filetypes.xhtml = ['html']
		let g:vsnip_snippet_dir = resolve($MYVIMDIR .. 'vsnip')
		" vim-vsnip/plugin/vsnip.vim s:expand_or_jump() を置き換え←補完後挿入モードにならないケースが有る
		" asyncomplete.vim で snippet と LSP の連携 https://github.com/hrsh7th/vim-vsnip-integ {{{
			packadd vim-vsnip-integ
			call vsnip_integ#integration#attach()
			call asyncomplete#register_source(extend(asyncomplete#get_source_info('vsnip'), #{priority: 80}))
		" }}}
		" snippet のファイル https://github.com/rafamadriz/friendly-snippets {{{
			packadd friendly-snippets
		" }}}
		" キーマップ {{{
			" <C-j> はポップアップ候補の移動に使っている
			" inoremap <expr><C-j>   vsnip#expandable() ? '<Plug>(vsnip-expand)'         : <C-G>u'<C-j>'
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
	" omni https://github.com/yami-beta/asyncomplete-omni.vim {{{
	packadd asyncomplete-omni.vim
	call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options(#{
				\ name: 'omni',
				\ filter: function('FilterOmni'),
				\ priority: 60,
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
				\ filter: function('FilterFile'),
				\ priority: 50,
				\ allowlist: ['*'],
				\ blocklist: ['notmuch-draft'],
				\ completor: function('asyncomplete#sources#file#completor')
				\ }))
			" }}}
	" buffer https://github.com/prabirshrestha/asyncomplete-buffer.vim {{{
	packadd asyncomplete-buffer.vim
	call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options(#{
				\ name: 'buffer',
				\ priority: 30,
				\ allowlist: ['*'],
				\ blocklist: ['c', 'cpp', 'python', 'vim', 'ruby', 'yaml', 'markdown', 'css', 'tex', 'sh', 'go','notmuch-draft'],
				\ completor: function('asyncomplete#sources#buffer#completor'),
				\ config: #{
				\ 	max_buffer_size: 500000
				\ }
				\ }))
				" とりあえず LSP がある filetype は blocklist にしている
	" }}}
	" mail $MYVIMDIR/pack/my-plug/opt/asyncomplete-mail/ {{{
	packadd asyncomplete-mail
	call asyncomplete#register_source(asyncomplete#sources#mail#get_source_options(#{
				\ filter: function('FilterMail'),
				\ priority: 100,
				\ allowlist: ['notmuch-draft']
				\ }))
	" }}}
	" spell $MYVIMDIR/pack/my-plug/opt/asyncomplete-spell/ {{{
	packadd asyncomplete-spell
	call asyncomplete#register_source(asyncomplete#sources#spell#get_source_options(#{
				\ priority: 20,
				\ allowlist: ['*']
				\ }))
	" }}}
	" html $MYVIMDIR/pack/my-plug/opt/asyncomplete-html {{{
	packadd asyncomplete-html
	call asyncomplete#register_source(asyncomplete#sources#html_id#GetSourceOptions(#{
				\ filter: function('FilterFile'),
				\ priority: 100
				\ }))
	" }}}
	" }}}
	let g:asyncomplete_preprocessor = [function('s:asyncomplete_preprocessor')]
	" call asyncomplete#enable_for_buffer() " asyncomplete.vim 自体の遅延読み込みを試みたがだめだった
	" let f = glob('$MYVIMDIR/pack/*/*/asyncomplete.vim/autoload/asyncomplete.vim')
	" 			\ ->resolve()
	" 			\ ->substitute('^' .. escape(expand('$HOME'), '/\.'), '~', 'g') " $HOME を ~ に置換
	" let f = execute('filter /\m^\s*\d\+:\s\+' .. escape(f, '/\~.') .. '$/ scriptnames', 'silent!')
	" 			\ ->substitute('[\n\r]', '', 'g')
	" 			\ ->substitute('^\s*\(\d\+\):.\+', '\1', 'g')
	" call call('<SNR>' .. f .. '_' .. 'on_insert_enter', [])
	call timer_start(1, {->execute('delfunction set_asyncomplete#main')})
endfunction

def s:asyncomplete_preprocessor(options: dict<any>, a_matches: dict<dict<any>>): void
	# sort by matchfuzzypos score+priority
	# source によって補完開始位置が違う場合、補完文字列を調整する
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
	var sources: dict<any>
	var startcol: number
	var priority: number
	var matche_score: list<number>
	for [source_name, matches] in items(a_matches)
		if !matches.items
			continue
		endif
		sources = asyncomplete#get_source_info(source_name)
		startcol = matches.startcol
		startcols += [startcol]
		base = strpart(options.typed, startcol - 1) # ←:help vim9-string-index
		if source_name =~# '^asyncomplete_lsp_' # LSP は server ごとで異なる
			priority = 70
		else
			priority = get(asyncomplete#get_source_info(source_name), 'priority', 50)
		endif
		if has_key(sources, 'filter')
			for m in matches.items
				m.priority = priority
				m.startcol = startcol
				if !base
					m.matche_score = 50
				else
					matche_score = matchfuzzypos([m.word], base)[2]
					if !matche_score
						m.word = ''
						m.matche_score = -100
					else
						m.matche_score = matche_score[0]
					endif
				endif
			endfor
			l_items += sources.filter(matches, startcol, base)
		else
			if empty(base)
				for item in matches.items
					item.priority = priority
					item.startcol = startcol
					item.matche_score = 50
					add(l_items, StripPairCharacters(item))
				endfor
			elseif has_matchfuzzypos && g:asyncomplete_matchfuzzy
				for m in [matchfuzzypos(matches.items, base, {key: 'word'})]
					if !m[0]
						continue
					endif
					for item in m[0]
						item.priority = priority
						item.startcol = startcol
						item.matche_score = m[2][0]
						add(l_items, StripPairCharacters(item))
					endfor
				endfor
			else
				for item in matches.items
					if stridx(item.word, base) == 0
						item.priority = priority
						item.startcol = startcol
						item.matche_score = 50
						add(l_items, StripPairCharacters(item))
					endif
				endfor
			endif
		endif
	endfor
	sort(startcols)->uniq()
	sort(l_items, (x, y) => (y.priority + y.matche_score) - (x.priority + x.matche_score))
	options.startcol = min(startcols)
	if len(startcols) > 1 # source によって補完開始位置が違う
		map(l_items, (_, v) => ({
			word: options.startcol == v.startcol ? v.word : strpart(options.typed, options.startcol - 1, v.startcol - 2) .. v.word, # ←:help vim9-string-index
			abbr: get(v, 'abbr', v.word),
			menu: get(v, 'menu', ''),
			info: get(v, 'info', ''),
			kind: get(v, 'kind', ''),
			icase: get(v, 'icase', 0),
			equal: get(v, 'equal', 0),
			dup: get(v, 'dup', 0),
			empty: get(v, 'empty', 0),
			user_data: get(v, 'user_data', '')
		}))
	endif
	asyncomplete#preprocess_complete(options, l_items)
enddef

def FilterMail(org: dict<any>, col: number, base: string): list<dict<any>>
	var matches_org: list<dict<any>> = org.items
	var matches: list<dict<any>>

	for m in matches_org # Fcc のみ fuzzy match を使わない
		if m.menu !=# '[Fcc]'
			add(matches, m)
		else
			if base !~# '^\s*$' && m.word =~? '^' .. base
				add(matches, m)
			endif
		endif
	endfor
	return matches
enddef

def FilterOmni(org: dict<any>, col: number, base: string): list<dict<any>>
	var matches: list<dict<any>> = org.items

	# 候補候補とカーソル前の文字が同じ引用符もしくは#なら候補前の引用符/#を取り除く
	# 候補最後とカーソル次の文字が同じ引用符なら候補最後の引用符を取り除く
	var c_beg: string = getline('.')[col('.') - len(base) - 2]
	var c_end: string = getline('.')[col('.') - 1]
	var quot_beg: bool = c_beg ==# "'" || c_beg ==# '"' || c_beg ==# '#'
	var quot_end: bool = c_end ==# "'" || c_end ==# '"'

	for m in matches
		quot_beg = quot_beg && ( m.word[0] ==# c_beg )
		quot_end = quot_end && ( m.word[len(m.word) - 1] ==# c_end )
		if quot_beg
			if quot_end
				m.word = m.word[1 : -2]
			else
				m.word = m.word[1 : ]
			endif
		elseif quot_end
			m.word = m.word[0 : -2]
		endif
	endfor
	return matches
enddef

def FilterFile(org: dict<any>, col: number, base: string): list<dict<any>>
	var matches: list<dict<any>> = org.items

	if !matches
		return []
	endif
	for m in matches
		m.word = simplify(m.word)
	endfor
	return matches
enddef
