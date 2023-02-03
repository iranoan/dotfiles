vim9script
scriptencoding utf-8

def Enviroment(): list<string>
	var mes: list<string>
	if has('unix')
		if executable('lsb_release')
			add(mes, '$ lsb_release -a')
			extend(mes, systemlist('lsb_release -a'))
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
		extend(mes, systemlist('chcp 65001 | systeminfo')[2 : 6])
	endif
	return mes
enddef

def System(): list<string>
	var mes: list<string> = ['$ vim --version']
	var win: string
	extend(mes, split(execute('version'), '\n'))
	mes[3] = substitute(mes[3], $USER .. '@' .. systemlist('hostname')[0], 'xxx@xxx', '')
	if has('win32') || has('win64')
		mes[0] = '> vim --version'
	endif
	extend(mes, Enviroment())
	return mes
enddef

export def Write(): void
	append(line('.') - 1, System())
enddef

export def Echo(): void
	echo join(System(), "\n")
enddef

export def EnvWrite(): void
	append(line('.') - 1, Enviroment())
enddef

export def EnvEcho(): void
	echo join(Enviroment(), "\n")
enddef
