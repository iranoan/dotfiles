vim9script
scriptencoding utf-8
# Man コマンド使用可能に
# $VIMRC で
# runtime! ftplugin/man.vim
# ! を外すと、$MYVIMDIR/ftplugin/man.vim のみ読み込まれて動作しない←https://github.com/vim-jp/issues/issues/1378#issuecomment-918812314
# ! を付けると、最初の起動時にファイルタイプに関係なく $MYVIMDIR/ftplugin/man.vim も読み込まれ、各種変数設定や環境変更が行われ都合が悪い

if exists('g:man_plugin')
	finish
endif
g:man_plugin = 1

var vim_dir0: string = &runtimepath->split(',')[0] # $MYVIMDIR を使うと dotfiles などリンクを使っていると、リンク元になり &runtimepath とは食い違う
var vim_dir: string = vim_dir0 .. '/'
# ユーザごとの $MYVIMDIR/ftplugin/man.vim はファイルタイプ別の設定なので、システムに有る /ftplugin/man.vim を読み込む
for h in split(&runtimepath, ',')
	if match(h, vim_dir) == 0 || h ==# vim_dir0
		continue
	endif
	if getftype(h .. '/ftplugin/man.vim') !=# ''
		execute 'source ' .. h .. '/ftplugin/man.vim'
		# let g:ft_man_open_mode = 'tab'
		augroup myMAN
			autocmd!
			autocmd FileType man nnoremap <buffer><nowait>q <Cmd>bwipeout!<CR>
		augroup END
	endif
endfor
