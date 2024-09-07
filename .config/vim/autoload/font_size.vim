vim9script
scriptencoding utf-8
# フォント・サイズを増減

export def UpDown(size: number): void # size: 増減させる数値
	# var columns: number = &columns
	# var lines: number = &lines
	execute 'set guifont=' .. substitute(&guifont, '\(\d\+\ze,\|\d\+$\)', '\=(str2nr(submatch(0)) + size)', 'g' )
		->substitute(' ', '\\ ', 'g')
enddef
