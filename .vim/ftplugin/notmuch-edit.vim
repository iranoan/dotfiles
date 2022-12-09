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
	packadd transform
	def g:ReformMail(): void
		def Nature(): void
			def GetBoundary(): string
				var s: string
				var boundary = ''
				for i in range(1, line('$'))
					s = getline(i)
					if s ==# ''
						break
					elseif s =~? '^Content-Type:'
						if s =~? '\<boundary=["'']'
								boundary = substitute(s, '\<boundary=["'']\([^"'']\+\)["'']', '\1', '')
						endif
						var j = i + 1
						while true
							s = getline(j)
							if boundary ==# '' && s =~? '\<boundary=["'']'
								boundary = substitute(s, '.\+\<boundary=["'']\([^"'']\+\)["'']', '\1', '')
							endif
							:silent execute ':' .. j .. 'delete _'
							if s !~# '^\s1'
								break
							endif
							j += 1
						endwhile
						:silent execute ':' .. i .. 'delete _'
						append(i - 1, ['Content-Type: text/plain; charset="UTF-8"', 'Content-Transfer-Encoding: 8bit'])
						break
					endif
				endfor
				return boundary
			enddef
			:silent execute ':global/^--' .. GetBoundary() .. '$/:.,+3delete _'
			:silent :-1delete | :silent :.,/^$/!base64 -di -w 0 -
			:1 | :silent :/<!DOCTYPE /,/<body>/delete _
			:silent :%substitute/\(<br>\)\+\s*\n\?/\r/g
			:silent global/^━ PR ━━\+$/:-1,/^━━\+$/+1delete _
			:silent global/^■最新科学情報をフォローしよう！　　$/:-1,/^━━\+$/-1delete _
			:silent :/^━━\+\n購読案内：　Nature ダイジェスト　お申し込みはこちら$/,/^===\+$/-1delete _
			:silent :/^配信停止はこちらからお手続きください。$/,$delete _
			:1 | silent :/^$/,$substitute/<a href="https:\/\/[^>]\+>\zehttps:\/\///g
			:1 | silent :/^$/,$substitute/\(?utm_source=Nature_TXT&utm_medium=\d\d\d\d\d\d\d\d&utm_campaign=Newsletter\)\?<\/a>//g
			var rep_dic = {
						\ '&amp;': '&',
						\ '&alpha;': 'α',
						\ '&beta;': 'β',
						\ '&gamma;': 'γ',
						\ '&delta;': 'δ',
						\ '&Alpha;': 'Α',
						\ '&Beta;': 'Β',
						\ '&Gamma;': 'Γ',
						\ '&Delta;': 'Δ',
						\ '&reg;': '®',
						\ '&copy;': '©',
						\ '&ndash;': '‐',
						\ '<sub>1</sub>': '₁',
						\ '<sub>2</sub>': '₂',
						\ '<sub>3</sub>': '₃',
						\ '<sup>1</sup>': '¹',
						\ '<sup>2</sup>': '²',
						\ '<sup>3</sup>': '³',
			}
			:silent :%substitute/\(&\(amp\|\alpha\|beta\|gamma\|delta\|reg\|copy\|ndash\);\|<\(su[bp]\)>[123]<\/\2>\)\c/\=rep_dic[submatch(0)]/ge
		enddef
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
			:silent execute ':1 | :/^＠ITの新着記事をお届けします。$/+1,/^--- NewsInsight -- 今日のニュース --\+$/-2delete | :/^━＠ITソーシャルアカウント━━━━━━━━━━━━━━━━━━━━━━━━━$/,/^発行：アイティメディア株式会社$/-2delete'
			setline('.', '-- ')
		elseif from ==? 'e_service@mof.go.jp'
			:silent execute ':1 | :/^当メールマガジンについてのご意見、ご感想はこちらへお願いします。$/,$delete | :%substitute/^　//g | :%substitute/　/ /g'
		elseif from ==? 'natureasia@e-alert.nature.com'
			Nature()
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
