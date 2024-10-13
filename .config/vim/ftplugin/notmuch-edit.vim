vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user')
	finish
endif
b:did_ftplugin_user = 1

# ファイルタイプ別のグローバル設定 {{{1
if !exists("g:mail_draft_plugin")
	g:mail_draft_plugin = 1
	packadd transform
	def g:ReformMail(): void # ML の広告を削除する個人的な関数
		def DelBlock(s: string, e: string, i: number, j: number): void # s, e 両方の文字列 (行) が有ったときのみ、その範囲を削除
			var buf: list<string>
			var start: number
			var s_pos: number
			var l: number = 1
			while true
				buf = getline(l, '$')
				start = match(buf, '^$')
				s_pos = match(buf, '^' .. s .. '$', start) + 1
				if !s_pos
					return
				endif
				var e_pos = match(buf, '^' .. e .. '$', s_pos)
				if e_pos == -1
					return
				endif
				l = s_pos
				s_pos = s_pos + i
				e_pos = e_pos + 1 + j
				silent execute ':' .. s_pos .. ',' .. e_pos .. 'delete _'
			endwhile
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
			DelBlock('日経ニュースメール　\d\+/\d\+ [朝昼夕]版', '━　注目ニュース　━━━━━━━', 2, -2)
			DelBlock('■このメールは送信専用メールアドレスから配信されています。', '■配信元：日本経済新聞社', 0, -1)
		elseif from ==? 'atmarkit_newarrivals@noreply.itmedia.co.jp'
			DelBlock('==PR-\+', '-\+==', 0, 1)
			silent execute ':1 | :/^＠ITの新着記事をお届けします。$/+1,/^--- NewsInsight -- 今日のニュース --\+$/-2delete | :/^━＠ITソーシャルアカウント━━━━━━━━━━━━━━━━━━━━━━━━━$/,/^発行：アイティメディア株式会社$/-2delete'
			setline('.', '-- ')
		elseif from ==? 'mailmag@mag2tegami.com'
			silent :/\%^/,/^$/s/^From: *mag2 *0000013455 *<mailmag@mag2tegami.com>/From: Liyn-an <info@Liyn-an.com>/
			silent :/^☆Ｏｏｏｏ.... 紅 茶 通 信 ☆ Liyn-an Tea TIMES ....ｏｏＯ☆/+2;$delete _
			DelBlock('──\+\[PR\]─', '─\[PR\]──\+', 0, 1)
		elseif from ==? 'ndh-news@nikkeibp.co.jp'
			DelBlock('', '◇日経デジタルヘルスNEWS', 0, -3)
		elseif from ==? 'xtech-ac@nikkeibp.co.jp'
			silent :1 | :/^$/,/^$/+1delete | silent :%s/^　//ge
			DelBlock('□■　注目のセミナー', '', 0, -1)
			DelBlock('□■　.\+ランキング　\d\{1,2}/\d\{1,2}', '', 0, -1)
			DelBlock('□■　お知らせ', '', 0, -1)
			DelBlock('◆登録内容の変更や配信停止は', 'Copyright (C)\d\{4}、日経BP', 0, -1)
		elseif from ==? 'xtech-pcmobile@nikkeibp.co.jp'
			DelBlock('-PR-', '-PR-', -1, 1)
			DelBlock('★リスキリングに効く！日経クロステック法人向け特別プラン', 'Copyright(C) \d\{4}　日経BP', -1, -2)
			silent :1 | :/^$/,/^$/+1delete | silent :%s/^　//ge
		elseif from ==? 'e_service@mof.go.jp'
			silent execute ':1 | :/当メールマガジンについてのご意見、ご感想はこちらへお願いします。/;$delete'
			silent silent :%s/^　//ge | silent :%s/<\(br \/\|\/div\|\/p\|^　\)>//ge | :1 | silent :/^$/,$s/<[^>]\+>\n\?//ge | silent :%s/&nbsp;/ /ge | silent :%s/&hellip;/…/ge | silent :%s/　/ /ge | :1 | silent :/^$/,$s/^\s//e | silent :/\%^/,/^$/s/text\/\zshtml/plain/e | silent :%s/^\n\zs\n+//e | silent :%s/&ldquo;/“/ge | silent :%s/&rdquo;/”/ge
		else
			return
		endif
		:1 | :/^$/,$Zen2han
		@/ = search
		setlocal foldlevel=1
		setpos('.', pos)
	enddef
endif

# ファイルタイプ別ローカル設定 {{{1
nnoremap <Leader>r <Cmd>call g:ReformMail()<CR>

# Undo {{{1
if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| setlocal foldlevel<'
else
	b:undo_ftplugin = 'setlocal foldlevel<'
endif
