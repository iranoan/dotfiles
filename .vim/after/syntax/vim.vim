scriptencoding utf-8
" syntax の追加
if exists('b:current_syntax_user')
	finish
endif
let b:current_syntax_user = 1
let b:undo_ftplugin = 'unlet b:current_syntax_user'

" syntax keyword vimCommand py3file
syntax match vimOper /\%#=1\(==\|!=\|>=\|<=\|=\~\|!\~\|>\|<\|=\)[?#]\{0,2}/  nextgroup=vimString,vimSpecFile skipwhite
syntax case ignore
syntax match vimNotation /\%#=1\(\\\|<lt>\)\=<\([scamd]-\)\{0,4}x\=\(f\d\{1,2}\|[^ \t:]\|cr\|enter\|lf\|linefeed\|return\|k\=del\%[ete]\|bs\|backspace\|tab\|esc\|right\|left\|help\|undo\|insert\|ins\|mouse\|k\=home\|k\=end\|kplus\|kminus\|kdivide\|kmultiply\|k\=enter\|kpoint\|space\|k\=\(page\)\=\(\|down\|up\|k\d\>\)\)>/  contains=vimBracket
