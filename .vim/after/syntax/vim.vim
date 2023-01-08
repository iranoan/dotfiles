scriptencoding utf-8
" syntax の追加
if exists('b:current_syntax_user')
	finish
endif
let b:current_syntax_user = 1
let b:undo_ftplugin = 'unlet b:current_syntax_user'

" syntax clear
syntax match vimOper /\%#=1\%(==\|!=\|>=\|<=\|=\~\|!\~\|>\|<\|=\)[?#]\{0,2}/  nextgroup=vimString,vimSpecFile skipwhite
syntax case ignore
syntax match vimNotation /\%#=1\%(\\\|<lt>\)\=<\%([scamd]-\)\{0,4}x\=\%(f\d\{1,2}\|[^ \t:]\|cr\|enter\|lf\|linefeed\|return\|k\=del\%[ete]\|bs\|backspace\|tab\|esc\|right\|left\|help\|undo\|insert\|ins\|mouse\|k\=home\|k\=end\|kplus\|kminus\|kdivide\|kmultiply\|k\=enter\|kpoint\|space\|k\=\%(page\)\=\%(\|down\|up\|k\d\>\)\)>/  contains=vimBracket

if exists("g:vimsyn_folding")
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
	" syntax region VimFoldMarker start='{{{' end='}}}' end='^$' fold transparent keepend contains=@vimCommentGroup,vim9Comment,vim9LineComment,vimComment,vimCommentString,vimCommentTitle,vimCommentTitleLeader,vimLineComment,vimMtchComment
	" " syn cluster vimComment	contains=VimFoldMarker
	" syn cluster vim9Comment	contains=VimFoldMarker
	" source $HOME/src/vim/runtime/syntax/vim.vim
	syntax region VimIfForWhileTry start='\<if\>' end='\<en\%[dif]\>' end='\n\ze\s*\%(el\%[se]\|elseif\=\)\>' fold transparent keepend
	syntax region VimIfForWhileTry start='\<\%(el\%[se]\|elseif\=\)\>' end='\<en\%[dif]\>' end='\n\ze\s*\%(el\%[se]\|elseif\=\)\>' fold transparent keepend
	syntax region VimIfForWhileTry start='\<for\>' end='\<endfor\=\>' fold transparent keepend
	syntax region VimIfForWhileTry start='\<wh\%[ile]\>' end='\<endw\%[hile]\>' fold transparent keepend
	syntax region VimIfForWhileTry start='\<try\>' end='\<endt\%[ry]\>' end='\n\ze\s*\%(cat\%[ch]\|fina\%[lly]\|th\%[row]\)\>' fold transparent keepend
	syntax region VimIfForWhileTry start='\<\%(cat\%[ch]\|fina\%[lly]\|th\%[row]\)\>' end='\<endt\%[ry]\>' end='\n\ze\s*\%(cat\%[ch]\|fina\%[lly]\|th\%[row]\)\>' fold transparent keepend
	syn cluster vimAugroupList	contains=vimAugroup,vimIsCommand,vimUserCmd,vimExecute,vimNotFunc,vimFuncName,vimFunction,vimFunctionError,vimLineComment,vimNotFunc,vimMap,vimSpecFile,vimOper,vimNumber,vimOperParen,vimComment,vim9Comment,vimString,vimSubst,vimMark,vimRegister,vimAddress,vimFilter,vimCmplxRepeat,vimComment,vim9Comment,vimLet,vimSet,vimAutoCmd,vimRegion,vimSynLine,vimNotation,vimCtrlChar,vimFuncVar,vimContinue,vimSetEqual,vimOption,VimIfForWhileTry
	syn cluster	vimFuncBodyList	contains=vimAbb,vimAddress,vimAugroupKey,vimAutoCmd,vimCmplxRepeat,vimComment,vim9Comment,vimContinue,vimCtrlChar,vimEcho,vimEchoHL,vimEnvvar,vimExecute,vimIsCommand,vimFBVar,vimFunc,vimFunction,vimFuncVar,vimGlobal,vimHighlight,vimIsCommand,vimLet,vimLetHereDoc,vimLineComment,vimMap,vimMark,vimNorm,vimNotation,vimNotFunc,vimNumber,vimOper,vimOperParen,vimRegion,vimRegister,vimSearch,vimSet,vimSpecFile,vimString,vimSubst,vimSynLine,vimUnmap,vimUserCommand,VimIfForWhileTry

	" bug fix
	syntax clear vimFunction
	syntax match	vimFunction	'\<\%(fu\%[nction]\)!\=\s\+\%(<[sS][iI][dD]>\|[sSgGbBwWtTlL]:\)\=\%(\i\|[#.]\|{.\{-1,}}\)*\ze\s*('	contains=@vimFuncList nextgroup=vimFuncBody
	syntax match	vimFunction	'\<def!\=\s\+\%(\i\|[#.]\|{.\{-1,}}\)*\ze\s*(' contains=@vimFuncList nextgroup=vimFuncBody
endif
