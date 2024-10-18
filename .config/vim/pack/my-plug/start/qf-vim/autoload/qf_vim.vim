vim9script
scriptencoding utf-8
# Vim script のエラー内容を Quickfix に取り込む
# https://qiita.com/tmsanrinsha/items/0787352360997c387e84 を参考にした
# Python Interface 不完全

export def QfMessages(): void
	function VerboseFunc(s) " {53} といった辞書関数だと def 関数内で処理できない
		try
			return execute('verbose function ' .. a:s)->split("[\n\r]")[1]
		catch /^Vim\%((\a\+)\)\=:E123:/
			return ''
		endtry
	endfunction

	def ParseErrorMessages(msgs: string): list<dict<any>>
		var qflist: list<dict<any>>        # 戻り値。setqflistの引数に使う配列
		var qf_info: dict<any>             # qflistの要素になる辞書
		var qf_info_list: list<dict<any>>  # qflistの要素となる辞書の配列。エラー内容がスタックトレースのときに使用
		var file_cache: dict<list<string>> # 読み込んだファイルの内容をキャッシュしておくための辞書
		var func_name: string              # 関数名
		var filename: string               # スクリプト・ファイル名
		var func_info: string              # 関数の情報 (記載ファイル名と行番号)
		var func_lnum: string              # 関数の宣言行
		var lnum: number                   # 関数内行番号
		var regex_error_detect: string     # エラー検索文字列
		var regex_line: string             # エラーから得る行癌号
		var regex_last_set: string
		var nr: string                     # エラー番号
		var text: string                   # エラー内容
		var ii: number
		var matched: string                # 検索のヒット部分文字列
		var error: bool = false

		if v:lang =~# 'ja_JP'
			regex_error_detect = '^.\+\ze の\(処理\|コンパイル\)中にエラーが検出されました:$'
			regex_line = '^行\s\+\zs\d\+\ze:$'
			regex_last_set = '最後にセットしたスクリプト: \(\f\+\) 行 \(\d\+\)$'
		else
			regex_error_detect = '^Error detected while \(process\|compil\)ing \zs.\+\ze:$'
			regex_line = '^line\s\+\zs\d\+\ze:$'
			regex_last_set = 'Last set from \(\f\+\) Line \(\d\+\)$'
		endif

		for line in split(msgs, "\n")
									->map((_, v) => substitute(v, '^command line\.\.', '', ''))
									->map((_, v) => substitute(v, '^function \S\+\[\d\+]\.\.script ', '', ''))
			if line =~# regex_error_detect # ... の処理中にエラーが検出されました:'
				error = false
				matched = matchstr(line, regex_error_detect)
				if matched =~# '\.\.function'
					func_name = matchstr(matched, '^.\+\.\.function \zs\S*')
					for stack in reverse(split(matched, '\.\.')[1 : ])
						func_name = (func_name =~# '^\d\+$') ? '{' .. func_name .. '}' : func_name # 辞書関数の数字は{}で囲む
						func_info = VerboseFunc(func_name)
						if func_info ==# '' # endfunction/enddef がない
							continue
						endif
						[filename, func_lnum] = matchlist(func_info, regex_last_set)[1 : 2 ]
						filename = expand(filename)
						if !has_key(file_cache, filename)
							file_cache[filename] = readfile(filename)
						endif
						lnum = str2nr(func_lnum)
						add(qf_info_list, {
									'filename': filename,
									'lnum': lnum,
									'text': matchstr(file_cache[filename][lnum - 1], '^\s*\(fu\%[nction]!\=\s\+\|def\s\+\)\zs[^(]\+')
								})
					endfor
				else # <filename> の処理中にエラーが検出されました:
					filename = expand(matchstr(line, regex_error_detect))
					qf_info.filename = expand(filename)
				endif
			elseif line =~# regex_line
				# 行    1:
				error = true
				lnum = str2nr(matchstr(line, regex_line))
				if len(qf_info_list) > 0
					qf_info_list[0].lnum += lnum
				else
					qf_info.lnum = lnum
				endif
			elseif line =~# '^E'
				# E492: エディタのコマンドではありません: one
				[nr, text] = matchlist(line, '^E\(\d\+\): \(.\+\)')[1 : 2]
				if len(qf_info_list) > 0
					if len(qf_info_list) == 1
						qf_info_list[0].nr = str2nr(nr)
						qf_info_list[0].text = 'in ' .. qf_info_list[0].text .. ' | ' .. text
					else
						ii = 0
						for val in qf_info_list
							val.nr = str2nr(nr)
							val.text = ' in ' .. val.text .. (ii == 0 ? (' | ' .. text) : '')
							ii += 1
						endfor
					endif
					qflist += qf_info_list
				else
					qf_info.nr = str2nr(nr)
					qf_info.text = text
					add(qflist, qf_info)
				endif
				qf_info = {}
				qf_info_list = []
			elseif error # Python Interface
				if line =~# '^  File "[^"]\+", line \d\+$'
					[filename, nr] = matchlist(line, '^  File "\([^"]\+\)", line \(\d\+\)$')[1 : 2]
					qf_info_list = []
				elseif line =~# '^    '
					qf_info_list = add(qf_info_list, {
													lnum: str2nr(nr),
													text: '| ' .. line[4 : ]
												})
				elseif line =~# '^[A-Za-z]\+Error: '
					add(qflist, {
											filename: filename,
											lnum: str2nr(nr),
											text: line
							})
					qflist += qf_info_list
					qf_info_list = []
					error = false
				endif
			endif
		endfor
		return qflist
	enddef

	var qflist: list<dict<any>> = ParseErrorMessages(execute('silent! messages'))
	if qflist == [] # エラーがないので、開いているファイルを source
		qflist = ParseErrorMessages(execute('source ' .. expand('%:p')))
		feedkeys("G\<Enter>")
	endif
	setqflist(qflist, 'r')
	cwindow
enddef
