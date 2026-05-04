vim9script
scriptencoding utf-8

export def SetGhostText(): void
	var f: string = expand('%')[6 : -5]
	var uri2filetype: dict<list<string>> = readfile(expand('<script>:p:h') .. '/uri2filetype.json')
	                                 	->join()
	                                 	->json_decode()
	# JSON format
	# {
	# 	"1": ["mail.google.com", "mail"],
	# 	"2": ["github.com",      "markdown"]
	# }
	# 優先順位をつけたいので、数字をキーにしている

	for [i, v] in items(uri2filetype)
		if f =~# '^' .. substitute(v[0], '\.', '\\.', 'g')
			&filetype = v[1]
			break
		endif
	endfor

	setlocal nomodified
	system('wmctrl -ia "$( wmctrl -l | grep -E ".+ - GVIM[0-9]*$" | sed -E ''s/ .+$//g'' )"' )
enddef
