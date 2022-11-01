vim9script

def Get_syn_id(transparent: bool): number
	var v_synid = synID(line('.'), col('.'), 1)
	if transparent
		return synIDtrans(v_synid)
	else
		return v_synid
	endif
enddef

def Get_syn_attr(synid: number): dict<string>
	var name = synIDattr(synid, 'name')
	var ctermfg = synIDattr(synid, 'fg', 'cterm')
	var ctermbg = synIDattr(synid, 'bg', 'cterm')
	var guifg = synIDattr(synid, 'fg', 'gui')
	var guibg = synIDattr(synid, 'bg', 'gui')
	return {
				'name': name,
				'ctermfg': ctermfg,
				'ctermbg': ctermbg,
				'guifg': guifg,
				'guibg': guibg
				}
enddef

export def Main(): void
	var baseSyn = s:Get_syn_attr(s:Get_syn_id(0))
	echo 'name: ' .. baseSyn.name ..
				' ctermfg: ' .. baseSyn.ctermfg ..
				' ctermbg: ' .. baseSyn.ctermbg ..
				' guifg: ' .. baseSyn.guifg ..
				' guibg: ' .. baseSyn.guibg
	var linkedSyn = s:Get_syn_attr(s:Get_syn_id(1))
	echo 'link to'
	echo 'name: ' .. linkedSyn.name ..
				' ctermfg: ' .. linkedSyn.ctermfg ..
				' ctermbg: ' .. linkedSyn.ctermbg ..
				' guifg: ' .. linkedSyn.guifg ..
				' guibg: ' .. linkedSyn.guibg
enddef
