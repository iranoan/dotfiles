vim9script
scriptencoding utf-8
# HTML/XHTML 共通設定
# 一部の参照表記や閉じるタグをつける/省略を変えているため

# ファイルタイプ別のグローバル設定 {{{1
if !exists('g:did_ftplugin_htmlxhtml')
	g:did_ftplugin_htmlxhtml = 1
	# augroup myHTMLXHTML
	# 	autocmd!
	# 	autocmd FileType css  setlocal equalprg=stylelint\ --fix\ --stdin\ --no-color\|prettier\ --write\ --parser\ css
	# 	autocmd FileType html setlocal equalprg<
	# augroup END
	def g:CloseTag(): string # completeopt 次第で候補が一つでも確定しない
		var cmpop: string = &completeopt
		var tmpop: string = substitute(cmpop, '\(menuone\|noinsert\|noselect\),', '', 'g')
			->substitute('\(menuone\|noinsert\|noselect\)$', '', 'g')
		# var ls: list<string>
		# ↓上手くいかない
		# set completeopt&vim
		# feedkeys("</\<C-X>\<C-O>", 'n')
		# &completeopt = cmpop
		# ↓も上手くいかない
		# feedkeys("</", 'n')
		# htmlcomplete#CompleteTags(1, '')
		# ls = htmlcomplete#CompleteTags(0, '')
		# if len(ls) == 1
		# 	return ls[0]
		# else
		# 	return "\<C-X>\<C-O>"
		# endif
		feedkeys("\<C-\>\<C-o>:set completeopt=" .. tmpop .. "\<Enter></\<C-X>\<C-O>\<C-\>\<C-o>:set completeopt=" .. cmpop .. "\<Enter>", 'n')
		return ''
	enddef
	# :help html-indent
	g:html_indent_script1 = 'inc'
	g:html_indent_style1 = 'inc'
	g:html_indent_autotags = 'html,body,tbody,dt,dd,li'
	g:html_syntax_folding = 1 # :help html-folding
endif

# ファイルタイプ別のローカル設定 {{{1
setlocal foldmethod=syntax
if &filetype !=# 'markdown'
	setlocal omnifunc=htmlcomplete#CompleteTags
	setlocal iskeyword=a-z,A-Z,48-57,_,- # class, id 名に - が使える。タグの補完では <, > を加えたほうが都合が良いが、加えると = による整形で上手くインデントできなくなる
	#ファイルタイプ別 map {{{
	setlocal makeprg=html-check.sh\ \"%\"
	setlocal errorformat=%f:%l:%c:\ %trror:\ %m,%f:%l:%c:\ info\ %tarning:\ %m,%f:%l:%c:\ %tnfo\ warning:\ %m,%f:%l:%c:\ %m,%f:%l:%m
	setlocal formatlistpat=^\\s*<\\(li\\\|dt\\\|dd\\)\\(>\\\|\\s\\+\\ze[^>]\\+\\)
	setlocal breakindentopt=list:4
	# inoremap <buffer> </ </<C-x><C-o>
	nnoremap <silent><buffer><Leader>v :update<Bar>silent !firefox %<CR>
	# <S,C-Enter> の組み合わせは GUI のみ有効
	inoremap <expr><buffer><C-Enter>   (getline('.') =~# '^\s*$' ?  '' : '<CR>') .. '<End><p></p><Left><Left><Left><Left><C-G>u'
	inoremap <expr><buffer> </         g:CloseTag()
	# ↑オムニ補完を利用して閉じタグ自動補完
	inoremap <buffer><!                <!DOCTYPE html>
	# }}}
endif
#ファイルタイプ別 map {{{
inoremap <buffer><<                &lt;
inoremap <buffer>>>                &gt;
inoremap <buffer>&&                &amp;
setlocal spelloptions=camel
# }}}

# Undo {{{1
if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| call undo_ftplugin#HTML()'
else
	b:undo_ftplugin = 'call undo_ftplugin#HTML()'
endif
