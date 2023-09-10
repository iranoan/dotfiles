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
		autocmd FileType fugitive,fugitiveblame,git nnoremap <buffer><nowait><silent>q :bwipeout<CR>
	augroup END
endfunction
