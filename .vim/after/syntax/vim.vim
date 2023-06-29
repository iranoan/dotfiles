scriptencoding utf-8
" syntax の追加
" fix https://github.com/vim-jp/issues/issues/1418
if exists('b:current_syntax_user')
	finish
endif
let b:current_syntax_user = 1
let b:undo_ftplugin = 'unlet b:current_syntax_user'

syntax match vimOper /\%#=1\%(==\|!=\|>=\|<=\|=\~\|!\~\|>\|<\|=\)[?#]\{0,2}/  nextgroup=vimString,vimSpecFile skipwhite
syntax case ignore
syntax match vimNotation /\%#=1\%(\\\|<lt>\)\=<\%([scamd]-\)\{0,4}x\=\%(f\d\{1,2}\|[^ \t:]\|cr\|enter\|lf\|linefeed\|return\|k\=del\%[ete]\|bs\|backspace\|tab\|esc\|right\|left\|help\|undo\|insert\|ins\|mouse\|k\=home\|k\=end\|kplus\|kminus\|kdivide\|kmultiply\|k\=enter\|kpoint\|space\|k\=\%(page\)\=\%(\|down\|up\|k\d\>\)\)>/  contains=vimBracket

if exists("g:vimsyn_folding")
	" foldmarker
	syntax region VimFoldMarker start='["#].*{{{' end='\n\ze["#].*{{{\d\+' end='["#].*}}}' end='^$' fold transparent keepend
	syntax region VimFoldMarker start='["#].*{{{9\>' end='\n\ze["#].*{{{[1-9]\>' end='["#].*\<9}}}' end='^$' fold transparent keepend
	syntax region VimFoldMarker start='["#].*{{{8\>' end='\n\ze["#].*{{{[1-8]\>' end='["#].*\<8}}}' end='^$' fold transparent keepend
	syntax region VimFoldMarker start='["#].*{{{7\>' end='\n\ze["#].*{{{[1-7]\>' end='["#].*\<7}}}' end='^$' fold transparent keepend
	syntax region VimFoldMarker start='["#].*{{{6\>' end='\n\ze["#].*{{{[1-6]\>' end='["#].*\<6}}}' end='^$' fold transparent keepend
	syntax region VimFoldMarker start='["#].*{{{5\>' end='\n\ze["#].*{{{[1-5]\>' end='["#].*\<5}}}' end='^$' fold transparent keepend
	syntax region VimFoldMarker start='["#].*{{{4\>' end='\n\ze["#].*{{{[1-4]\>' end='["#].*\<4}}}' end='^$' fold transparent keepend
	syntax region VimFoldMarker start='["#].*{{{3\>' end='\n\ze["#].*{{{[1-3]\>' end='["#].*\<3}}}' end='^$' fold transparent keepend
	syntax region VimFoldMarker start='["#].*{{{2\>' end='\n\ze["#].*{{{[12]\>' end='["#].*\<2}}}' end='^$' fold transparent keepend
	syntax region VimFoldMarker start='["#].*{{{1\>' end='\n\ze["#].*{{{1\>' end='["#].*\<1}}}' end='^$' fold transparent keepend
	" if, for, while, try
	syntax region VimIfForWhileTry start='\<if\>' end='\<en\%[dif]\>' end='\n\ze\s*\%(el\%[se]\|elseif\=\)\>' fold transparent keepend
	syntax region VimIfForWhileTry start='\<\%(el\%[se]\|elseif\=\)\>' end='\<en\%[dif]\>' end='\n\ze\s*\%(el\%[se]\|elseif\=\)\>' fold transparent keepend
	syntax region VimIfForWhileTry start='\<for\>' end='\<endfor\=\>' fold transparent keepend
	syntax region VimIfForWhileTry start='\<wh\%[ile]\>' end='\<endw\%[hile]\>' fold transparent keepend
	syntax region VimIfForWhileTry start='\<try\>' end='\<endt\%[ry]\>' end='\n\ze\s*\%(cat\%[ch]\|fina\%[lly]\|th\%[row]\)\>' fold transparent keepend
	syntax region VimIfForWhileTry start='\<\%(cat\%[ch]\|fina\%[lly]\|th\%[row]\)\>' end='\<endt\%[ry]\>' end='\n\ze\s*\%(cat\%[ch]\|fina\%[lly]\|th\%[row]\)\>' fold transparent keepend
	syntax cluster vimAugroupList	add=VimIfForWhileTry
	syntax cluster vimFuncBodyList	add=VimIfForWhileTry
	syntax cluster vimFuncBodyList	add=VimIfForWhileTry
	"
	" syntax cluster	VimIfForWhileTryBodyList contains=vim9Comment,vimAbb,vimAddress,vimAugroupKey,vimAutoCmd,vimCmplxRepeat,vimComment,vimContinue,vimCtrlChar,vimEcho,vimEchoHL,vimEnvvar,vimExecute,vimFBVar,vimFunc,vimFunction,vimFuncVar,vimGlobal,vimGroupAdd,vimGroupRem,vimHighlight,vimHiLink,vimIsCommand,vimLet,vimLetHereDoc,vimLineComment,vimLuaRegion,vimMap,vimMark,vimMzSchemeRegion,vimNorm,vimNotation,vimNotFunc,vimNumber,vimOper,vimOperParen,vimPerlRegion,vimPythonRegion,vimRegion,vimRegister,vimRubyRegion,vimSearch,vimSet,vimSpecFile,vimString,vimSubst,vimSynLine,vimSynMtchGroup,vimSyntax,vimSynType,vimTclRegion,vimUnmap,vimUserCommand,VimIfForWhileTry
	" syntax cluster VimIfForWhileTryList contains=vimCommand
	" syntax match VimIfForWhileTry '\<\%(if\|el\%[se]\|elseif\=\)\>'                 contains=@VimIfForWhileTryList nextgroup=VimIfBody
	" syntax match VimIfForWhileTry '\<for\>'                                         contains=@VimIfForWhileTryList nextgroup=VimForBody
	" syntax match VimIfForWhileTry '\<wh\%[ile]\>'                                   contains=@VimIfForWhileTryList nextgroup=VimWhileBody
	" syntax match VimIfForWhileTry '\<\%(try\|cat\%[ch]\|fina\%[lly]\|th\%[row]\)\>' contains=@VimIfForWhileTryList nextgroup=VimTryBody
	" syntax region VimIfBody    contained fold start="\s"me=s start='$' matchgroup=vimCommand contains=@VimIfForWhileTryBodyList end='\<en\%[dif]\>' end='\n\s*\%(el\%[se]\|elseif\=\)\>'me=s
	" syntax region VimForBody   contained fold start="\s"me=s start='$' matchgroup=vimCommand contains=@VimIfForWhileTryBodyList end='\<endfor\=\>'
	" syntax region VimWhileBody contained fold start="\s"me=s start='$' matchgroup=vimCommand contains=@VimIfForWhileTryBodyList end='\<endw\%[hile]\>'
	" syntax region VimTryBody   contained fold start="\s"me=s start='$' matchgroup=vimCommand contains=@VimIfForWhileTryBodyList end='\<endt\%[ry]\>' end='\<\%(cat\%[ch]\|fina\%[lly]\|th\%[row]\)\>'me=s
	" syn cluster vimAugroupList	add=@VimIfForWhileTryBodyList
	" syn cluster	vimFuncBodyList	add=@VimIfForWhileTryBodyList
	" syn cluster	vimUserCmdList	add=@VimIfForWhileTryBodyList
	" (), {}, []
	syn region vimOperParen matchgroup=vimParenSep start="(" end=")"    contains=vimoperStar,@vimOperGroup fold contains=vimOperParen
	syn region vimOperParen matchgroup=vimSep      start="#\={" end="}" contains=@vimOperGroup nextgroup=vimVar,vimFuncVar fold contains=vimOperParen
	syn region vimOperParen                        start="\[" end="\]"  contains=@vimOperGroup nextgroup=vimVar,vimFuncVar fold contains=vimOperParen

	" bug fix
	syntax clear vimFunction
	syntax match	vimFunction	'\<\%(fu\%[nction]\)!\=\s\+\%(<[sS][iI][dD]>\|[sSgGbBwWtTlL]:\)\=\%(\i\|[#.]\|{.\{-1,}}\)*\ze\s*('	contains=@vimFuncList nextgroup=vimFuncBody
	syntax match	vimFunction	'\<def!\=\s\+\%(\i\|[#.]\|{.\{-1,}}\)*\ze\s*(' contains=@vimFuncList nextgroup=vimFuncBody
endif
" fix https://github.com/vim-jp/issues/issues/1418
syn region	vimString	oneline keepend	start=+[^a-zA-Z>!\\@]"+lc=1 skip=+\\\\\|\\"+ matchgroup=vimStringEnd end=+"+	contains=@vimStringGroup
syn region	vimString	oneline keepend	start=+[^a-zA-Z>!\\@]'+lc=1 end=+'+
