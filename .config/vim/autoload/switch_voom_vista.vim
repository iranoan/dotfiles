vim9script
# Voom に未対応は Vista を使う様に分岐関数とキーマップ

export def Main(): void
	# 対応しているファイルが存在するか? を使って、次のコマンドでリスト化
	# r!find "$HOME/.vim/pack/github/opt/VOoM/autoload/voom/" -type d | xargs --no-run-if-empty -I{} find "{}" -type f -name "voom_mode_*.py" | sed -r -e 's:.+/voom_mode_:'\'':g' -e 's:\.py:'\'':g' | tr '\n' ','| sed -e 's/,/, /g' -e 's/, $//g'
	var voom_support_list = [
				\ 'asciidoc', 'cwiki', 'dokuwiki', 'fmr', 'fmr1', 'fmr2', 'fmr3', 'hashes', 'html', 'xhtml', 'inverseAtx', 'latex', 'latexDtx', 'markdown', 'org', 'pandoc', 'paragraphBlank', 'paragraphIndent', 'paragraphNoIndent', 'python', 'rest', 'taskpaper', 'thevimoutliner', 'txt2tags', 'viki', 'vimoutliner', 'vimwiki', 'wiki'
				\ ]
	var name: string = bufname()
	if &filetype ==? 'tex'
		execute 'Voom latex'
	elseif &filetype ==? 'text'
		execute 'Voom markdown'
	elseif &filetype ==? 'vim' # Vista というか LSP vim-language-Server は vim9script 未対応 2023/01/17
		execute 'Voom vimoutliner'
	elseif index( ['c', 'h', 'cpp', 'sh', 'python'], &filetype ) >= 0 # taglist, Voom 両方に対応しているファイルタイプも有るので、取り敢えずこれだけを Vista を使う
		execute 'Vista'
		# for w in gettabinfo(tabpagenr())[0]['windows']
		# 	if has_key(getwininfo(w)[0]['variables'], 'vista_first_line_hi_id') # この時点ではウィンドウがまだ開かれていない
		# 		win_execute(w, 'setlocal statusline=%#StatusLineRight#' .. escape(vista#statusline#(), ' '))
		# 	endif
		# endfor
		return
	elseif &filetype ==? 'xhtml'
		execute 'Voom html'
	elseif index( voom_support_list, &filetype ) >= 0
		execute 'Voom ' .. &filetype
	else
		echomsg 'No Support filetype:''' .. &filetype .. ''''
		return
	endif
	execute 'setlocal statusline=%#StatusLineRight#[%{&filetype}]\ ' .. name
enddef
