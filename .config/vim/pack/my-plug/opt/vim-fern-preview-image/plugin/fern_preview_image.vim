vim9script
scriptencoding utf-8

if get(g:, 'popup_preview', {}) == {}
	echohl ErrorMsg
		| echomsg 'Require popup_preview plugin.'
		| echohl None
	finish
endif

if extendnew(get(g:, 'fern_preview_image_loaded', {loaded: false}), {loaded: false}).loaded
	finish
endif

g:fern_preview_image = extendnew({loaded: true}, get(g:, 'fern_preview_image', g:popup_preview), 'force')
