vim9script
scriptencoding utf-8
# b:undo_ftplugin に使う関数を纏めてある

export def AWK(): void
	if &filetype ==# 'awk'
		return
	endif
	setlocal cindent< autoindent< smartindent< foldmethod< errorformat< makeprg<
enddef

export def Sh(): void
	if &filetype ==# 'sh' || &filetype ==# 'bash'
		return
	endif
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
enddef

export def HTML(): void # XHTML と共用
	if &filetype ==# 'html'
		return
	endif
	iunmap <buffer>&&
	iunmap <buffer>&<space>
	iunmap <buffer>**
	iunmap <buffer>+-
	iunmap <buffer>--
	iunmap <buffer>---
	iunmap <buffer><!
	iunmap <buffer></
	iunmap <buffer><<
	iunmap <buffer><=
	iunmap <buffer><C-Enter>
	iunmap <buffer><C-Space>
	iunmap <buffer><S-C-Enter>
	iunmap <buffer><S-Enter>
	iunmap <buffer>==
	iunmap <buffer>>=
	iunmap <buffer>>>
	iunmap <buffer>\\
	nunmap <buffer><Leader>v
	if hasmapto('<leader>tt', 'n')
		nunmap <buffer><leader>tt
	endif
	if hasmapto('<leader>tt', 'x')
		xunmap <buffer><leader>tt
	endif
	if hasmapto('<leader>tr', 'n')
		nunmap <buffer><leader>tr
	endif
	if hasmapto('<leader>tr ', 'x')
		xunmap <buffer><leader>tr
	endif
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal breakindentopt< errorformat< foldmethod< formatlistpat< iskeyword< makeprg< omnifunc< spelloptions<
enddef

export def Vim(): void
	if &filetype ==# 'vim'
		return
	endif
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal spelloptions< formatoptions< textwidth< iskeyword<
enddef

export def C(): void
	if &filetype ==# 'c'
		return
	endif
	nunmap <buffer><Leader>gcc
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal equalprg< errorformat< foldmethod< makeprg< makeprg< makeprg< matchpairs< path<
enddef

export def CSS(): void
	if &filetype ==# 'css'
		return
	endif
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal equalprg< foldmethod< makeprg< omnifunc< spelloptions<
enddef

export def Gnuplot(): void
	if &filetype ==# 'gnuplot'
		return
	endif
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal commentstring< makeprg< errorformat<
enddef

export def Help(): void
	if &filetype ==# 'help'
		return
	endif
	nunmap <buffer>q
	nunmap <buffer>o
	nunmap <buffer>i
	nunmap <buffer>p
	nunmap <buffer><tab>
	nunmap <buffer><S-tab>
	nunmap <buffer><CR>
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal commentstring< errorformat< foldmethod< keywordprg< makeprg<
enddef

export def JSON(): void
	if &filetype ==# 'json'
		return
	endif
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal errorformat< makeprg< equalprg< commentstring< foldmethod<
enddef

export def Mail(): void
	if &filetype ==# 'mail' || &filetype ==# 'notmuch-draft'
		return
	endif
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal textwidth< expandtab< formatexpr<
enddef

export def Man(): void
	if &filetype ==# 'man'
		return
	endif
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal list< spell< foldmethod< foldenable< foldlevelstart< foldcolumn< keywordprg<
enddef

export def Markdown(): void
	if &filetype ==# 'markdown'
		return
	endif
	if hasmapto('<leader>v', 'n')
			nunmap <silent><buffer><Leader>v
		endif
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal expandtab< tabstop< shiftwidth< softtabstop<
enddef

export def MSMTP(): void
	if &filetype ==# 'msmtp'
		return
	endif
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal commentstring<
enddef

export def Python(): void
	if &filetype ==# 'python'
		return
	endif
	nunmap p
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal equalprg< errorformat< foldexpr< formatprg< spelloptions< tabstop< tabstop< errorformat< foldexpr< iskeyword<
enddef

export def Qf(): void
	if &filetype ==# 'qf'
		return
	endif
	nunmap <buffer>q
	nunmap <buffer><C-O>
	nunmap <buffer><C-I>
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal foldcolumn< statusline<
enddef

export def TeX(): void
	if &filetype ==# 'tex'
		return
	endif
	nunmap <buffer><Leader>v
	iunmap <buffer><S-Enter>
	iunmap <buffer><S-C-Enter>
	iunmap <buffer><C-Enter>
	nunmap <buffer><leader>bb
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal breakindentopt< errorformat< formatlistpat< iskeyword< iskeyword< iskeyword< makeprg< suffixesadd<
enddef
