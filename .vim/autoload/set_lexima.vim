scriptencoding utf-8

function set_lexima#main() abort
	packadd lexima.vim
	" 全てのファイルタイプに全角会話文括弧追加
	call lexima#add_rule({'char': '「', 'input_after': '」'})
	call lexima#add_rule({'char': '」', 'at': '\%#」', 'leave': 1})
	call lexima#add_rule({'char': '<BS>', 'at': '「\%#」', 'delete': 1})
	call lexima#add_rule({'char': '『', 'input_after': '』'})
	call lexima#add_rule({'char': '』', 'at': '\%#』', 'leave': 1})
	call lexima#add_rule({'char': '<BS>', 'at': '『\%#』', 'delete': 1})
	" TeX
	call lexima#add_rule({'char': '$', 'input_after': '$', 'filetype': 'tex'})
	call lexima#add_rule({'char': '$', 'at': '\%#\$', 'leave': 1, 'filetype': 'tex'})
	call lexima#add_rule({'char': '$', 'at': '\\\%#', 'input': '$', 'filetype': 'tex'})
	call lexima#add_rule({'char': '<BS>', 'at': '\$\%#\$', 'delete': 1, 'filetype': 'tex'})
	" HTML
	call lexima#add_rule({'char': '<', 'input_after': '>', 'filetype': [ 'html', 'text' ]})
	call lexima#add_rule({'char': '>', 'at': '\%#>', 'leave': 1, 'filetype': [ 'html', 'text' ]})
	call lexima#add_rule({'char': '<BS>', 'at': '<\%#>', 'delete': 1, 'filetype': [ 'html', 'text' ]})
	" C, C++, CSS コメント
	call lexima#add_rule({'char': '*', 'at': '/\%#','input': '* ','input_after': ' */', 'filetype': [ 'c', 'cpp', 'css' ]})
	call lexima#add_rule({'char': '*', 'at': '\\/\%#', 'input': '*', 'filetype': [ 'c', 'cpp', 'css' ]})
	" call lexima#add_rule({'char': '/', 'at': '\*\%#', 'leave': 1, 'filetype': [ 'c', 'cpp', 'css' ]})
	" call lexima#add_rule({'char': '/', 'at': '\\*\%#', 'input': '/', 'filetype': [ 'c', 'cpp', 'css' ]})
	call lexima#add_rule({'char': '<BS>', 'at': '\/\*[ \t]*\%#[ \t]*\*\/', 'input': '<BS><BS><BS>', 'delete': 3, 'filetype': [ 'c', 'cpp', 'css' ]})
endfunction
