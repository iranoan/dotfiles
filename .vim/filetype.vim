vim9script
# ファイル名によって filetype 指定
scriptencoding utf-8
if exists('did_load_filetypes')
	finish
endif
var did_load_filetypes = 1

augroup filetypedetect
	autocmd!
	autocmd BufNewFile,BufRead *.plt          set filetype=gnuplot # *.plt は mimetypeが設定されていないことも有り得る
	autocmd BufNewFile,BufRead .bash_history,.bashrc,~/dotfiles/.bash/*,~/.bash/* set filetype=bash
	autocmd BufNewFile,BufRead .xprofile      set filetype=sh
	autocmd BufNewFile,BufRead .textlintrc,.stylelintrc set filetype=json
	autocmd BufNewFile,BufRead .msmtprc       set filetype=msmtp
	autocmd BufNewFile,BufRead tags-??        set filetype=tags
	autocmd BufNewFile,BufRead .uim           set filetype=scheme
	# autocmd BufNewFile,BufRead *.htm,*.html   setlocal filetype=html
	autocmd BufEnter           */textern/textern-*/*.txt set filetype==mail
augroup END
