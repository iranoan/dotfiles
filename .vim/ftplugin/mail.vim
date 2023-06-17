"メール用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

if !exists('g:mail_plugin')
	let g:mail_plugin = 1
	augroup myMail
		autocmd!
		"メール作成ではタブ文字は空白 空白文字非表示 自動改行させない
		autocmd BufEnter mutt-*,neomutt-* setlocal expandtab nolist
	augroup END
endif

setlocal foldmethod=syntax commentstring=>%s
