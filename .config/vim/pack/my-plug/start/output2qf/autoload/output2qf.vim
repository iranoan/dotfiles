vim9script
scriptencoding utf-8

export def Shell(...ls: list<string>): void
	var ret: list<string> = systemlist(join(ls, ' '))->map('v:val .. ":1: "')
	if len(ret) == 0
		echohl WarningMsg
		echo 'Empty Result'
		echohl None
		return
	endif
	cexpr join(ret, "\n")
	copen
enddef


export def Vim(): void # Vim script のエラー内容を Quickfix に取り込む
	# https://qiita.com/tmsanrinsha/items/0787352360997c387e84 に触発された→変数名などが共通している部分がある
	def ParseErrorMessages(msgs: string): list<dict<any>>
		var qflist: list<dict<any>>        # 戻り値。setqflist の引数に使う配列
		var qf_list: list<dict<any>>       # qflist に後から入れる
		var file_cache: dict<list<string>> # 読み込んだファイルの内容をキャッシュしておくための辞書
		var filename: string               # スクリプト・ファイル名
		var ifilename: string              # 外部 interface のファイル名 (空かどうかで interface のファイルを読み込んでいるか? の判定にも使用)
		var lnum: number                   # 関数内行番号
		var lnum_s: string                 # lnum を数値に変換する前の文字列
		var regex_process: string          # 処理中エラー検索文字列
		var regex_compile: string          # コンパイル中エラー検索文字列
		var regex_line: string             # エラーから得る行番号
		var regex_last_set: string         # verbose function で表示されるファイル名と行番号の検索文字列
		var Undefined_func: string         # verbose function で未定義関数のエラー文字列
		var nr: string                     # エラー番号
		var text: string                   # エラー内容
		var output_flag: number            # 直前のアウトプットの種類 0b001: エラー検出行あり 0b010 エラー行あり 0b100 エラー内容あり
		var error_index: number            # エラー処理の書き換えが必要になる qflist に入れた順序
		var error_iindex: number           # 外部 interface のエラー処理の書き換えが必要になる qflist に入れた順序
		var dummy: string                  # matchlist() の返り値の内、使わない分のダミー

		if v:lang =~# 'ja_JP'
			regex_process = '^\(\S.\+\) の処理中にエラーが検出されました:$'
			regex_compile = '^\(\S.\+\) のコンパイル中にエラーが検出されました:$'
			regex_line = '^行\s\+\zs\d\+\ze:$'
			regex_last_set = '^\t最後にセットしたスクリプト: \(\f\+\) 行 \(\d\+\)$'
			Undefined_func = 'E123: 未定義の関数です: '
		else
			regex_process = '^Error detected while processing \(\S.\+\):$'
			regex_compile = '^Error detected while compiling \(\S.\+\):$'
			regex_line = '^line\s\+\zs\d\+\ze:$'
			regex_last_set = '^\tLast set from \(\f\+\) Line \(\d\+\)$'
			Undefined_func = 'E123: Undefined function: '
		endif

		def BeginError(o: string, s: string): void
			var l: string = substitute(o, s, '\1', '')
												->substitute('^command line\.\.', '', '')
												->substitute('\(\.\.\)\?\a\+\s\+Autocommands\s\+for\s\+\S\+\ze\.\.', '', '')
			var is_file: bool = true # 処理の対象が true: file, false: function
			var func_file: string    # 関数/ファイル名+行番号
			var func_name: string    # 関数名
			var offset: string       # 呼び出し元の行番号

			def GetFuncInfo(O: string, n: string, t: string): dict<any>
				var f = (O =~# '^\d\+$') ? '{' .. O .. '}' : O # 辞書/ラムダ関数の数字は {} で囲む
				var fname: string # ファイル名

				try
					fname = execute('legacy verbose function ' .. f)->split("[\n\r]")[1] # {53} といった辞書関数だと vim9script で処理できない
				catch /^Vim\%((\a\+)\)\=:E123:/
					fname = ''
				endtry
				if fname ==# '' # 未定義の関数
					return {
							filename: filename,
							lnum: 0,
							text: Undefined_func .. f,
							type: 'E',
							nr: 123
						}
				endif
				[fname, lnum_s] = matchlist(fname, regex_last_set)[1 : 2]
				fname = expand(fname)
				if !has_key(file_cache, fname)
					file_cache[fname] = readfile(fname)
				endif
				lnum = str2nr(lnum_s)
				func_name = matchstr(file_cache[fname][lnum - 1 : lnum + 2]->join(' '), '^\s*\(export\s\+\)\?\(fu\%[nction]!\=\s\+\|def\s\+\)\zs[^(]\+')
				# lambda 式では複数行の場合があるので
				lnum += str2nr(n)
				return {
							filename: fname,
							lnum: lnum,
							text: t .. 'in ' .. func_name,
							type: t == 'calling location: ' ? 'I' : 'E',
							nr: 1
						} # ↑情報はとりあえず1としておき、それ以外は通常あとから書き換わる
			enddef

			output_flag = 0b001
			ifilename = ''
			error_index = len(qflist)
			qf_list = []
			for i in split(l, '\.\.')
				func_file = i
				if func_file =~# '^function '
					func_file = func_file[9 : ]
					is_file = false
				elseif func_file =~# '^script '
					func_file = func_file[7 : ]
					is_file = true
				endif
				if is_file
					[filename, dummy, offset] = matchlist(func_file, '\(\f\+\)\(\[\(\d\+\)\]\)\?')[1 : 3]
					filename = expand(filename)
					lnum = str2nr(offset)
					add(qf_list, {
						filename: filename,
						lnum: lnum,
						text: lnum == 0 ? '' : 'calling location',
						type: lnum == 0 ? 'E' : 'I',
						nr: 1
					})
				else
					[func_name, dummy, offset] = matchlist(func_file, '\c\([a-z0-9#<>_]\+\)\(\[\(\d\+\)\]\)\?')[1 : 3]
					add(qf_list, GetFuncInfo(func_name, offset, offset ==# '' ? '' : 'calling location: '))
				endif
			endfor
			qflist += reverse(qf_list)
		enddef

		def ChangeQfItem(i_v: number, s: string, i_i: number, n: string, t: string): void
			qflist[i_i].nr = str2nr(n)
			qflist[i_i].type = t
			if i_i != i_v
				qflist[i_v].nr = str2nr(n)
				qflist[i_v].type = t
			endif
			if qflist[i_v].text !=# ''
				qflist[i_v].text ..= ' | ' .. s
			else
				qflist[i_v].text = s
			endif
		enddef

		for line in split(msgs, "\n")
			if line =~# regex_process # ... の処理中にエラーが検出されました:'
				BeginError(line, regex_process)
			elseif line =~# regex_compile # ... のコンパイル中にエラーが検出されました:'
				BeginError(line, regex_compile)
			elseif line =~# regex_line # 行番号
				if and(output_flag, 0b001) != 0 # エラー検出あり
					qflist[error_index].lnum += str2nr(matchstr(line, regex_line))
				else
					add(qflist, {
							filename: filename,
							lnum: str2nr(matchstr(line, regex_line))
						}
					)
				endif
				output_flag = or(output_flag, 0b010)
				ifilename = ''
			elseif line =~# '^[EW]' # E492: エディタのコマンドではありません: ... 等
				[nr, text] = matchlist(line, '^E\(\d\+\): \(.\+\)')[1 : 2]
				if and(output_flag, 0b001) == 0b001 # エラー検出行あり
					ChangeQfItem(error_index, text, error_index, nr, (line =~# '^W' ? 'W' : 'E'))
				elseif output_flag == 0b100 # 直前もエラー内容行
					continue # エラー処理もエラー行もないのでエラー箇所を特定できない←大抵同じエラーの繰り返し?
					# add(qflist, { filename: filename, lnum: lnum, nr: str2nr(nr), text: text })
				elseif and(output_flag, 0b010) == 0b010 # 直前エラー行
					qflist[-1].text = text
					qflist[-1].nr = str2nr(nr)
				endif
				output_flag = 0b100
				ifilename = ''
			elseif and(output_flag, 0b011) != 0 # 外部 interface 等エラー処理の開始や行番号出力とエラー内容行の間
				if line =~# '^  File "[^"]\+", line \d\+\(, in \w\+\)\?$'
					[ifilename, lnum_s, dummy, text] = matchlist(line, '^  File "\([^"]\+\)", line \(\d\+\)\(, \(in \w\+\)\)\?$')[1 : 4]
					error_iindex = len(qflist)
					add(qflist, {
						filename: expand(ifilename),
						lnum: str2nr(lnum_s),
						text: text,
						type: 'I',
						nr: 1
					})
				elseif line =~# '^[A-Za-z]\+Error: ' # Python interface の内部エラー内容
					if ifilename == ''
						add(qflist, {text: line})
					else
						ChangeQfItem(error_iindex, line, error_index, '169', 'E')
					endif
					ifilename = ''
				elseif line =~# 'vim.error: Vim(\w\+):E\d\+: ' # 外部インターフェースで vim.command() を使い Vim のエラーが起きた時
					if ifilename == ''
						add(qflist, {text: line})
					else
						[text, nr] = matchlist(line, 'vim.error: Vim(\w\+):E\(\d\+\): .\+' )[ : 1]
						ChangeQfItem(error_iindex, text, error_iindex, nr, 'E')
					endif
					ifilename = ''
				else # それ以外はそのまま加える
					add(qflist, { text: line })
				endif
			endif
		endfor
		return qflist
	enddef

	var qflist: list<dict<any>> = ParseErrorMessages(execute('silent! messages'))
	if qflist == [] && &filetype ==# 'vim' # エラーがないので、開いているファイルを source
		qflist = ParseErrorMessages(execute('source ' .. expand('%:p')))
	endif
	setqflist(qflist, 'r')
	cwindow
enddef
