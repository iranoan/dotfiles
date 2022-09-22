scriptencoding utf-8
scriptversion 4

function set_vimlsp#main() abort
	packadd vim-lsp
	let g:lsp_diagnostics_enabled = 1
	" let g:lsp_diagnostics_float_cursor = 1 " エラー内容をフローティング表示 (g:lsp_diagnostics_enabled も ON にしないと動作しない)
	let g:lsp_diagnostics_float_delay = 200 " 表示の待ち時間
	let g:lsp_diagnostics_signs_enabled = 1
	let l:icon_dir = split(&runtimepath, ',')[0] .. '/icons/'
	let l:icon_ext = has('win32') ? '.ico' : '.png'
	let g:lsp_diagnostics_signs_error       = {'text': '😰', 'icon': l:icon_dir .. 'error' .. l:icon_ext}
	let g:lsp_diagnostics_signs_warning     = {'text': '🤔', 'icon': l:icon_dir .. 'warning' .. l:icon_ext}
	let g:lsp_diagnostics_signs_hint        = {'text': '💡', 'icon': l:icon_dir .. 'hint' .. l:icon_ext}
	let g:lsp_diagnostics_signs_information = {'text': '📔', 'icon': l:icon_dir .. 'information' .. l:icon_ext}
	let g:lsp_fold_enabled = 0
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
	" }}}
	" LSP との連携 https://github.com/prabirshrestha/asyncomplete-lsp.vim {{{
	if !is_plugin_installed#main('asyncomplete-omni.vim') " asyncomplete.vim のプラグインの一つ asyncomplete-omni.vim が導入済みかどうかで、asyncomplete.vim が導入済みかを判断
		call set_asyncomplete#main() " 先に設定しておかないと補完候補に現れない
	endif
	packadd asyncomplete-lsp.vim
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
		autocmd WinEnter,FileType c,cpp,python,vim,ruby,yaml,markdown,html,xhtml,tex,css,sh,go,conf if !s:check_run_lsp() | call lsp#activate() | endif
		" packadd を使う場合、これがないと開いた既存のウィンドウにでバッファを額た時に有効にならない
		" autocmd BufWinEnter * call lsp#activate() "
		" ↑コメントとしたのは、すでに開いている filetype だと、新たに fzf HISTORY に開いたバッファで有効にならないため
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
	if &filetype == 'python' || &filetype == 'vim'
		b:ale_enabled = 0
		nmap <buffer>[a        <Plug>(lsp-previous-diagnostic)
		nmap <buffer>]a        <Plug>(lsp-next-diagnostic)
	elseif  &filetype == 'c' || &filetype == 'cpp' || &filetype == 'html' || &filetype == 'xhtml' || &filetype == 'tex'
		b:lsp_diagnostics_enabled = 0
		# clang で行末の;無しで次の行がエラー扱いになる
		# HTML, TeX では文法チェックがない
	endif
	if exists('b:lsp_diagnostics_enabled') && b:lsp_diagnostics_enabled != 0  # get(b, 'lsp_diagnostics_enabled') は他のバッファ変数がないせいか使えなかった
		nmap <leader>p         <Plug>(lsp-document-diagnostics)
	endif
	# CSS などは両方使う
	# }}}
	# {{{ キーマップ
	# outline ジャンプ
	nmap <buffer><Leader>lo  <Plug>(lsp-document-symbol-search)
	# # 名前変更
	# nmap <buffer><leader>R <plug>(lsp-rename)
	# # 参照検索
	# nmap <buffer><leader>n <plug>(lsp-references)
	# # テキスト整形
	# nmap <leader>s          <Plug>(lsp-document-format)
	# # Lint結果をQuickFixで表示
	nmap <buffer><expr>K     &filetype ==# 'vim' ? 'K' : '<Plug>(lsp-hover)'
	nmap <buffer><C-]>       <Plug>(lsp-definition)
	# nmap <buffer>gi        <Plug>(lsp-implementation)
	# nmap <buffer>gt        <Plug>(lsp-type-definition)
	# }}}
enddef

def s:check_run_lsp(): bool # 後から同じウィンドウに開いた時以下の設定がないと、LSP server が起動しない
	call s:on_lsp_buffer_enabled()  # すでに開いているファイルタイプと同じファイルを開いたとき、これがないとキーマップが有効にならない
	# autocmd User lsp_buffer_enabled では不十分
	var i = {}
	var html_server = ''
	var servers_name = lsp#get_server_names()
	for s in servers_name
		i = lsp#get_server_info(s)
		if index(i.allowlist, &filetype) != -1
			if lsp#get_server_status(i.name) ==? 'running'
				return true
			endif
			if &filetype ==? 'css' # HTML の style 属性では一度 HTML の LSP を止めないとうまく働いてくれない
				# まだ不完全で、再度 style 属性に入り直さないとうまく動作しない
				var j = {}
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
	return v:true  # 合致する lsp-server が無い
enddef
