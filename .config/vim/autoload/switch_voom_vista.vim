vim9script
# Voom に未対応は Vista を使う様に分岐

export def Main(): void
	var voom_support_list: list<string> = glob('$MYVIMDIR' .. '/pack/*/opt/VOoM/autoload/voom/voom_vimplugin*/voom_mode_*.py', true, true)
	var s: number = matchend(voom_support_list[0], '.\+/voom_mode_')
	map(voom_support_list, (_, v) => v[s : -4 ])
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
