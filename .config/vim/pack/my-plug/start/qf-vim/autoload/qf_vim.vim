vim9script
scriptencoding utf-8
# Vim script のエラー内容を Quickfix に取り込む
# https://qiita.com/tmsanrinsha/items/0787352360997c387e84 を参考にした

export def QfMessages(): void
	function VerboseFunc(s) " {53} といった辞書関数だと def 関数内で処理できない
		return execute('verbose function ' .. a:s)
	endfunction

	def ParseErrorMessages(msgs: string): list<dict<any>>
		var qflist: list<dict<any>>       # 戻り値。setqflistの引数に使う配列
		var qf_info: dict<any>            # qflistの要素になる辞書
		var qf_info_list: list<dict<any>> # qflistの要素となる辞書の配列。エラー内容がスタックトレースのときに使用
		var files: dict<list<string>>     # 読み込んだファイルの内容をキャッシュしておくための辞書
		var func_name: string             # 関数名
		var verbose_func: string          # スクリプト・ローカルなどの関数内容
		var filename: string              # スクリプト・ファイル名
		var func_lines: list<string>      # スクリプト・ローカルなどの関数内容確認用
		var max_line: number              # 関数の行数
		var lnum: number                  # 関数内行番号
		var offset: number                # 行番号
		# var find_dic_func: number
		var regex_error_detect: string    # エラー検索文字列
		var script_error_detect: string   # message でエラーがない時このスクリプトからカレント・バッファを source した時の付加部分を削除する為の検索文字列
		var regex_line: string            # エラーから得る行癌号
		var regex_last_set: string
		var nr: any                       # エラー番号
		var text: string                  # エラー内容
		var ii: number
		var matched: string               # 検索のヒット部分文字列

		if v:lang =~# 'ja_JP'
			regex_error_detect = '^.\+\ze の処理中にエラーが検出されました:$'
			script_error_detect = '^.\+\[\d\+]\.\.script \ze.\+ の処理中にエラーが検出されました:$'
			regex_line = '^行\s\+\zs\d\+\ze:$'
			regex_last_set = '最後にセットしたスクリプト: \zs\f\+'
		else
			regex_error_detect = '^Error detected while processing \zs.\+\ze:$'
			script_error_detect = '^Error detected while processing \zs.\+\[\d\+]\.\.script \ze.\+:$'
			regex_line = '^line\s\+\zs\d\+\e:$'
			regex_last_set = 'Last set from \zs\f\+'
		endif

		for line in split(msgs, "\n")
			->map((_, v) => substitute(v, script_error_detect, '', ''))
			if line =~# regex_error_detect
				# ... の処理中にエラーが検出されました:'
				matched = matchstr(line, regex_error_detect)
				if matched =~# '\.\.function'
					# function <SNR>253_fuga の処理中にエラーが検出されました:
					# function <SNR>253_piyo[1]..<SNR>253_fuga の処理中にエラーが検出されました:
					matched = matchstr(matched, '^.\+\.\.function \zs\S*')
					for stack in reverse(split(matched, '\.\.'))
						[func_name, offset] = (stack =~# '\S\+\[\d') ? matchlist(stack, '\(\S\+\)\[\(\d\+\)\]')[1 : 2] : [stack, 0]
						func_name = (func_name =~# '^\d\+$') ? '{' .. func_name .. '}' : func_name # 辞書関数の数字は{}で囲む
						verbose_func = VerboseFunc(func_name)
						if verbose_func ==# '' # endfunction/enddef がない
							continue
						endif
						filename = matchstr(verbose_func, regex_last_set)
						filename = expand(filename)
						if !has_key(files, filename)
							files[filename] = readfile(filename)
						endif
						if func_name =~# '{\d\+}'
							func_lines = split(verbose_func, "\n")
							unlet func_lines[1]
							max_line = len(func_lines)
							func_lines[0] = '^\s*\(fu\%[nction]!\=\s\+\zs\S\+\.\S\+\|def\s\+\zs[^)]\+):\s\+[a-z<>]\+\)'
							for i in range(1, max_line - 2)
								func_lines[i] = '^\s*' .. matchstr(func_lines[i], '^\d\+\s*\zs.*')
							endfor
							func_lines[max_line - 1] = '^\s*end\(f[unction]\|def)'
							# lnum = 0
							# while 1
							# 	lnum = match(files[filename], func_lines[0], lnum)
							# 	if lnum < 0
							# 		throw 'No dictionary function'
							# 	endif
							# 	find_dic_func = 1
							# 	for i in range(1, max_line - 1)
							# 		if files[filename][lnum + i] !~# func_lines[i]
							# 			lnum = lnum + i
							# 			find_dic_func = 0
							# 			break
							# 		endif
							# 	endfor
							# 	if find_dic_func
							# 		break
							# 	endif
							# endwhile
							# ↑何のためか分らない
							lnum = match(files[filename], func_lines[0], lnum)
							func_name = matchstr(files[filename][lnum], func_lines[0])
							lnum += 1 + offset
						else
							func_name  = substitute(func_name, '<SNR>\d\+_', 's:', '')
							lnum = match(files[filename], '^\s*\(fu\%[nction]!\=\s\|def\)\+' .. func_name) + 1 + offset
						endif
						add(qf_info_list, {
									'filename': filename,
									'lnum': lnum,
									'text': func_name,
								})
					endfor
				else
					# <filename> の処理中にエラーが検出されました:
					filename = expand(matchstr(line, regex_error_detect))
					qf_info.filename = expand(filename)
				endif
			elseif line =~# regex_line
				# 行    1:
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
							val.text = '#' .. ii .. ' in ' .. val.text .. (ii == 0 ? (' | ' .. text) : '')
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
			endif
		endfor
		return qflist
	enddef

	var qflist: list<dict<any>> = ParseErrorMessages(execute('silent! messages'))
	setqflist(qflist, 'r')
	if qflist == [] # エラーがないので、開いているファイルを source
		qflist = ParseErrorMessages(execute('source %'))
		feedkeys("G\<Enter>")
		setqflist(qflist, 'r')
	endif
	cwindow
enddef
