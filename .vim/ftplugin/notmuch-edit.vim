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
	def g:ReformMail(): void
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
		var search = @/
		if from ==? 'nikkei-news@mx.nikkei.com'
			:silent execute ':1 | :/^$/+10delete | :$-27,$-15delete'
		elseif from ==? 'atmarkit_newarrivals@noreply.itmedia.co.jp'
			:silent execute ':1 | :/^==PR-\+$/,/^-\+==/+1delete | :/^＠ITの新着記事をお届けします。\n/,/^--- NewsInsight -- 今日のニュース --\+$/-2delete | :/^━＠ITソーシャルアカウント━━━━━━━━━━━━━━━━━━━━━━━━━$/,/^発行：アイティメディア株式会社$/-2delete'
			setline('.', '-- ')
		elseif from ==? 'e_service@mof.go.jp'
			:silent execute ':1 | :/^当メールマガジンについてのご意見、ご感想はこちらへお願いします。$/,$delete | :%substitute/^　//g | :%substitute/　/ /g'
		else
			return
		endif
		:1 | :/^$/,$Zen2han
		@/ = search
		setpos('.', pos)
	enddef
endif
#--------------------------------
#ファイルタイプ別ローカル設定
#--------------------------------
nnoremap <Leader>r <Cmd>call g:ReformMail()<CR>
