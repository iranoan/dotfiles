vim9script
# Vim help 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif

b:did_ftplugin_user = 1

# ファイルタイプ別のグローバル設定 {{{1
if !exists('g:help_example_languages')
	g:help_example_languages = {vim: 'vim', sh: 'sh', bash: 'sh', python: 'python'}
	# augroup FileTypeHELP
	# 	autocmd!
	# 	autocmd BufWinEnter * setlocal foldlevel=99
	# augroup END
endif

# ファイルタイプ別ローカル設定 {{{1
setlocal foldmethod=expr foldexpr=help#fold#Level() foldtext=help#fold#Text()
setlocal makeprg=textlint\ --format\ compact\ \"%\"
setlocal errorformat=%f:\ line\ %l\\,\ col\ %c\\,\ %trror\ -\ %m
# ~/.config/vim/pack/my-plug/opt/notmuch-py-vim/doc/notmuch-python.jax: line 41, col 15, Error - 一文に二回以上利用されている助詞 "が" がみつかりました。 (japanese/no-doubled-joshi)
setlocal keywordprg=:help
setlocal commentstring=%s
# ↑コメント書式がない
# キーマップ
nnoremap <buffer><nowait><expr><silent>q  &modifiable ? 'q' : ':bwipeout!<CR>'
nnoremap <buffer><expr>o          &readonly ? "\<C-]>" : 'o'
nnoremap <buffer><expr>i          &readonly ? "\<C-]>" : 'i'
nnoremap <buffer><expr>p          &readonly ? "\<C-o>" : 'p'
# タグに移動
nnoremap <buffer><tab>            <Cmd>call search('\|\zs.\{-}\|', 'w')<CR>:nohlsearch<CR>
nnoremap <buffer><S-tab>          <Cmd>call search('\|\zs.\{-}\|', 'wb')<CR>:nohlsearch<CR>
nnoremap <buffer><CR>             <C-]>
