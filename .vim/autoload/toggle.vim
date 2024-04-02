vim9script
# 設定を ON/OFF トグルの関数群
scriptencoding utf-8

var breakat: string = &breakat == '' ? ' ^I!@*-+;:,./?' : &breakat

def GuiOptionM(): void
	if &guioptions =~# 'M'
		silent set guioptions-=M
		if exists('g:did_install_default_menus')
			unlet g:did_install_default_menus
		endif
		if exists('g:did_install_syntax_menu')
			unlet g:did_install_syntax_menu
		endif
		execute 'source ' .. resolve(globpath(&runtimepath, 'menu.vim', 1, 1)[0])
	endif
enddef

export def Menu()
	call GuiOptionM()
	if &guioptions =~# 'm'
		set guioptions-=m
	else
		set guioptions+=m
	endif
enddef

export def Toolbar()
	call GuiOptionM()
	if &guioptions =~# 'T'
		set guioptions-=T
	else
		set guioptions+=T
	endif
enddef
