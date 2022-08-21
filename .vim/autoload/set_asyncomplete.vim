scriptencoding utf-8

function set_asyncomplete#main() abort
	if exists('s:load_asycomplte') " && s:load_asycomplte
		return
	endif
	let s:load_asycomplte = 1
	" packadd asyncomplete.vim ←asyncomplete.vim 自体は ~/.vim/pack/*/start に置かないと最初に読み込んだバッファで働かない
	" let g:asyncomplete_auto_completeopt = 1 " ←デフォルト
	" let g:asyncomplete_min_chars = 1        " 補完完了直後にも表示されて、うまく働かないキーマップが出てくるが、対処法が見つからない
	" " ↑例えば TeX で
	" " inoremap <buffer><S-Enter>       <Enter>\item<Tab>
	" " としているが、補完直後の <S-Enter> では最初の <Enter> が確定の扱いになってしまう
	" 以下 plugin {{{3
	" また 'allowlist': ['*'] を使うと、直ぐ消えてしまうケースが出てくる←vim のコメントで再現
	" " snippet https://github.com/hrsh7th/vim-vsnip {{{
	" packadd vim-vsnip
	" 	" snippet と LSP の連携 https://github.com/hrsh7th/vim-vsnip-integ {{{
	" 	packadd vim-vsnip-integ
	" 	" }}}
	" 	" https://github.com/mattn/vim-lsp-icons {{{
	" 	packadd vim-lsp-icons
	" 	" }}}
	" 	" snippet のファイル https://github.com/rafamadriz/friendly-snippets {{{
	" 	packadd friendly-snippets
	" 	" }}}
	" 	" vim-vsnip で追加したほうが良い設定 {{{
	" 	let g:lsp_settings = {
	" 	\   'gopls': {
	" 	\     'initialization_options': {
	" 	\       'usePlaceholders': v:true,
	" 	\     },
	" 	\   },
	" 	\ }
	" 	" }}}
	" " キーマップ {{{
	" let g:vsnip_snippet_dir = expand('~/.vim/pack/github/opt/friendly-snippets/snippets') " 上で読み込んだファイルを使う
	" let g:vsnip_snippet_dirs = [expand('~/.vim/vsnip')]
	" let g:vsnip_filetypes = {}
	" let g:vsnip_filetypes.sh = ['shell']
	" imap <expr> <C-y> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-y>'
	" smap <expr> <C-y> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-y>'
	" }}}
	" " }}}
	" LSP との連携する asyncomplete-lsp.vim は vim-lsp 側で行う ← InsertEnter のタイミングではうまく動作しない
	call s:set_neosnippet() " ←neosnippet の読み込み・設定↓連携 {{{
	delfunction s:set_neosnippet
		" キーマップ {{{
		imap <expr><C-y> pumvisible() ? asyncomplete#close_popup() : neosnippet#expandable_or_jumpable() ? '<Plug>(neosnippet_expand_or_jump)' : '<C-y>'
		smap <expr><C-y> pumvisible() ? asyncomplete#close_popup() : neosnippet#expandable_or_jumpable() ? '<Plug>(neosnippet_expand_or_jump)' : '<C-y>'
		xmap <expr><C-y> pumvisible() ? asyncomplete#close_popup() : neosnippet#expandable_or_jumpable() ? '<Plug>(neosnippet_expand_or_jump)' : '<C-y>'
		nmap <expr><C-y> pumvisible() ? asyncomplete#close_popup() : neosnippet#expandable_or_jumpable() ? '<Plug>(neosnippet_expand_or_jump)' : '<C-y>'
		vmap <expr><C-y> pumvisible() ? asyncomplete#close_popup() : neosnippet#expandable_or_jumpable() ? '<Plug>(neosnippet_expand_or_jump)' : '"+y'
		" ポップアップ表示中のマップ <C-n>, <C-k> は元々希望の動作
		imap <expr><C-j> pumvisible() ? '\<Down>' : '\<C-j>'
		smap <expr><C-j> pumvisible() ? '\<Down>' : '\<C-j>'
		xmap <expr><C-j> pumvisible() ? '\<Down>' : '\<C-j>'
		nmap <expr><C-j> pumvisible() ? '\<Down>' : '\<C-j>'
		" inoremap <expr><C-p> pumvisible() ? '\<C-p>' : '<C-r>"'
		" ↑ insert moode ペーストに割り当てているので ~/.vim/vimrc 側で行っている
		imap <expr><C-Space> pumvisible() ? asyncomplete#close_popup() : '<C-Space>'
		" imap <expr><Space> pumvisible() ? asyncomplete#close_popup() : '<Space>'
		" }}}
		" LSP と snippet 連携 https://github.com/thomasfaingnaert/vim-lsp-neosnippet {{{
		" https://github.com/thomasfaingnaert/vim-lsp-snippets
		packadd vim-lsp-snippets
		packadd vim-lsp-neosnippet
		" }}}
		" snippet https://github.com/prabirshrestha/asyncomplete-neosnippet.vim {{{
		" vim-lsp-neosnippet だけだと <C-x><C-o> のトリガーをタイプしないと表示されない、もしくは表示まで時間がかかるケースがある
		packadd asyncomplete-neosnippet.vim
		call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options({
					\ 'name': 'neosnippet',
					\ 'allowlist': ['c', 'cpp', 'python', 'vim', 'ruby', 'yaml', 'html', 'css', 'tex', 'sh'],
					\ 'priority': 8,
					\ 'completor': function('asyncomplete#sources#neosnippet#completor'),
					\ }))
		" }}}
	" }}}
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

function s:set_neosnippet() abort
	if is_plugin_installed#main('neosnippet-snippets')
		return
	endif
	" 補完辞書基本 https://github.com/Shougo/neosnippet
	packadd neosnippet
	" 言語別の補完辞書 https://github.com/Shougo/neosnippet-snippets {{{
	packadd neosnippet-snippets
	" }}}
	" ↑IME ON の時は効かない (全角空白のため?)
	" smap <expr><C-p> pumvisible() ? '<Up>' : '<C-p>'
	" xmap <expr><C-p> pumvisible() ? '<Up>' : '<C-p>'
	" nmap <expr><C-p> pumvisible() ? '<Up>' : '"+gp'
	" imap <C-y>     <Plug>(neosnippet_expand_or_jump)
	" smap <C-y>     <Plug>(neosnippet_expand_or_jump)
	" xmap <C-y>     <Plug>(neosnippet_expand_or_jump)
	" nmap <C-y>     <Plug>(neosnippet_expand_or_jump)
	" let g:neosnippet#enable_conceal_marker = 1 " conceal 自体が補完時以外の入力で見難いので使わない
	let g:neosnippet#enable_completed_snippet = 1
	let g:neosnippet#expand_word_boundary = 1    " 補完は単語で←0のままでは記号の後ろで出ない
	let g:neosnippet#disable_select_mode_mappings = 0 " キーマップしない
	let g:neosnippet#enable_complete_done = 1
	" imap <C-b> <Plug>(neosnippet_expand_or_jump)
	" smap <C-b> <Plug>(neosnippet_expand_or_jump)
	" xmap <C-b> <Plug>(neosnippet_expand_target)
	"<BS>: close popup and delete backword char.
	" inoremap <expr><BS> neocomplete#smart_close_popup()
	"Close popup by <Space>.
	"inoremap <expr><Space> pumvisible() ? '<C-y>' : '<Space>'
	"SuperTab like snippets behavior.
	"補完候補のディレクトリ (個人用があるので再設定)
	let g:neosnippet#snippets_directory = '~/.vim/snippet/'
	" if has('conceal')                              "補完で続けての入力を示すマーカーを入力中は非表示←そもそも TeX などで見難くなるので使わない
	" 	setlocal conceallevel=2 concealcursor=niv
	" endif
endfunction
