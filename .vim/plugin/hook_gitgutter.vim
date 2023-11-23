scriptencoding utf-8

function! s:obtain_file_renames(bufnr, base)
	let renames = {}
	let cmd = gitgutter#git()
	if gitgutter#utility#git_supports_command_line_config_override()
		let cmd .= ' -c "core.safecrlf=false"'
	endif
	let cmd .= ' diff --diff-filter=R --name-status '.a:base
	let [out, error_code] = gitgutter#utility#system(gitgutter#utility#cd_cmd(a:bufnr, cmd))
	if error_code
		" Assume the problem is the diff base.
		call gitgutter#utility#warn('g:gitgutter_diff_base ('.a:base.') is invalid')
		return {}
	endif
	for line in split(out, '\n')
		let ls = split(line)
		if ls[0] == 'warning:'
			continue
		endif
		try
			let [original, current] = ls[1:]
		catch /^Vim\%((\a\+)\)\=:E687:/
			echomsg ls
			continue
		endtry
		let renames[current] = original
	endfor
	return renames
endfunction
