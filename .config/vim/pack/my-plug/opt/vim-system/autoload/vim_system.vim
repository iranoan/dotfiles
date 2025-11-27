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

def Desktop(): list<string>
	var mes: list<string>
	if has('unix')
			add(mes, '$ echo $XDG_CURRENT_DESKTOP')
			extend(mes, systemlist('sh -c "echo $XDG_CURRENT_DESKTOP"'))
			if $XDG_CURRENT_DESKTOP =~? 'GNOME'
				add(mes, '$ gnome-shell --version')
				extend(mes, systemlist('gnome-shell --version'))
			elseif $XDG_CURRENT_DESKTOP =~? 'plasma' || $XDG_CURRENT_DESKTOP =~? 'kde'
				if executable('plasmashell')
					add(mes, '$ plasmashell --version')
					extend(mes, systemlist('plasmashell --version'))
				else
					add(mes, '$ kf5-config --version')
					extend(mes, systemlist('kf5-config --version | grep "Qt:"'))
				endif
			elseif $XDG_CURRENT_DESKTOP =~? 'mate'
				add(mes, '$ mate-session --version')
				extend(mes, systemlist('mate-session --version'))
			elseif $XDG_CURRENT_DESKTOP =~? 'xfce'
				add(mes, '$ xfce-session --version')
				add(mes, systemlist('xfce-session --version')[0])
			elseif $XDG_CURRENT_DESKTOP =~? 'cinnamon'
				add(mes, '$ cinnamon --version')
				extend(mes, systemlist('cinnamon --version'))
			elseif $XDG_CURRENT_DESKTOP =~? 'lxqt'
				add(mes, '$ lxqt-about --version')
				extend(mes, systemlist('lxqt-about --version'))
			elseif $XDG_CURRENT_DESKTOP =~? 'lxde'
				add(mes, '$ lxsession --version')
				extend(mes, systemlist('lxsession --version'))
			endif
			add(mes, '$ echo $XDG_SESSION_TYPE')
			extend(mes, systemlist('sh -c "echo $XDG_SESSION_TYPE"'))
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
	append(line('.'), Enviroment() + Desktop())
enddef

export def EnvEcho(): void
	echo join(Enviroment() + Desktop(), "\n")
enddef
