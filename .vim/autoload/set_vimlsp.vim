scriptencoding utf-8
scriptversion 4

function set_vimlsp#main() abort
	packadd vim-lsp
	" let g:lsp_diagnostics_enabled = 1      " デフォルト
	let g:lsp_diagnostics_float_cursor = 1 " エラー内容をフローティング表示
	let g:lsp_diagnostics_float_insert_mode_enabled = 0
	let g:lsp_diagnostics_float_delay = 200 " 表示の待ち時間
	" let g:lsp_diagnostics_signs_enabled = 1 " デフォルト
	let g:lsp_diagnostics_echo_cursor = 1
	let g:lsp_diagnostics_echo_delay = 200
	let g:lsp_diagnostics_signs_delay = 200
	let g:lsp_diagnostics_highlights_delay = 200
	let g:lsp_inlay_hints_delay = 200
	let g:lsp_document_highlight_delay = 200
	let g:lsp_semantic_delay = 200
	let g:lsp_diagnostics_virtual_text_enabled = 0 " 行末に表示され邪魔だし、set wrap でキャレットや n の検索ヒットがずれる行がでてくる
	let l:icon_dir = split(&runtimepath, ',')[0] .. '/icons/'
	let l:icon_ext = has('win32') ? '.ico' : '.png'
	let g:lsp_diagnostics_signs_error       = {'text': '😰', 'icon': l:icon_dir .. 'error' .. l:icon_ext}
	let g:lsp_diagnostics_signs_warning     = {'text': '🤔', 'icon': l:icon_dir .. 'warning' .. l:icon_ext}
	let g:lsp_diagnostics_signs_hint        = {'text': '💡', 'icon': l:icon_dir .. 'hint' .. l:icon_ext}
	let g:lsp_diagnostics_signs_information = {'text': '📔', 'icon': l:icon_dir .. 'information' .. l:icon_ext}
	let g:lsp_fold_enabled = 0
	let g:lsp_text_edit_enabled = 1
	" vim-lsp-settings は &filetype == sh に対応しているが &filetype == bash は未対応 {{{
	call lsp#register_server({
				\ 'name': 'bash-language-server',
				\ 'cmd': {server_info->['bash-language-server', 'start']},
				\ 'initialization_options': v:null,
				\ 'allowlist': ['sh', 'bash'],
				\ 'blocklist': [],
				\ 'config': {'refresh_pattern': '\([a-zA-Z0-9_-]\+\|\k\+\)$'}
				\ })
	call lsp#register_server({
				\ 'name': 'vscode-html-language-server',
				\ 'cmd': {server_info->['vscode-html-language-server', '--stdio']},
				\ 'initialization_options': {'embeddedLanguages': {'javascript': v:true, 'css': v:true}},
				\ 'allowlist': ['html', 'xhtml'],
				\ 'blocklist': [],
				\ 'config': {'refresh_pattern': '\(/\|\k\+\)$'},
				\ 'workspace_config': {},
				\ 'semantic_highlight': {},
				\ })
	" call lsp#register_server({
	" 			\ 'name': 'efm-langserver',
	" 			\ 'cmd': {server_info->['efm-langserver', '-c=/home/hiroyuki/.config/efm-langserver/config.yaml']},
	" 			\ 'allowlist': ['json', 'markdown', 'html', 'xhtml', 'css', 'tex'],
	" 			\ }) " 現状 ALE を浸かったほうが反応が速い
	" }}}
	" vim-lsp の自動設定 https://github.com/mattn/vim-lsp-settings {{{
	packadd vim-lsp-settings
	let g:lsp_settings = {
				\ 'pylsp': {
					\ 'workspace_config': {
						\ 'pylsp': {
							\ 'configurationSources': ['flake8']
						\ }
					\ }
				\ },
			\ }
			" vim-vsnip で追加したほうが良い設定例 {{{
				" \ 'gopls': {
				" 	\ 'initialization_options': {
				" 		\ 'usePlaceholders': v:true,
				" 	\ },
				" \ }
	" }}}
	" LSP との連携 https://github.com/prabirshrestha/asyncomplete-lsp.vim {{{
	if !manage_pack#IsInstalled('asyncomplete-omni.vim') " asyncomplete.vim のプラグインの一つ asyncomplete-omni.vim が導入済みかどうかで、asyncomplete.vim が導入済みかを判断
		call set_asyncomplete#main() " 先に設定しておかないと補完候補に現れない
		autocmd! loadasyncomplete
		augroup! loadasyncomplete
		delfunction set_asyncomplete#main
	endif
	packadd asyncomplete-lsp.vim
	call lsp#activate()
	" }}}
	" command! LspDebug let lsp_log_verbose=1 | let lsp_log_file = expand('~/lsp.log')
	augroup set_lsp_install
		autocmd!
		autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
		" fold 方法←今の所 foldmethod=syntax などの独自方法のままのほうが良い
		" autocmd FileType ??? setlocal
		" 			\ foldmethod=expr
		" 			\ foldexpr=lsp#ui#vim#folding#foldexpr()
		" 			\ foldtext=lsp#ui#vim#folding#foldtext()
		" ↓packadd を使う場合、これがないと開いた既存のウィンドウでバッファを開いた時に有効にならない
		autocmd FileType c,cpp,python,vim,ruby,yaml,markdown,html,xhtml,tex,css,sh,bash,go,conf if !s:check_run_lsp() | call lsp#activate() | endif
		autocmd BufAdd *
					\ if count(['c', 'cpp', 'python', 'vim', 'ruby', 'yaml', 'markdown', 'html', 'xhtml', 'tex', 'css', 'sh', 'bash', 'go', 'conf'], &filetype) >=1
					\ | if !s:check_run_lsp()
					\ | 	call lsp#activate()
					\ | endif
					\ | endif
	augroup END
endfunction

def s:on_lsp_buffer_enabled(): void
	if &filetype !=# 'html' && &filetype !=# 'xhtml' && &filetype !=# 'css'
		setlocal omnifunc=lsp#complete
	endif
	if exists('+tagfunc')
		setlocal tagfunc=lsp#tagfunc
	endif
	# ALE を優先させるか両方使うか {{{
	if &filetype == 'vim' || &filetype == 'sh' || &filetype == 'bash'
		b:ale_enabled = 0 # ALE 不使用
		nnoremap <buffer>[a        <Plug>(lsp-previous-diagnostic)
		nnoremap <buffer>]a        <Plug>(lsp-next-diagnostic)
		nnoremap <buffer><leader>p <Plug>(lsp-document-diagnostics)
	elseif &filetype == 'css' || &filetype == 'c' || &filetype == 'cpp' || &filetype == 'html' || &filetype == 'xhtml' || &filetype == 'tex'
	# elseif &filetype == 'css' || &filetype == 'c' || &filetype == 'cpp' || &filetype == 'tex'
		b:lsp_diagnostics_enabled = 0
		# clang 以外で行末の;無しで次の行がエラー扱いになる
		# TeX では lacheck, CSS では css-validator が efm-languserver を介しても動かない
	else # 結果的に b:lsp_diagnostics_enabled != 0 はエラー/警告リスト ALE 優先に
		nnoremap <buffer><leader>p <Plug>(lsp-document-diagnostics)
	endif
	# 指定がなければ両方使う
	# }}}
	# {{{ キーマップ
	# outline ジャンプ
	nnoremap <buffer><Leader>lo  <Plug>(lsp-document-symbol-search)
	# # 名前変更
	# nnoremap <buffer><leader>R <plug>(lsp-rename)
	# # 参照検索
	# nnoremap <buffer><leader>n <plug>(lsp-references)
	# # テキスト整形
	# nnoremap <leader>s          <Plug>(lsp-document-format)
	# # Lint結果をQuickFixで表示
	nnoremap <buffer><expr>K     &filetype ==# 'vim' ? 'K' : '<Plug>(lsp-hover)'
	nnoremap <buffer><C-]>       <Plug>(lsp-definition)
	# nnoremap <buffer>gi        <Plug>(lsp-implementation)
	# nnoremap <buffer>gt        <Plug>(lsp-type-definition)
	# }}}
	# 次の条件の時、うまく動かない (running で起動しているのに Diagnostic 系が動作しない) ケースが有るので、一度止めてから再度有効にする
	# * まだ LSP が動作していない
	# * 空のバッファに LSP を使用するファイルを開く
	# 例えば、空のバッファで起動後 :edit ~/.bash_history した時
	var s_info: dict<any>
	for s in lsp#get_server_names()
		s_info = lsp#get_server_info(s)
		if index(s_info.allowlist, &filetype) != -1
			break
		endif
	endfor
	while lsp#get_server_status(s_info.name) !=? 'running' && lsp#get_server_status(s_info.name) !=? 'starting'
		lsp#stop_server(s_info.name)
		break
	endwhile
	lsp#enable()
enddef

def s:check_run_lsp(): bool # 後から同じウィンドウに開いた時以下の設定がないと、LSP server が起動しない
	call s:on_lsp_buffer_enabled()  # すでに開いているファイルタイプと同じファイルを開いたとき、これがないとキーマップが有効にならない
	# autocmd User lsp_buffer_enabled では不十分
	var i: dict<any>
	var servers_name = lsp#get_server_names()
	for s in servers_name
		i = lsp#get_server_info(s)
		if index(i.allowlist, &filetype) != -1
			if lsp#get_server_status(i.name) ==? 'running'
				return true
			endif
			if &filetype ==? 'css' # HTML の style 属性では一度 HTML の LSP を止めないとうまく働いてくれない
				# まだ不完全で、再度 style 属性に入り直さないとうまく動作しない
				var j: dict<any>
				for h in servers_name
					j = lsp#get_server_info(h)
					if index(j.allowlist, 'html') != -1
						lsp#stop_server(j.name)
						return false
					endif
				endfor
			endif
			return false
		endif
		endfor
	return true  # 合致する lsp-server が無い
enddef
