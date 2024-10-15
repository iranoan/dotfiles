scriptencoding utf-8

function set_fugitve#main() abort
	packadd vim-fugitive
	" 既に廃止済みや単なる別名コマンド削除←補完候補として出ると邪魔
	" delcommand Gblame
	delcommand Gbrowse
	" delcommand Gcommit
	delcommand Gdelete
	" delcommand Gfetch
	" delcommand Glog
	delcommand GlLog
	" delcommand Gmerge
	delcommand Gmove
	" delcommand Gpull
	" delcommand Gpush
	" delcommand Grebase
	delcommand Gremove
	delcommand Grename
	" delcommand Grevert
	" delcommand Gstatus
	augroup fugitive_keymap
		autocmd!
		autocmd FileType fugitive,fugitiveblame,git call set_fugitve#filetype()
	augroup END
endfunction

def set_fugitve#undo_ftplugin(): void
	nunmap <buffer><nowait><silent>q
	setlocal foldmethod<
enddef

def set_fugitve#filetype(): void
	nnoremap <buffer><nowait><silent>q :bwipeout<CR>
	if &filetype ==# 'fugitive' || &filetype ==# 'git'
		setlocal foldmethod=syntax
	endif
	if exists('b:undo_ftplugin')
		if b:undo_ftplugin !~#  '\<call set_fugitve#undo_ftplugin()'
			b:undo_ftplugin ..= '| call set_fugitve#undo_ftplugin()'
		endif
	else
		b:undo_ftplugin = 'call set_fugitve#undo_ftplugin()'
	endif
enddef
