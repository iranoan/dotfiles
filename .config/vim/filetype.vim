vim9script
scriptencoding utf-8
# ファイル名によって filetype 指定
if exists('did_load_filetypes')
	finish
endif
var did_load_filetypes = 1

augroup user_filetypedetect
	autocmd!
	autocmd BufNewFile,BufRead *.plt          setfiletype gnuplot # *.plt は mimetypeが設定されていないことも有り得る
	autocmd BufNewFile,BufRead .bash_history,.bashrc,~/dotfiles/.config/bash/*,~/.config/bash/* setfiletype bash
	autocmd BufNewFile,BufRead .xprofile      setfiletype sh
	autocmd BufNewFile,BufRead .textlintrc,.stylelintrc,.htmlhintrc setfiletype json
	autocmd BufNewFile,BufRead .msmtprc       setfiletype msmtp
	autocmd BufNewFile,BufRead tags-??        setfiletype tags
	autocmd BufNewFile,BufRead .uim           setfiletype scheme
	autocmd BufNewFile,BufRead .fdignore,*/.config/fd/ignore setfiletype gitignore
	# autocmd BufNewFile,BufRead *.htm,*.html   setlocal filetype=html
	autocmd BufEnter           */textern/textern-*/*.txt setfiletype mail
	autocmd BufWinEnter        *.jax          setfiletype help
	autocmd BufNewFile,BufRead ~/Hidemaru/Macro/{**/,}*.mac setfiletype hidemaru
augroup END
