scriptencoding utf-8

call ale#linter#Define('html', #{
			\ name: 'vnu',
			\ output_stream: 'both',
			\ executable: exepath('java'),
			\ command: '%e -jar '.. get(g:, 'ale_vnu_use_global', '$HOME/node_modules/vnu-jar/build/dist/vnu.jar') .. ' --vabose --format json -',
			\ callback: 'ale_linters#html#vnu#HandleVnuJar',
			\ })

def ale_linters#html#vnu#HandleVnuJar(b: number, lines: list<string>): list<dict<any>>
	var output: list<dict<any>>
	var obj: dict<any>
	var type: string

	if type(json_decode(lines[0])) != 4
		echohl ErrorMsg
		for m in lines
			echomsg m
		endfor
		echohl None
		return []
	endif
	for input in json_decode(lines[0])['messages']
		obj = {
			lnum: get(input, 'firstLine', input.lastLine),
			end_lnum: input.lastLine,
			# end_lnum: get(input, 'lastLine', input.firstLine)
			col: input.firstColumn,
			end_col: input.lastColumn,
			text: input.message,
		}
		# { # 未使用要素
		# 	"messages":[
		# 	{
		# 		"extract":"<html>\n<head",
		# 		"hiliteStart":0,
		# 		"hiliteLength":6
		# 	}
		# 	]
		# }
		if len(getline(obj.lnum)) <= obj.col
			obj.lnum += 1
			obj.col = 1
		endif
		type = input.type
		if type ==# 'error'
			obj.type = 'E'
		elseif type ==# 'info'
			if get(input, 'subType', '') ==# 'warning'
				obj.type = 'W'
			else
				obj.type = 'I'
			endif
		elseif type ==# 'warning'
			obj.type = 'W'
		else
			obj.type = 'N'
		endif
		# if has_key(error, 'ruleId')
		# 	let code = error['ruleId']
		# 	 Sometimes ESLint returns null here
		# 	if !empty(code)
		# 		let obj.code = code
		# 	endif
		# endif
		add(output, obj)
	endfor
	return output
enddef
