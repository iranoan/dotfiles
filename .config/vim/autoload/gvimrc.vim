vim9script
# GUI 環境の設定を ON/OFF トグルとフォント・サイズ変更の関数
scriptencoding utf-8

def GuiOptionM(): void
	if &guioptions =~# 'M'
		silent set guioptions-=M
		if exists('g:did_install_default_menus')
			unlet g:did_install_default_menus
		endif
		if exists('g:did_install_syntax_menu')
			unlet g:did_install_syntax_menu
		endif
		execute 'source' resolve(globpath(&runtimepath, 'menu.vim', 1, 1)[0])
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

export def FontSize(size: number): void # フォント・サイズを増減
	# size: 増減させる数値
	# var columns: number = &columns
	# var lines: number = &lines
	execute 'set guifont=' .. substitute(&guifont, '\(\d\+\ze,\|\d\+$\)', '\=(str2nr(submatch(0)) + size)', 'g' )
		->substitute(' ', '\\ ', 'g')
enddef
