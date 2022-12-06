vim9script
scriptencoding utf-8

# if exists('b:did_ftplugin_user')
# 	finish
# endif
# var b:did_ftplugin_user = 1

#--------------------------------
#ファイルタイプ別のグローバル設定
#--------------------------------
if !exists("g:mail_draft_plugin")
	g:mail_draft_plugin = 1
	def ReformMail(): void
		var msg = readfile(fnameescape(systemlist('notmuch search --output=files id:' .. b:notmuch.msg_id)[0]))
		var from: string
		var i = match(msg, '^From:\c')
		while true
			from ..= msg[i]
			i += 1
			if match(msg[i], '^\s') == -1
				break
			endif
		endwhile
		from = substitute(from, '^From:\s*', '', 'g')->substitute('.\+\s*<\([^>]*\)>', '\1', 'g')
		var pos = getpos('.')
		if from ==? 'nikkei-news@mx.nikkei.com'
			setpos('.', [0, 1, 1, 0])
			:silent execute ':/^$/+10delete | :$-27,$-15delete'
		else
			return
		endif
		setpos('.', pos)
	enddef
endif
#--------------------------------
#ファイルタイプ別ローカル設定
#--------------------------------
nnoremap <Leader>r <Cmd>call <SID>ReformMail()<CR>
