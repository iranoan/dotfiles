scriptencoding utf-8
"カーソル行に書かれたフォルダや関連付けられたアプリケーションで開く (URL またはフォルダは最後が/、ファイルは拡張子があること)

if exists('g:open_uri')
	finish
endif
let g:open_uri = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

"↓ダブル・クリックと <leader>x に割り当て
nnoremap <silent><Leader>x :call open_uri#main()<CR>
nnoremap <2-LeftMouse> :call open_uri#main()<CR>

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
