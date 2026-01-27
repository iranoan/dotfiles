vim9script

export def Main(): void
	def Get_syn_id(transparent: bool): number
		var v_synid = synID(line('.'), col('.'), 1)
		if transparent
			return synIDtrans(v_synid)
		else
			return v_synid
		endif
	enddef

	def Get_syn_attr(synid: number): dict<string>
		var name: string = synIDattr(synid, 'name')
		var ctermfg: string = synIDattr(synid, 'fg', 'cterm')
		var ctermbg: string = synIDattr(synid, 'bg', 'cterm')
		var ctermul: string = synIDattr(synid, 'ul', 'cterm')
		var guifg: string = synIDattr(synid, 'fg', 'gui')
		var guibg: string = synIDattr(synid, 'bg', 'gui')
		var guisp: string = synIDattr(synid, 'sp', 'gui')
		var cterm: string = (synIDattr(synid, 'bold', 'cterm') ==# '1' ? ',bold' : '') ..
			(synIDattr(synid, 'italic', 'cterm') ==# '1' ? ',italic' : '') ..
			(synIDattr(synid, 'reverse', 'cterm') ==# '1' ? ',reverse' : '') ..
			(synIDattr(synid, 'inverse', 'cterm') ==# '1' ? ',inverse' : '') ..
			(synIDattr(synid, 'standout', 'cterm') ==# '1' ? ',standout' : '') ..
			(synIDattr(synid, 'underline', 'cterm') ==# '1' ? ',underline' : '') ..
			(synIDattr(synid, 'undercurl', 'cterm') ==# '1' ? ',undercurl' : '') ..
			(synIDattr(synid, 'strike', 'cterm') ==# '1' ? ',strike' : '') ..
			(synIDattr(synid, 'nocombine', 'cterm') ==# '1' ? ',nocombine' : '')
		var gui: string = (synIDattr(synid, 'bold', 'gui') ==# '1' ? ',bold' : '') ..
			(synIDattr(synid, 'italic', 'gui') ==# '1' ? ',italic' : '') ..
			(synIDattr(synid, 'reverse', 'gui') ==# '1' ? ',reverse' : '') ..
			(synIDattr(synid, 'inverse', 'gui') ==# '1' ? ',inverse' : '') ..
			(synIDattr(synid, 'standout', 'gui') ==# '1' ? ',standout' : '') ..
			(synIDattr(synid, 'underline', 'gui') ==# '1' ? ',underline' : '') ..
			(synIDattr(synid, 'undercurl', 'gui') ==# '1' ? ',undercurl' : '') ..
			(synIDattr(synid, 'strike', 'gui') ==# '1' ? ',strike' : '') ..
			(synIDattr(synid, 'nocombine', 'gui') ==# '1' ? ',nocombine' : '')
		return {
			name: name,
			ctermfg: ctermfg,
			ctermbg: ctermbg,
			ctermul: ctermul,
			cterm: substitute(cterm, '^,', '', ''),
			guifg: guifg,
			guibg: guibg,
			guisp: guisp,
			gui: substitute(gui, '^,', '', ''),
		}
	enddef

	def GetInfo(dict: dict<string>): string
		def NotEmpty(d: dict<string>, s: string): string
			if d[s] ==# ''
				return ''
			endif
			return ' ' .. s .. '=' .. d[s]
		enddef

		var str: string
		for s in ['cterm', 'ctermfg', 'ctermbg', 'ctermul', 'gui', 'guifg', 'guibg', 'guisp',]
			str ..= NotEmpty(dict, s)
		endfor
		return str
	enddef

	var baseSyn = Get_syn_attr(Get_syn_id(0))
	var linkedSyn = Get_syn_attr(Get_syn_id(1))
	if baseSyn.name == linkedSyn.name
		echo 'name: ' .. baseSyn.name .. GetInfo(baseSyn)
	else
		echo 'name: ' .. baseSyn.name .. "\n" ..
			'link to' .. "\n" ..
		'name: ' .. linkedSyn.name  .. GetInfo(linkedSyn)
	endif
enddef
