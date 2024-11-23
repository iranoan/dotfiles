scriptencoding utf-8

function! s:css_validator() abort
	let jar = get(g:, 'als_css_validator_use_global', expand('$HOME/bin/jar'))
	if jar !~# '[/\\]$'
		let jar ..= '/'
	endif
	return jar .. 'css-validator.jar:'
				\ .. jar .. 'tagsoup-1.2.1.jar:'
				\ .. jar .. 'xercesImpl.jar:'
				\ .. jar .. 'commons-collections-3.2.1.jar:'
				\ .. jar .. 'commons-lang-2.6.jar:'
				\ .. jar .. 'jigsaw.jar:'
				\ .. jar .. 'velocity-1.7.jar:'
				\ .. jar .. 'xml-apis.jar'
endfunction

call ale#linter#Define('css', #{
			\ name: 'css-validator',
			\ output_stream: 'stdout',
			\ executable: exepath('java'),
			\ command: '%e -jar "' ..  get(g:, 'als_css_validator_use_global', '$HOME/bin/jar/css-validator.jar') .. '" --output=json --profile=css3 --lang=ja --vextwarning=true file:%t',
			\ callback: 'ale_linters#css#ale_css_validator#Handle',
			\ })
			" \ command: '%e -classpath "' .. s:css_validator() .. '" --output=json --profile=css3 --lang=ja --vextwarning=true file:%t',

delfunction s:css_validator

def ale_linters#css#ale_css_validator#Handle(b: number, lines: list<string>): list<dict<any>>
	var output: list<dict<any>>
	var obj: dict<any>
	var type: string
	var mes: string
	var ret: dict<any> = json_decode(lines->join('')).cssvalidation
	if ret.uri =~# '\.html\?' # HTML ファイルの style 属性には未対応
		|| ( ret.result.errorcount == 0 && ret.result.warningcount == 0 )
		return []
	endif
	# 未使用要素
	# date 2023-12-10T01:47:27Z
	# timestamp 1702216047007
	# csslevel css3
	# checkedby http://www.w3.org/2005/07/css-validator
	# validity false

	for [k, v] in items({errors: 'E', warnings: 'W'})
		for i in get(ret, k, [])
			mes = (has_key(i, 'context') ? i.context .. ': ' : '') .. i.message .. (has_key(i, 'type') ? ' [' .. i.type .. ']' : '')
			obj = {
				lnum: i.line,
				# end_lnum: ,
				# col: ,
				# end_col: ,
				text: mes,
				detail: '[css-validator] '  .. mes,
				type: v,
			}
			# 未使用要素
			# 'level': 0,
			# 'source': 'file:/home/hiroyuki/downloads/test/sample.css',
			add(output, obj)
		endfor
	endfor
	return output
enddef
