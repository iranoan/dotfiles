scriptencoding utf-8

function set_ale#main()
	" let g:ale_set_balloons = 1
	" let g:ale_hover_to_preview=1
	packadd ale
	let g:ale_disable_lsp = 1
	let g:ale_set_balloons = 0                " エラー/警告をバルーン表示しない
	let g:ale_enabled = 0                     " デフォルトでは OFF にして BufWinEnter で ON にする (argdo などで複数のファイルにも使われると遅い)
	let g:ale_sign_error = '😰'
	let g:ale_sign_style_error = '😱'
	let g:ale_sign_warning = '🤔'
	let g:ale_sign_style_warning = '🤨'
	" let g:ale_open_list=1                   " リストを開くがちらつく
	let g:ale_echo_msg_error_str   = '😰'
	let g:ale_echo_msg_info_str    = '📔'
	let g:ale_echo_msg_warning_str = '🤔'
	let g:ale_echo_msg_format = '[%linter%]%severity% %s [%...code...%]'
	let g:ale_virtualtext_cursor = 0          " virtual text をカーソル位置に表示しない
	" let g:ale_sign_column_always=1
	let g:ale_close_preview_on_insert=1
	let g:ale_markdown_markdownlint_options = '-c ~/.config/markdownlint.json'
	" let g:ale_keep_list_window_open=1
	" let g:ale_lint_on_enter = 1              " ファイルを開いたときにlint実行
	" let g:ale_lint_on_save = 1               " ファイルを保存したときにlint実行
	" let g:ale_lint_on_text_changed = 'never' " 編集中のlintはしない
	" " lint結果をロケーションリストとQuickFixには表示しない
	" " 出てると結構うざいしQuickFixを書き換えられるのは困る
	" let g:ale_set_loclist = 1
	" let g:ale_set_quickfix = 0
	" let g:ale_open_list = 0
	" let g:ale_keep_list_window_open = 0
	" 他の Linter のオプションが増えないように限定しておく
	let g:ale_linters = #{
				\ python: ['flake8'],
				\ c:      ['clang'],
				\ cpp:    ['clang'],
				\ h:      ['clangd', 'clang', 'g++'],
				\ css:    ['css-validator', 'stylelint-v16'],
				\ html:   ['nu-html-checker'],
				\ tex:    ['lacheck', 'chktex'],
				\ json:   ['jsonlint'],
				\ }
				" \ tex   : ['textlint'],
				" \ cpp   : ['clangd', 'clang', 'g++'], " ←clang 以外は行末の;無しで次の行がエラー扱いになる
				" \ tex   : ['lacheck', 'alex', 'chktex', 'proselint', 'redpen', 'texlab', 'vale', 'writegood'],
				" , 'proselint' はプログラムの文法チェッカーではなく、英語のチェッカー (日本語の textlint にあたる)→ https://githubja.com/amperser/proselint もたつく要因かもしれないので、一旦除外
	" 各ツールをFixerとして登録
	let g:ale_fixers = #{ python: ['autopep8'], }
	let g:ale_python_flake8_options = '--config=$HOME/.config/flake8'
	let g:ale_linter_aliases = #{
				\ help : 'markdown',
				\ html : ['html', 'javascript', 'css'],
				\ }
				" \ xhtml: 'html',
	" マッピング
	nnoremap <silent>[a        <Plug>(ale_previous)
	nnoremap <silent>]a        <Plug>(ale_next)
	nnoremap <silent><leader>p <Cmd>call set_ale#open_eror_ls()<CR>
	augroup ALE_ON
		autocmd!
		autocmd BufWinEnter * let b:ale_enabled = 1 | ALEEnableBuffer | ALEEnable
	augroup END
endfunction

def set_ale#open_eror_ls(): void
	var org_win = bufwinid(bufnr())
	botright lwindow 5
	win_gotoid(org_win)
enddef
