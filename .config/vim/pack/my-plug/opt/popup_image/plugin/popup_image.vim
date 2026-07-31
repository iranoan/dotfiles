vim9script
scriptencoding utf-8

g:popup_image_options = extendnew({pt2px: {x: 96, y: 96}, min_size: {x: 5, y: 5}}, get(g:, 'popup_image_options', {}), 'force')
