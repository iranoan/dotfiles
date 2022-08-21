scriptencoding utf-8
"カーソル行に書かれたフォルダや関連付けられたアプリケーションで開く (URL またはフォルダは最後が/、ファイルは拡張子があること)

"↓ダブル・クリックと <leader>x に割り当て
nnoremap <silent><Leader>x :call open_uri#main()<CR>
nnoremap <2-LeftMouse> :call open_uri#main()<CR>
