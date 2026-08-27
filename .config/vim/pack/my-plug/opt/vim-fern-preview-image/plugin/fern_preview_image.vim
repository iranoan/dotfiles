vim9script
scriptencoding utf-8

if get(g:, 'popup_preview', {}) == {}
	echohl ErrorMsg
		| echomsg 'Require popup_preview plugin.'
		| echohl None
	finish
endif

g:fern_preview_image = extendnew({}, get(g:, 'fern_preview_image', g:popup_preview), 'force')
# 下記カスタム可能
	# col:
	# line:
	# border:
	# borderchars:
	# width:
	# height:
