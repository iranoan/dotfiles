"QuickFix 用の設定
scriptencoding utf-8

if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

nnoremap <buffer><silent>q :bwipeout!<CR>
