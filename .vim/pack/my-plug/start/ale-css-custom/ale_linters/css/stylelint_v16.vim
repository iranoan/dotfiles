call ale#Set('css_stylelint_executable', 'stylelint-v16')
call ale#Set('css_stylelint_options', '')
call ale#Set('css_stylelint_use_global', get(g:, 'ale_use_global_executables', 0))

function! s:css_stylelint(buffer) abort
	return '%e ' .. ale#Pad(ale#Var(a:buffer, 'css_stylelint_options'))
				\ .. ' -f json --no-color --stdin-filename %s --stdin --'
endfunction

call ale#linter#Define('css', #{
			\ name: 'stylelint-v16',
			\ executable: 'stylelint',
			\ output_stream: 'stderr',
			\ command: s:css_stylelint(bufnr()),
			\ callback: 'ale_linters#css#stylelint_v16#Handle',
			\ })

delfunction s:css_stylelint

def ale_linters#css#stylelint_v16#Handle(b: number, lines: list<string>): list<dict<any>>
	var output: list<dict<any>>
	var obj: dict<any>
	var type: string
	for i in json_decode(lines[0])[0].warnings
		# 未使用要素
		# "source":"<input css 1>",
		# "deprecations":[],
		# "invalidOptionWarnings":[],
		# "parseErrors":[],
		# "errored":true,
		obj = {
			lnum: i.line,
			end_lnum: get(i, 'endLine', i.line),
			col: i.column,
			end_col: get(i, 'endColumn', i.column),
			text: i.text,
			type: i.severity ==# 'error' ? 'E' : 'W',
			detail: '[stylelint-v16] ' .. i.text,
		}
		add(output, obj)
	endfor
	return output
enddef
