vim9script
scriptencoding utf-8

def Enviroment(): list<string>
	var mes: list<string>
	if has('unix')
		if getftype('/etc/os-release') !=# ''
			add(mes, '$ cat /etc/os-release')
			extend(mes, systemlist('cat /etc/os-release'))
		else
			add(mes, '$ cat /etc/issue')
			extend(mes, systemlist('cat /etc/issue'))
		endif
		add(mes, '$ uname -a')
		extend(mes, systemlist('uname -a'))
		mes[-1] = substitute(mes[-1], systemlist('hostname')[0], 'xxx', '')
	elseif has('osx')
		add(mes, '$ sw_vers')
		extend(mes, systemlist('sw_vers'))
	elseif has('win32') || has('win64')
		add(mes, '> systeminfo')
		var cp: string = 'cp' .. substitute(system('chcp'), '^[^0-9]\+\(\d\+\)\n\?', '\1', '')
		extend(mes, split(iconv(system('systeminfo'), cp, 'utf-8'), '\n')[0 : 5])
	endif
	return mes
enddef

def System(): list<string>
	var mes: list<string> = [ ( ( has('win32') || has('win64') ) ? '>' : '$' ) .. ' vim --version' ]
	extend(mes, split(execute('version'), '\n'))
	mes[3] = substitute(mes[3], $USER .. '@' .. systemlist('hostname')[0], 'xxx@xxx', '')
	extend(mes, Enviroment())
	return mes
enddef

export def Write(): void
	append(line('.'), System())
enddef

export def Echo(): void
	echo join(System(), "\n")
enddef

export def EnvWrite(): void
	append(line('.'), Enviroment())
enddef

export def EnvEcho(): void
	echo join(Enviroment(), "\n")
enddef
