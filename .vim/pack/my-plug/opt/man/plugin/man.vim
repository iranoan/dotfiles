" Man コマンド使用可能に
" ~/.vim/vimrc で
" runtime! ftplugin/man.vim
" ! を外すと、~/.vim/ftplugin/man.vim のみ読み込まれて動作しない←https://github.com/vim-jp/issues/issues/1378#issuecomment-918812314
" ! を付けると、最初の起動時にファイルタイプに関係なく ~/.vim/ftplugin/man.vim も読み込まれ、各種変数設定や環境変更が行われ都合が悪い

scriptencoding utf-8

function s:executable_man() abort " ユーザごとでなく、システムに有る /ftplugin/man.vim を読み込む
	for l:h in split(&runtimepath, ',')
		if match(l:h, expand('~/.vim')) != -1
			continue
		endif
		if getftype(l:h . '/ftplugin/man.vim') !=# ''
			execute 'source ' . l:h . '/ftplugin/man.vim'
			let g:ft_man_open_mode = 'tab'
		endif
	endfor
endfunction
call s:executable_man()
