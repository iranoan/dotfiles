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
	def g:ReformMail(): void # ML の広告を削除する個人的な関数
		def DelBlock(s: string, e: string, i: number, j: number): void # s, e 両方の文字列 (行) が有ったときのみ、その範囲を削除
			var buf = getline(1, '$')
			var start = match(buf, '^$')
			var s_pos = match(buf, '^' .. s .. '$', start) + 1 + i
			if !s_pos
				return
			endif
			var e_pos = match(buf, '^' .. e .. '$', s_pos) + 1 + j
			if !e_pos
				return
			endif
			:silent execute ':' .. s_pos .. ',' .. e_pos .. 'delete _'
			return
		enddef

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
			:1 | :silent :/<!DOCTYPE /;/<p>/delete _
			:silent :%substitute/\(<br>\)\+\s*\n\?/\r/g
			:silent global/^━ PR ━━\+$/:-1,/^━━\+$/+1delete _
			DelBlock('■最新科学情報をフォローしよう！　　', '━━\+', 0, 1)
			DelBlock('購読案内：　Nature ダイジェスト　お申し込みはこちら *', '===\+', -1, -1)
			:silent :/^配信停止はこちらからお手続きください。$/;$delete _
			:1 | silent :/^$/,$substitute/<a href="https:\/\/[^>]\+>\zehttps:\/\///g
			:1 | silent :/^$/,$substitute/?utm_source=\(Nature_TXT\|NM\)&utm_medium=\d\{8}&utm_campaign=Newsletter//g
			:1 | silent :/^$/,$substitute/<\/a>//g
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
		normal! zR
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
			DelBlock('==PR-\+', '-\+==', 0, 1)
			:silent execute ':1 | :/^＠ITの新着記事をお届けします。$/+1,/^--- NewsInsight -- 今日のニュース --\+$/-2delete | :/^━＠ITソーシャルアカウント━━━━━━━━━━━━━━━━━━━━━━━━━$/,/^発行：アイティメディア株式会社$/-2delete'
			setline('.', '-- ')
		elseif from ==? 'e_service@mof.go.jp'
			:silent execute ':1 | :/^当メールマガジンについてのご意見、ご感想はこちらへお願いします。$/;$delete | :%substitute/^　//g | :%substitute/　/ /g'
		elseif from ==? 'natureasia@e-alert.nature.com'
			Nature()
		elseif from ==? 'mailmag@mag2tegami.com'
			:silent :/\%^/,/^$/s/^From: *mag2 *0000013455 *<mailmag@mag2tegami.com>/From: Liyn-an <info@Liyn-an.com>/
			DelBlock('──\+\[PR\]─', '─\[PR\]──\+', -1, 1)
			:silent :/^ \+Copyright(c), 2022 \+Liyn-an co\.,Ltd./+2;$delete _
		else
			return
		endif
		:1 | :/^$/,$Zen2han
		@/ = search
		setlocal foldlevel=1
		setpos('.', pos)
	enddef
endif
#--------------------------------
#ファイルタイプ別ローカル設定
#--------------------------------
nnoremap <Leader>r <Cmd>call g:ReformMail()<CR>
