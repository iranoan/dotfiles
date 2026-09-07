scriptencoding utf-8

function! set_complete_popup_image#init() abort
	if !pack_manage#IsInstalled('popup_image')
		call set_popup_image#init()
	endif
	packadd complete-preview-image
	call timer_start(1, {->execute('delfunction set_complete_popup_image#init')})
endfunction
