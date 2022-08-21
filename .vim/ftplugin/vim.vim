"VIM スクリプト用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

"--------------------------------
"ファイルタイプ別のグローバル設定
"--------------------------------
if !exists('g:vim_plugin')
	let g:vim_plugin = 1
	"--------------------------------
	augroup myVIM
		autocmd!
		autocmd CursorMoved,InsertLeave * call <SID>get_comment_string()
		 " 通常はローカル設定で良いが、vim スクリプト内で ruby/python スクリプトが有ると変わる可能性のあるものも含める
		autocmd FileType vim setlocal keywordprg=:help
					\ tabstop=2 softtabstop=2 noexpandtab shiftwidth=2
					\ colorcolumn=""
					\ iskeyword+=?,:
	augroup END

	def s:get_comment_string(): void # vim9script/def/function によって適切な commentstring 返す
		# function ... | ... | endfunction の様に | で連結した関数が有るとうまく判定できない
		# function ...  endfunction / def ...  enddef と対応していなくとも OK としている
		if &filetype !=# 'vim'
			return
		endif
		var defs = filter(getline(1, '.'), 'v:val =~# ''^\s*\(\(end\)\?def\|endf\%[unction]\|fu\%[nction]\)\>''')
		call map(defs, 'substitute(v:val, ''\v^\s*(enddef|def|endf|fu).*'', ''\1'', ''g'')')
		if len(defs) == 0
			&commentstring = getline(1) =~# '^\s*vim9script\>' ? '#%s' : '"%s'
			return
		endif
		var f_kind0 = substitute(getline('.'), '\v^\s*(enddef|def|endf|fu).*', '\1', 'g')
		if f_kind0 ==# 'fu' || f_kind0 ==# 'def'
			remove(defs, -1)
		endif
		var i = len(defs) - 1
		var f_kind1: string
		while i >= 1
			f_kind0 = defs[i]
			f_kind1 = defs[i - 1]
			if (f_kind0 ==# 'endf' || f_kind0 ==# 'enddef') && (f_kind1 ==# 'fu' || f_kind1 ==# 'def')
				i -= 2
			else
				break
			endif
		endwhile
		if i < 0
			&commentstring = getline(1) =~# '^\s*vim9script\>' ? '#%s' : '"%s'
			return
		else
			f_kind0 = defs[i]
			if f_kind0 ==# 'fu'
				&commentstring = '"%s'
				return
			elseif f_kind0 ==# 'def'
				&commentstring = '#%s'
				return
			else # endf%[unction] || enddef
				&commentstring = getline(1) =~# '^\s*vim9script\>' ? '#%s' : '"%s'
				return
			endif
		endif
	enddef
endif

"--------------------------------
"ファイルタイプ別のローカル設定
"--------------------------------
setlocal textwidth=0 "自動改行させない
setlocal keywordprg=:help
setlocal iskeyword+=?,: " is?, isnot? の syntax highlight を効かせるため
call <SID>get_comment_string()
