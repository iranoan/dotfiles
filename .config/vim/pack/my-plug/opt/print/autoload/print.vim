vim9script
scriptencoding utf-8
# 印刷の設定と印刷用に色の指定
# 特に GUI だと一部のシンタックスの背景が set background=dark のままになるのをごまかす
# VIM - Vi IMproved 9.1 (2024 Jan 02, compiled Nov 16 2024 12:55:23) の時点で、Normal は問題なくなった

export def Main(first: number, last: number): void
	# linewidth=4 で固定されていて変えられない
	var linenr: list<dict<any>> = hlget('LineNr')
	# var widht: number = &columns
	var bg: string = &background
	var termguicolors: bool = &termguicolors

	# setlocal columns=80 background=light
	set background=light
	highlight LineNr guifg=#000000 guibg=#FFFFFF gui=bold cterm=bold ctermfg=black ctermbg=white
	if !has('gui_running')
		set termguicolors
	endif
	execute($':{first},{last}hardcopy')
	call hlset(linenr)
	# execute($'setlocal columns={widht} background={bg}')
	execute($'setlocal background={bg}')
	if !has('gui_running') && !termguicolors
		set notermguicolors
	endif
enddef
