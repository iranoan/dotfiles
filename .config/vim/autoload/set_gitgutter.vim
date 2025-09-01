scriptencoding utf-8

function set_gitgutter#main() abort
	packadd vim-gitgutter
	let g:gitgutter_preview_win_floating = 1    " GitGutterPreviewHunk 表示はポップアップ
	let g:gitgutter_map_keys = 0                " デフォルト・マッピング OFF
	let g:gitgutter_close_preview_on_escape = 1 " <ESC> で閉じる
	" let g:gitgutter_sign_added = '+'
	let g:gitgutter_sign_modified = '/'
	let g:gitgutter_sign_removed = '-'
	" let g:gitgutter_sign_removed_first_line = '-<'
	" let g:gitgutter_sign_removed_above_and_below = '->'
	let g:gitgutter_sign_modified_removed   = '/-'
	nnoremap <leader>gp <Plug>(GitGutterPreviewHunk)
	nnoremap <leader>gs <Plug>(GitGutterStageHunk)
	nnoremap <leader>gu <Plug>(GitGutterUndoHunk)
	nnoremap [g <Plug>(GitGutterPrevHunk)
	nnoremap ]g <Plug>(GitGutterNextHunk)
	" GitGutter* コマンドが定義され、vim-fugitive の Git コマンドが未定義ではなく、曖昧扱いになるので、コマンドのみ定義しておく
	command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#Complete Git exe fugitive#Command(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>)
	" ↑vim9script で定義されると「E1126: Vim9 スクリプトでは :let は使用できません」のエラーが出る (autocmd FuncUndefined fugitive#* → packadd vim-fugitve でファイルが読み込まれ、それによってコマンドが再定義されるので問題なく動作はする)
	" → :help E1231
	" augroup hook_gitgutter " git の warning を無視するように関数をフックする
	" 	autocmd!
	" 	autocmd FuncUndefined gitgutter#*
	" 				\ call hook_function#main($MYVIMDIR .. 'pack/github/start/vim-gitgutter/autoload/gitgutter/utility.vim', $MYVIMDIR .. 'plugin/hook_gitgutter.vim', 'obtain_file_renames')
	" 				\ | autocmd! hook_gitgutter
	" 				\ | augroup! hook_gitgutter
	" augroup END
	call timer_start(1, {->execute('delfunction set_gitgutter#main')})
endfunction
