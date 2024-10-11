vim9script
scriptencoding utf-8
# HTML/XHTML 共通設定
# 一部の参照表記や閉じるタグをつける/省略を変えているため

if !exists('g:did_ftplugin_html')
	def g:CloseTag(): string # completeopt 次第で候補が一つでも確定しない
		var cmpop: string = &completeopt
		var tmpop: string = substitute(cmpop, '\(menuone\|noinsert\|noselect\),', '', 'g')
			->substitute('\(menuone\|noinsert\|noselect\)$', '', 'g')
		var ls: list<string>
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
endif
g:did_ftplugin_html = 1

setlocal makeprg=html-check.sh\ \"%\"
setlocal errorformat=%f:%l:%c:\ %trror:\ %m,%f:%l:%c:\ info\ %tarning:\ %m,%f:%l:%c:\ %tnfo\ warning:\ %m,%f:%l:%c:\ %m,%f:%l:%m
setlocal formatlistpat=^\\s*<\\(li\\\|dt\\\|dd\\)\\(>\\\|\\s\\+\\ze[^>]\\+\\)
setlocal breakindentopt=list:4
#--------------------------------
# オムニ補完関数指定
setlocal omnifunc=htmlcomplete#CompleteTags
#--------------------------------
#ファイルタイプ別 map
# inoremap <buffer> </ </<C-x><C-o>
inoremap <expr><buffer> </         g:CloseTag()
# ↑オムニ補完を利用して閉じタグ自動補完
nnoremap <silent><buffer><Leader>v :update<Bar>silent !firefox %<CR>
# <S,C-Enter> の組み合わせは GUI のみ有効
inoremap <expr><buffer><C-Enter>   (getline('.') =~# '^\s*$' ?  '' : '<CR>') .. '<End><p></p><Left><Left><Left><Left><C-G>u'
inoremap <buffer><<                &lt;
inoremap <buffer>>>                &gt;
inoremap <buffer>&&                &amp;
inoremap <buffer>--                ‐
inoremap <buffer>---               ―
inoremap <buffer><!                <!DOCTYPE html>
setlocal spelloptions=camel
# 折りたたみ
setlocal foldmethod=syntax

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| setlocal signcolumn< foldcolumn< | call undo_ftplugin#HTML()'
else
	b:undo_ftplugin = 'setlocal signcolumn< foldcolumn< | call undo_ftplugin#HTML()'
endif
