scriptencoding utf-8

function set_gitgutter#main() abort
	packadd vim-gitgutter
	let g:gitgutter_preview_win_floating = 1 " GitGutterPreviewHunk 表示はポップアップ
	let g:gitgutter_map_keys = 0             " デフォルト・マッピング OFF
	nmap <leader>hp <Plug>(GitGutterPreviewHunk)
	nmap <leader>hs <Plug>(GitGutterStageHunk)
	nmap <leader>hu <Plug>(GitGutterUndoHunk)
	nmap [g <Plug>(GitGutterPrevHunk)
	nmap ]g <Plug>(GitGutterNextHunk)
	" GitGutter* コマンドが定義され、vim-fugitive の Git コマンドが未定義ではなく、曖昧扱いになるので、コマンドのみ定義しておく
	command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#Complete Git exe fugitive#Command(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>)
endfunction
