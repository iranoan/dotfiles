vim9script
scriptencoding utf-8
# b:undo_ftplugin に使う関数を纏めてある

export def HTML(): void # XHTML と共用
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
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal breakindentopt< errorformat< foldmethod< formatlistpat< iskeyword< makeprg< omnifunc< spelloptions<
enddef

export def Vim(): void
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal spelloptions< formatoptions< textwidth< iskeyword<
enddef

export def C(): void
	nunmap <buffer><Leader>gcc
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal equalprg< errorformat< foldmethod< makeprg< makeprg< makeprg< matchpairs< path<
enddef

export def CSS(): void
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal equalprg< foldmethod< makeprg< omnifunc< spelloptions<
enddef

export def Gnuplot(): void
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal commentstring< makeprg< errorformat<
enddef

export def Help(): void
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
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal errorformat< makeprg< equalprg< commentstring< foldmethod<
enddef

export def Mail(): void
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal textwidth< expandtab<
enddef

export def Man(): void
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal list< spell< foldmethod< foldenable< foldlevelstart< foldcolumn< keywordprg<
enddef

export def Markdown(): void
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal expandtab< tabstop< shiftwidth< softtabstop<
enddef

export def MSMTP(): void
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal commentstring<
enddef

export def Python(): void
	nunmap p
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal equalprg< errorformat< foldexpr< formatprg< spelloptions< tabstop< tabstop< errorformat< foldexpr< iskeyword<
enddef

export def Qf(): void
	nunmap <buffer>q
	nunmap <buffer><C-O>
	nunmap <buffer><C-I>
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal foldcolumn<
enddef

export def TeX(): void
	nunmap <buffer><Leader>v
	iunmap <buffer><S-Enter>
	iunmap <buffer><S-C-Enter>
	iunmap <buffer><C-Enter>
	nunmap <buffer><leader>bb
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
	setlocal breakindentopt< errorformat< formatlistpat< iskeyword< iskeyword< iskeyword< makeprg< suffixesadd<
enddef
