" 独自の filetype ファイル
scriptencoding utf-8
if exists('s:did_load_filetypes')
	finish
endif
let s:did_load_filetypes = 1
let g:sh_fold_enabled = 7
augroup filetypedetect
	autocmd!
	"*.plt は mimetypeが設定されていないことも有り得る
	autocmd BufNewFile,BufRead *.plt          set filetype=gnuplot
	autocmd BufNewFile,BufRead .bash_history,.bashrc,~/dotfiles/.bash/*,~/.bash/* set filetype=bash
	autocmd BufNewFile,BufRead .xprofile      set filetype=sh
	autocmd BufNewFile,BufRead .textlintrc,.stylelintrc set filetype=json
	autocmd BufNewFile,BufRead .msmtprc       set filetype=msmtp | setlocal commentstring=#%s
	autocmd BufNewFile,BufRead tags-??        set filetype=tags
	autocmd BufNewFile,BufRead .uim         set filetype=scheme
	autocmd BufEnter           */textern/textern-*/*.txt setlocal syntax=mail foldmethod=syntax commentstring=>%s
	" autocmd BufNewFile,BufRead *.htm,*.html   setlocal filetype=html
	autocmd BufEnter           *.sw?          bwipeout!             " スワップファイルは閉じる
	autocmd BufEnter           tags           edit ++encoding=utf-8 " tags ファイルは UTF-8 強制←開き直しているが他にもっと良い方法が解らない
augroup END
