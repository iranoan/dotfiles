vim9script
scriptencoding utf-8
# HTML 用の設定
if exists('b:did_ftplugin_user')
		|| &filetype ==# 'markdown' # デフォルトで markdown でも読み込まれるのを阻止
	finish
endif
b:did_ftplugin_user = 1

# ファイルタイプ別のグローバル設定 {{{1
if !exists('g:html_syntax_folding') # ↓設定済みか? に流用
	g:html_syntax_folding = 1 # :help html-folding
	# :help html-indent
	g:html_indent_script1 = 'auto'
	g:html_indent_style1 = 'auto'
	packadd surroundTag
endif
# }}}1

# ファイルタイプ別ローカル設定 {{{1
setlocal foldmethod=syntax
setlocal spelloptions=camel
setlocal omnifunc=htmlcomplete#CompleteTags
setlocal iskeyword=a-z,A-Z,48-57,_,- # class, id 名に - が使える。タグの補完では <, > を加えたほうが都合が良いが、加えると = による整形で上手くインデントできなくなる
setlocal makeprg=html-check.sh\ \"%\"
setlocal errorformat=%f:%l:%c:\ %trror:\ %m,%f:%l:%c:\ info\ %tarning:\ %m,%f:%l:%c:\ %tnfo\ warning:\ %m,%f:%l:%c:\ %m,%f:%l:%m
setlocal formatlistpat=^\\s*<\\(li\\\|dt\\\|dd\\)\\(>\\\|\\s\\+\\ze[^>]\\+\\)
setlocal breakindentopt=list:4
# ファイルタイプ別 map {{{
# <S,C-Enter>, <S,C-Space> の組み合わせは GUI のみ有効
nnoremap <silent><buffer><Leader>v :update<Bar>silent !firefox %<CR>
inoremap <expr><buffer><C-Enter>   (getline('.') =~# '^\s*$' ?  '' : '<CR>') .. '<End><p></p><Left><Left><Left><Left><C-G>u'
inoremap <buffer> </               <Cmd>call ftplugin#html#CloseTag()<CR>
# ↑オムニ補完を利用して閉じタグ自動補完
inoremap <buffer><!                <!DOCTYPE html>
inoremap <expr><buffer>**          &filetype ==# 'html' ? '&times;' : '&#215;'
inoremap <expr><buffer><S-Enter>   pumvisible#Insert('<li></li><Left><Left><Left><Left><Left><C-G>u')
inoremap <expr><buffer><S-C-Enter> pumvisible#Insert_after(&filetype ==# 'html' ? '<br>' : '<br />') .. '<C-G>u'
inoremap <buffer><<                &lt;
inoremap <buffer>>>                &gt;
inoremap <buffer>&&                &amp;
inoremap <expr><buffer><C-Space>   pumvisible() ? asyncomplete#close_popup() : (&filetype ==# 'html' ? '&nbsp;' : '&#160;')
inoremap <expr><buffer><=          &filetype ==# 'html' ? '&le;'     : '&#8804;'
inoremap <expr><buffer>>=          &filetype ==# 'html' ? '&ge;'     : '&#8805;'
inoremap <expr><buffer>&<space>    &filetype ==# 'html' ? '&ndash;'  : '&#8211;'
inoremap <expr><buffer>--          &filetype ==# 'html' ? '‐'       : '&#8212;'
inoremap <expr><buffer>---         &filetype ==# 'html' ? '―'       : '&#165;'
inoremap <expr><buffer>\\          &filetype ==# 'html' ? '&yen;'    : '&#177;'
inoremap <expr><buffer>+-          &filetype ==# 'html' ? '&plusmn;' : '&#215;'
inoremap <expr><buffer>==          &filetype ==# 'html' ? '&equiv;'  : '&#8801;'
nnoremap <buffer>gf                <Cmd>call ftplugin#html#GF()<CR>
# }}}
# }}}1

# $MYVIMDIR/pack/ のファイルタイプ別ローカル設定 {{{1
nnoremap <silent><buffer><leader>tt <Cmd>SurroundTag <span\ class="tcy"><CR>
xnoremap <silent><buffer><leader>tt <Cmd>SurroundTag <span\ class="tcy"><CR>
nnoremap <silent><buffer><leader>tr <Cmd>SurroundTag <ruby> <rp>(</rp><rt></rt><rp>)</rp><CR>
xnoremap <silent><buffer><leader>tr <Cmd>SurroundTag <ruby> <rp>(</rp><rt></rt><rp>)</rp><CR>
