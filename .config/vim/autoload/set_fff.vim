scriptencoding utf-8

function set_fff#init() abort
	if !pack_manage#IsInstalled('popup_preview')
		call set_popup_preview#init()
	endif
	packadd fuzzy-file-finder
	call timer_start(1, {->execute('delfunction set_fff#init')})
endfunction

function set_fff#main(cmd) abort
	if !pack_manage#IsInstalled('fuzzy-file-finder')
		call set_fff#init()
	endif
	call pack_manage#SetMAP('fuzzy-file-finder', a:cmd, [
				\ #{mode: 'n', key: '<silent><Leader>fr', method: 1, cmd: 'call fff#FFFiles(["~"])'},
				\ #{mode: 'x', key: '<silent><Leader>fr', method: 1, cmd: 'call fff#FFFiles(["~"])'},
				\ #{mode: 'n', key: '<silent><Leader>ff', method: 1, cmd: 'call fff#FFFiles()'},
				\ #{mode: 'x', key: '<silent><Leader>ff', method: 1, cmd: 'call fff#FFFiles()'},
				\ #{mode: 'n', key: '<silent><Leader>fu', method: 1, cmd: 'call fff#FFFiles([".."])'},
				\ #{mode: 'x', key: '<silent><Leader>fu', method: 1, cmd: 'call fff#FFFiles([".."])'},
				\ #{mode: 'n', key: '<silent><Leader>f.', method: 1, cmd: 'call fff#FFFiles(["~/dotfiles"])'},
				\ #{mode: 'x', key: '<silent><Leader>f.', method: 1, cmd: 'call fff#FFFiles(["~/dotfiles"])'},
				\ #{mode: 'n', key: '<silent><Leader>fv', method: 1, cmd: 'call fff#FFFiles(["$MYVIMDIR"])'},
				\ #{mode: 'x', key: '<silent><Leader>fv', method: 1, cmd: 'call fff#FFFiles(["$MYVIMDIR"])'},
				\ #{mode: 'n', key: '<silent><Leader>fs', method: 1, cmd: 'call fff#FFFiles(["~/src"])'},
				\ #{mode: 'x', key: '<silent><Leader>fs', method: 1, cmd: 'call fff#FFFiles(["~/src"])'},
				\ #{mode: 'n', key: '<silent><Leader>fx', method: 1, cmd: 'call fff#FFFiles(["~/bin"])'},
				\ #{mode: 'x', key: '<silent><Leader>fx', method: 1, cmd: 'call fff#FFFiles(["~/bin"])'},
				\ #{mode: 'n', key: '<silent><Leader>fe', method: 1, cmd: 'call fff#FFFiles(["~/book/epub"])'},
				\ #{mode: 'x', key: '<silent><Leader>fe', method: 1, cmd: 'call fff#FFFiles(["~/book/epub"])'},
				\ #{mode: 'n', key: '<silent><Leader>fd', method: 1, cmd: 'call fff#FFFiles(["~/downloads"])'},
				\ #{mode: 'x', key: '<silent><Leader>fd', method: 1, cmd: 'call fff#FFFiles(["~/downloads"])'},
				\ #{mode: 'n', key: '<silent><Leader>fD', method: 1, cmd: 'call fff#FFFiles(["~/Document"])'},
				\ #{mode: 'x', key: '<silent><Leader>fD', method: 1, cmd: 'call fff#FFFiles(["~/Document"])'},
				\ #{mode: 'n', key: '<silent><Leader>fp', method: 1, cmd: 'call fff#FFFiles(["~/public_html/iranoan"])'},
				\ #{mode: 'x', key: '<silent><Leader>fp', method: 1, cmd: 'call fff#FFFiles(["~/public_html/iranoan"])'},
				\ #{mode: 'n', key: '<silent><Leader>fi', method: 1, cmd: 'call fff#FFFiles(["~/Information/slide"])'},
				\ #{mode: 'x', key: '<silent><Leader>fi', method: 1, cmd: 'call fff#FFFiles(["~/Information/slide"])'},
				\ ])
	call timer_start(1, {->execute('delfunction set_fff#main')})
endfunction

