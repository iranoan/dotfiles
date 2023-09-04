scriptencoding utf-8

function set_gitgutter#main() abort
	let g:gitgutter_preview_win_floating = 1    " GitGutterPreviewHunk 表示はポップアップ
	let g:gitgutter_map_keys = 0                " デフォルト・マッピング OFF
	let g:gitgutter_close_preview_on_escape = 1 " <ESC> で閉じる
	" let g:gitgutter_sign_added = '+'
	let g:gitgutter_sign_modified = '/'
	let g:gitgutter_sign_removed = '-'
	" let g:gitgutter_sign_removed_first_line = '-<'
	" let g:gitgutter_sign_removed_above_and_below = '->'
	let g:gitgutter_sign_modified_removed   = '/-'
	nmap <leader>gp <Plug>(GitGutterPreviewHunk)
	nmap <leader>gs <Plug>(GitGutterStageHunk)
	nmap <leader>gu <Plug>(GitGutterUndoHunk)
	nmap [g <Plug>(GitGutterPrevHunk)
	nmap ]g <Plug>(GitGutterNextHunk)
	" GitGutter* コマンドが定義され、vim-fugitive の Git コマンドが未定義ではなく、曖昧扱いになるので、コマンドのみ定義しておく
	command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#Complete Git exe fugitive#Command(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>)
	" ↑vim9script で定義されると「E1126: Vim9 スクリプトでは :let は使用できません」のエラーが出る (autocmd FuncUndefined fugitive#* → packadd vim-fugitve でファイルが読み込まれ、それによってコマンドが再定義されるので問題なく動作はする)
	" → :help E1231
endfunction
