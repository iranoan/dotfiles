" Python 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

" ファイルタイプ別のグローバル設定 {{{1
if !exists('g:py_plugin')
	let g:py_plugin = 1
	" augroup myPython
	" 	autocmd!
	" augroup END
	packadd python-fold
endif

" ファイルタイプ別ローカル設定 {{{1
nnoremap p ]p
"↑p と似ているが、現在行に合わせてインデントが調整される
"--------------------------------
setlocal tabstop=4 softtabstop=4 expandtab shiftwidth=0 colorcolumn=80
" setlocal keywordprg=pydoc3 だと os.path などの選択状態で思った動作をしない←コマンドラインに出てしまう
setlocal errorformat=%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
setlocal spelloptions=camel
"--------------------------------
" setlocal makeprg=python3\ \"%\" " 標準入力からの入力待ちが有る場合いつまで経っても終わらない←素直に QuickRun を使えば良い
" デバッガ {{{2
" nnoremap <silent><buffer><Leader>db :terminal pdb3 "%"<CR><C-w>x
" ひとつ下にターミナルで起動する
setlocal equalprg=autopep8\ -
setlocal formatprg=autopep8\ -
" --max-line-length\ 100 " ~/.config/pep8
setlocal foldexpr=python_fold#Fold() foldmethod=expr
