" Hidemaru macro syntax
if exists("b:current_syntax")
  finish
endif

let s:keepcpo= &cpo
set cpo&vim
syntax clear
syntax case match

" Function
syntax keyword HidemaruFunction	ascii browsefile browserpanehandle browserpanesize browserpaneurl byteindex_to_charindex char char_to_cmu char_to_gcu char_to_ucs4 char_to_wcs charcount charg charindex_to_byteindex cmu_to_char cmuleftstr cmulen cmumidstr cmurightstr cmustrrstr cmustrstr columntox decodeuri dllfunc dllfuncexist dllfuncstr dllfuncstrw dllfuncw encodeuri enumcolormarkerlayer enumregkey enumregvalue existfile filter findwindow findwindowclass findwindowg gcu_to_char gculeftstr gculen gcumidstr gcurightstr gcustrrstr gcustrstr getarg getautocompitem getclipboard getclipboardinfo getcolormarker getconfig getconfigcolor getconfigg getcurrenttabg getenv geteventnotify geteventparam getfilehist getfiletime getfocus getgrepfilehist getininum getininumw getinistr getinistrw getlinecount getlinetext getloaddllfile getmaxinfo getoutlineitem getpathhist getregbinary getregnum getregstr getreplacehist getresultex getsearchhist getselectedtext getstaticvariable gettabhandleg gettabstopg gettagsfile gettext gettext2 gettitle gettotaltext hex hidemaruhandle input inputchar inputg iskeydown join keypressedex leftstr linenotoy loaddll midstr quote renderpanecommand rightstr sendmessage split sprintf str strlen strreplace strrstr strstr ucs4_to_char ucs4leftstr ucs4len ucs4midstr ucs4rightstr ucs4strrstr ucs4strstr unichar val wcs_to_char wcsleftstr wcslen wcsmidstr wcsrightstr wcsstrrstr wcsstrstr xtocolumn ytolineno
" function duplicating statement or keyword
syntax match HidemaruFunction	/\<\(browserpanecommand\|getselectedrange\|setcompatiblemode\|seterrormode\|tolower\|toupper\|unicode\)\ze(/
" JavaScript
syntax keyword HidemaruFunction	clearInterval clearTimeout evalMacro getCurrentProcessInfo getCurrentWindowHandle getCursorPos getCursorPosFromMousePos getFileFullPath getFunctionId getInputStates getJsMode getLineText getPixelPosFromCursorPos getSelectedText getStaticVariable getTotalText getUpdateCount getVar hidemaruGlobal isMacroExecuting loadDll loadTextFile postExecMacroFile postExecMacroMemory runProcess saveTextFile setInterval setStaticVariable setTimeout setVar sendMessage
" DLL Function"
syntax match HidemaruDLLFunction	/"\zs\(GetCurrentDir\|GetMode\|GetProject\|GetUpdated\|GetWindowHandle\|LoadProject\|Output\|OutputW\|Pop\|Push\|SaveProject\|SetBaseDir\|SetMode\)\ze"/

" config keyword
syntax keyword HidemaruOption	backup bcolor boldstate ccolor configstate correctlineno currentconfigset fontcharset fontmode fontname fontsize freecursor hilightstate hilighttitle ignoreeof indentstate kinsokustate lcolor linenostate linespace pagestate rcolor rulerbackcolor rulercolor savewitheof showruler showtab tabcount tabruler tcolor width
" getconfig() or config x keyword
syntax match HidemaruConfigXOption	/\<x\(ActiveKakko\|ActiveTagPair\|Asp\|AspDefaultScript\|AutoAdjustOrikaeshi\|AutocompAuto\|AutocompDic\|AutocompFlag1\|AutocompFlag2\|Backup\|BackupFast\|Blockquote\|BlockquoteFix\|BoldFace\|BquoteInclude\|BquoteItemized\|CharSpace\|ClistFont\|ClistFontSize\|ColorComment\|ColorEmail\|ColorFN\|ColorIfdef\|ColorNum\|ColorUrl\|CorrectLineNo\|CurLineColor\|CurLineColorEx\|Dangumi\|FiletypeCharcode\|Folding\|FoldingTwigBar\|Font\|FontCharSet\|FontDecimal\|FontPoint\|FontSize\|FormLine\|FreeCursor\|GuideLine\|GuideLineInterval\|HideCR\|HideEOF\|Hilight\|HilightDirectIfdef\|HilightDirectMulti\|HilightDirectWord\|HilightList\|HilightTitle\|IgnoreEOF\|Ime\|ImeColorCurLine\|Indent\|JspComment\|Kinsoku\|LF\|LastColor\|Orikaeshi\|OrikaeshiLine\|Outline\|OutlineBar\|Php\|RangeEdit\|Ruler\|RulerBack\|RulerColor\|SaveConv\|SaveLastPos\|SaveWithEOF\|ShowBox\|ShowCR\|ShowEOF\|ShowLineNo\|ShowPageNo\|ShowTab\|StripTrail\|Stripe\|Tab\|TabMode\|TabRuler\|Tategaki\|UnderLine\|VertLine\|Xml\)\>/ contained
syntax match HidemaruConfigXOption	/"\zs\<\(ActiveKakko\|ActiveTagPair\|Asp\|AspDefaultScript\|AutoAdjustOrikaeshi\|AutocompAuto\|AutocompDic\|AutocompFlag1\|AutocompFlag2\|Backup\|BackupFast\|Blockquote\|BlockquoteFix\|BoldFace\|BquoteInclude\|BquoteItemized\|CharSpace\|ClistFont\|ClistFontSize\|ColorComment\|ColorEmail\|ColorFN\|ColorIfdef\|ColorNum\|ColorUrl\|CorrectLineNo\|CurLineColor\|CurLineColorEx\|Dangumi\|FiletypeCharcode\|Folding\|FoldingTwigBar\|Font\|FontCharSet\|FontDecimal\|FontPoint\|FontSize\|FormLine\|FreeCursor\|GuideLine\|GuideLineInterval\|HideCR\|HideEOF\|Hilight\|HilightDirectIfdef\|HilightDirectMulti\|HilightDirectWord\|HilightList\|HilightTitle\|IgnoreEOF\|Ime\|ImeColorCurLine\|Indent\|JspComment\|Kinsoku\|LF\|LastColor\|Orikaeshi\|OrikaeshiLine\|Outline\|OutlineBar\|Php\|RangeEdit\|Ruler\|RulerBack\|RulerColor\|SaveConv\|SaveLastPos\|SaveWithEOF\|ShowBox\|ShowCR\|ShowEOF\|ShowLineNo\|ShowPageNo\|ShowTab\|StripTrail\|Stripe\|Tab\|TabMode\|TabRuler\|Tategaki\|UnderLine\|VertLine\|Xml\)\ze"/ contained
" search, grepdialog, openfile, replace
syntax keyword HidemaruOption	arabic ask baltic big5 binary casesense default easteuro euc euckr euro filelist fullpath fuzzy gb2312 greek hebrew hilight icon incolormarker inselect inselect2 jis johab linknext loop maskcomment maskifdef masknormal maskonly maskscript maskstring masktag noaddhist nocasesense nohilight noregular oem outputsametab outputsingle preview regular russian sjis subdir symbol thai turkish unicode_be utf32 utf32_be utf7 utf8 vietnamese word
" search option duplicating function
syntax match HidemaruOption	/\<unicode[^(A-Za-z0-9_]/
syntax match HidemaruOption	/\<unicode$/

" Keyword
syntax keyword HidemaruKeyword	anyclipboard argcount autocompstate backupdir basename basename2 basename3 bom browsemode carettabmode charset code codepage colorcode column compatiblemode compfilehandle currentmacrobasename currentmacrodirectory currentmacrofilename cxscreen cxworkarea cyscreen cyworkarea darkmode date day dayofweek dayofweeknum diff directory directory2 directory3 encode event filename filename2 filename3 filetype findmarker foldable folded foundbuffer foundendx foundendy foundhilighting foundoption foundtopx foundtopy grepfilebuffer grepfolderbuffer hidemarucount hidemarudir hour imestate inputstates inselecting keypressed lastupdatedx lastupdatedy linecount linecount2 linelen linelen2 linelen_cmu linelen_gcu linelen_ucs4 linelen_wcs lineno lineselecting lineupdated loaddllfile macrodir marked minute monitor monitorcount month mousecolumn mouselineno mouseselecting multiselectcount multiselecting outlinehandle outlineitemcount outlinesize platform prevposx prevposy rangeeditend rangeeditmode rangeedittop readonly rectselecting refreshdatetime regulardll replacebuffer replay reservedmultisel result return_in_cell_mode screenleftx screentopy scrolllinkhandle searchbuffer searchmode searchoption searchoption2 second selecting selectionlock selendcolumn selendlineno selendx selendy selopenx selopeny seltopcolumn seltoplineno seltopx seltopy settingdir splitmode splitpos splitstate stophistory tabcolumn tabcolumnmax tabgroup tabgrouporder tabgrouptotal tabmode taborder tabtotal targetcolormarker tickcount time updatecount updated version windir windowcx windowcy windowheight windowposx windowposy windowstate windowstate2 windowwidth winsysdir x xpixel xpixel2 xview xworkarea y year ypixel ypixel2 yworkarea setoutlinesize
" keyword duplicating function
syntax match HidemaruKeyword	/\<unicode[^(A-Za-z0-9_]/
syntax match HidemaruKeyword	/\<unicode$/

" Command
syntax keyword HidemaruCommand	APPENDSAVE CHANGENAME COMPFILE Del EDITMENU FIND GREP INSERTFILE LOAD OPEN OPENFILEPART SAVEAS
syntax keyword HidemaruCommand	alwaystopswitch appendcopy appendcut appendsave autocomplete autospellcheckswitch backspace backtab backtagjump beginlinesel beginrect beginsel browsemodeswitch capslockforgot case casechange changename clearallmark clearcliphist clearcolormarkerallfound clearupdated clearupdates clist closenew colormarker colormarkerallfound colormarkerdialog colormarkersnapshot compfile copy copy2 copyline copyurl copyword cut cutline delete deleteafter deletebefore deletecolormarker deletecolormarkerall deletefilehist deleteline deleteline2 deleteword deletewordall deletewordfront directtagjump dupline endsel escape escapeinselect exit exitall find find2 finddown finddown2 findmarkerlist findup findup2 findword fold foldall forceinselect forwardtab foundlist foundlistoutline freecursorswitch getcliphist getsearch gofileend gofiletop gokakko golastupdated goleftkakko golineend golineend2 golineend3 golinetop golinetop2 gorightkakko goscreenend goscreentop gosearchstarted goupdatedown goupdateup gowordend gowordend2 gowordtop gowordtop2 grep grepdialog grepdialog2 grepreplace grepreplacedialog2 halfnextpage halfprevpage help help2 help3 hidemaruhelp hilightfound imeconvforgot imeregisterword imeswitch indent insert insertfile insertfix insertline insertreturn jump loadfile localgrep macrohelp marklist moveto moveto2 movetolineno movetoview msdnlibrary newfile nextcolormarker nextcompfile nextfoldable nextfunc nexthidemaru nexthidemaruicon nextmark nextoutlineitem nextpage nextresult nexttab openbyhidemaru openbyshell openfile openfilepart overwrite overwriteswitch paste pasterect poppaste poppaste2 prevcolormarker prevcompfile prevfoldable prevfunc prevhidemaru prevhidemaruicon prevmark prevoutlineitem prevpage prevpos prevresult prevtab print propertydialog quit quitall rangeeditin rangeeditout readonlyloadfile readonlyopenfile readonlyswitch redo redraw refcopy refcopy2 refpaste reopen replace replaceall replaceallfast replaceallquick replacedialog replacedown replaceup restoredesktop rolldown rolldown2 rollup rollup2 save saveall saveas savebacktagjump savedesktop saveexit saveexitall savelf saveupdatedall scrolllink searchdialog searchdown searchdown2 searchup searchup2 selectall selectallfound selectcfunc selectcolormarker selectcolumn selectfoldable selectinselect selectline selectword setencode setfilehist setgrepfile setinselect2 setmark setpathhist setreplace setreplacehist setsearch setsearchhist setsplitinfo settabgroup settabmode settaborder settargetcolormarker shifttab showcliphist showcode showfoldingbar showlineno showoutline showoutlinebar spellcheckdialog splitswitch stophistoryswitch switchcasesense switchregular switchword tagjump tohankaku tospace totab tozenkakuhira tozenkakukata undelete undo unfold unfoldall unindent windowcascade windowhorz windowlist windowtiling windowvert wordleft wordright wordrightsalnen
" command duplicating function
syntax match HidemaruCommand	/\<split[^(A-Za-z0-9_]/
syntax match HidemaruCommand	/\<split$/

" Statement
syntax keyword HidemaruStatement	addclipboard allowobjparam beep beginclipboardread begingroupundo beginrectmulti break call callmethod callmethod_ callmethod_returnnum callmethod_returnobj callmethod_returnstr clearkeyhook clearreservedmultisel clearreservedmultiselall closehidemaru closehidemaruforced closereg config configcolor configset continue convert_return_in_cell copyformed createobject createreg cutafter cutword dde ddeexecute ddeexecutew ddeinitiate ddeinitiatew ddepoke ddepokew dderequest dderequestw ddestartadvice ddestartadvicew ddestopadvice ddestopadvicew ddeterminate ddewaitadvice ddewaitadvicew debuginfo deletefile deletereg disablebreak disabledraw disabledraw2 disableerrormsg disablehistory disableinvert down down_nowrap enabledraw enableerrormsg enableinvert endgroupundo endmacro endmacro_postcommand endmacroall envchanged eval execjs execmacro findhidemaru findspecial freedll fullscreen getcollection getobject getpropnum getpropobj getpropstr gotagpair goto hidemaruorder hidemaruversion iconall iconthistab if inputpos invertselection jsmode keepdde keepdll keepobject keyhook left loadbookmark loadhilight loadkeyassign member menu menuarray message mousemenu mousemenuarray openreg play playsync prevposhistback prevposhistforward question refcall refreshbrowserpane refreshoutline registercallback releaseobject renderpanecommand reservemultisel return right run runex runsync runsync2 savebookmark saveconfig savehilight savekeyassign selectreservedmultisel selectword2 setactivehidemaru setbackgroundmode setbrowserpanesize setbrowserpanetarget setbrowserpaneurl setclipboard setcomdetachmethod setconfigstate setdlldetachfunc seteventnotify setfiletype setfloatmode setfocus setfontchangemode setmenudelay setmonitor setpropnum setpropobj setpropstr setregularcache setrenderpanetarget setselectionrange setstaticvariable settabstop setwindowpos setwindowsize shiftdown shiftleft shiftright shiftup showbrowserpane showvars showwindow sleep syncoutline title tomultiselect up up_nowrap while wordleft2 wordright2 wordrightsalnen2 writeininum writeininumw writeinistr writeinistrw writeregbinary writeregnum writeregstr
" command duplicating function
syntax match HidemaruCommand	/\<\(browserpanecommand\|getselectedrange\|setcompatiblemode\|seterrormode\|tolower\|toupper\)[^(A-Za-z0-9_]/
syntax match HidemaruCommand	/\<\(browserpanecommand\|getselectedrange\|setcompatiblemode\|seterrormode\|tolower\|toupper\)$/

" String
syntax region	HidemaruString	start=+"+ skip=+\\\\\|\\"+ end=+"+ oneline contains=@Spell,HidemaruConfigXOption

" Character
syntax region	HidemaruCharacter	start=+'+ skip=+\\\\\|\\'+ end=+'+ oneline

" Variable
syntax match	HidemaruVariable /\(##\|#\|\$\$\|\$\)\w\+/

" Operator
syntax match	HidemaruOperator	"\([=!<>]=\?\|[?:+-/%^*&]\)"

" Number
syntax match	HidemaruNumber	/[-+]\?\<\d\+\>\.\?/                " 整数
syntax match	HidemaruNumber	/[-+]\?\<\d\+\.\d\+\>/              " 小数
syntax match	HidemaruNumber	/[-+]\?\<\d\+\.\d\+[eE][+-]\d\+\>/  " 浮動小数点数
syntax match	HidemaruFloat	/\<0x[0-9A-Za-z]\+\>/               " 浮動小数点数

" Boolean
syntax keyword HidemaruBoolean	false true

" Constant
syntax keyword HidemaruConstant	eof no yes

" Comment
syntax region	HidemaruComment	start="//" end="$" keepend contains=@Spell

highlight default link HidemaruFunction	Function
highlight default link HidemaruDLLFunction	Function
highlight default link HidemaruOption	PreProc
highlight default link HidemaruConfigXOption	PreProc
highlight default link HidemaruKeyword	Statement
highlight default link HidemaruCommand	Statement
highlight default link HidemaruStatement	Statement
highlight default link HidemaruComment	Comment
highlight default link HidemaruString	String
highlight default link HidemaruCharacter	Character
highlight default link HidemaruVariable	Identifier
highlight default link HidemaruOperator	Operator
highlight default link HidemaruNumber	Number
highlight default link HidemaruFloat	Float
highlight default link HidemaruConstant	Constant

let b:current_syntax = "hidemaru"
let &cpo = s:keepcpo
unlet s:keepcpo
