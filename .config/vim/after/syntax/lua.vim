" add fold
syn region luaFunctionBlock transparent matchgroup=luaFunction start="\<function\>" end="\<end\>" contains=TOP fold
syn region luaCondEnd contained transparent matchgroup=luaCond start="\<then\>" end="\<end\>" contains=TOP fold
syn region luaBlock transparent matchgroup=luaStatement start="\<do\>" end="\<end\>" contains=TOP fold
syn region luaRepeatBlock transparent matchgroup=luaRepeat start="\<repeat\>" end="\<until\>" contains=TOP fold
if lua_version == 5 && lua_subversion == 0
  syn region luaComment        matchgroup=luaCommentDelimiter start="--\[\[" end="\]\]" contains=luaTodo,luaInnerComment,@Spell fold
  syn region luaInnerComment   contained transparent start="\[\[" end="\]\]" fold
elseif lua_version > 5 || (lua_version == 5 && lua_subversion >= 1)
  syn region luaComment        matchgroup=luaCommentDelimiter start="--\[\z(=*\)\[" end="\]\z1\]" contains=luaTodo,@Spell fold
endif
if lua_version == 5
  if lua_subversion == 0
    syn region luaString2 matchgroup=luaStringDelimiter start=+\[\[+ end=+\]\]+ contains=luaString2,@Spell fold
  else
    syn region luaString2 matchgroup=luaStringDelimiter start="\[\z(=*\)\[" end="\]\z1\]" contains=@Spell fold
  endif
endif
syn region luaString matchgroup=luaStringDelimiter start=+'+ end=+'+ skip=+\\\\\|\\'+ contains=luaSpecial,@Spell fold
syn region luaString matchgroup=luaStringDelimiter start=+"+ end=+"+ skip=+\\\\\|\\"+ contains=luaSpecial,@Spell fold
syn region luaTableBlock transparent matchgroup=luaTable start="{" end="}" contains=TOP,luaStatement fold
