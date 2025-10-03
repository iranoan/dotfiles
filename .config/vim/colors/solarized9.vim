vim9script
scriptencoding utf-8

# hi clear
g:colors_name = 'solarized9'

g:terminal_ansi_colors = [
	'#073642', '#dc322f', '#859900', '#b58900', '#268bd2', '#d33682', '#2aa198', '#eee8d5',
	'#002b36', '#cb4b16', '#586e75', '#657b83', '#839496', '#6c71c4', '#93a1a1', '#fdf6e3'
]

if &background ==# 'dark'
	if has('gui_running')
		hi Normal term=NONE cterm=NONE gui=NONE ctermfg=7 guifg=#eee8d5 ctermbg=8 guibg=#002b36 ctermul=NONE guisp=NONE
	else
		if !&termguicolors
			set t_Co=16
		endif
		if get(get(g:, 'solarized9_set', {}), 'transparent', v:true)
			hi Normal term=NONE cterm=NONE gui=NONE ctermfg=7 guifg=#eee8d5 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
		else
			hi Normal term=NONE cterm=NONE gui=NONE ctermfg=7 guifg=#eee8d5 ctermbg=8 guibg=#002b36 ctermul=NONE guisp=NONE
		endif
	endif
	hi ColorColumn term=reverse cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi Cursor term=NONE cterm=NONE gui=NONE ctermfg=8 guifg=#002b36 ctermbg=12 guibg=#839496 ctermul=NONE guisp=NONE
	hi CursorColumn term=reverse cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi CursorLine term=NONE cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi DiffAdd term=underline,reverse cterm=NONE gui=NONE ctermfg=2 guifg=#859900 ctermbg=0 guibg=#073642 ctermul=2 guisp=#859900
	hi DiffChange term=underline,reverse cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=0 guibg=#073642 ctermul=3 guisp=#b58900
	hi DiffDelete term=underline,reverse cterm=bold gui=bold ctermfg=1 guifg=#dc322f ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi DiffText term=bold,underline,reverse cterm=NONE gui=bold ctermfg=4 guifg=#268bd2 ctermbg=0 guibg=#073642 ctermul=4 guisp=#268bd2
	hi FoldColumn term=reverse cterm=NONE gui=NONE ctermfg=12 guifg=#839496 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi Folded term=bold cterm=bold gui=bold ctermfg=12 guifg=#839496 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi LineNr term=reverse cterm=NONE gui=NONE ctermfg=11 guifg=#657b83 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi NonText term=bold cterm=bold gui=bold ctermfg=11 guifg=#657b83 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
	hi Pmenu term=NONE cterm=NONE gui=NONE ctermfg=14 guifg=#93a1a1 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi PmenuSbar term=reverse cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=10 guibg=#586e75 ctermul=NONE guisp=NONE
	hi PmenuSel term=NONE cterm=NONE gui=NONE ctermfg=7 guifg=#eee8d5 ctermbg=8 guibg=#002b36 ctermul=NONE guisp=NONE
	hi PmenuThumb term=reverse cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=12 guibg=#839496 ctermul=NONE guisp=NONE
	hi SignColumn term=reverse cterm=NONE gui=NONE ctermfg=12 guifg=#839496 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi SpecialKey term=bold cterm=bold gui=bold ctermfg=11 guifg=#657b83 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi StatusLine term=bold,reverse cterm=bold,reverse gui=bold,reverse ctermfg=12 guifg=#839496 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi StatusLineNC term=reverse cterm=reverse gui=reverse ctermfg=10 guifg=#586e75 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi TabLine term=underline cterm=underline gui=underline ctermfg=12 guifg=#839496 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi TabLineSel term=underline,bold cterm=underline,bold gui=underline,bold ctermfg=7 guifg=#eee8d5 ctermbg=8 guibg=#002b36 ctermul=NONE guisp=NONE
	hi ToolbarButton term=bold,reverse cterm=bold gui=bold ctermfg=14 guifg=#93a1a1 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi ToolbarLine term=reverse cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi VertSplit term=NONE cterm=NONE gui=NONE ctermfg=11 guifg=#657b83 ctermbg=11 guibg=#657b83 ctermul=NONE guisp=NONE
	hi Visual term=reverse cterm=reverse gui=reverse ctermfg=10 guifg=#586e75 ctermbg=8 guibg=#002b36 ctermul=NONE guisp=NONE
	hi VisualNOS term=reverse cterm=reverse gui=reverse ctermfg=NONE guifg=NONE ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi WildMenu term=bold cterm=reverse gui=reverse ctermfg=7 guifg=#eee8d5 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi ALEErrorSign term=NONE cterm=bold gui=bold ctermfg=1 guifg=#dc322f ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi ALEErrorSignLineNr term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=1 guibg=#dc322f ctermul=NONE guisp=NONE
	hi ALEInfoSign term=NONE cterm=bold gui=bold ctermfg=6 guifg=#2aa198 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi ALEInfoSignLineNr term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=6 guibg=#2aa198 ctermul=NONE guisp=NONE
	hi ALEWarningSign term=NONE cterm=bold gui=bold ctermfg=3 guifg=#b58900 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi ALEWarningSignLineNr term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=3 guibg=#b58900 ctermul=NONE guisp=NONE
	hi GitGutterAddInvisible term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi GitGutterChangeInvisible term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi GitGutterDeleteInvisible term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi GlyphPalette0 term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
	hi GlyphPalette15 term=NONE cterm=NONE gui=NONE ctermfg=15 guifg=#fdf6e3 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
	hi GlyphPalette7 term=NONE cterm=NONE gui=NONE ctermfg=7 guifg=#eee8d5 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
	hi GlyphPalette8 term=NONE cterm=NONE gui=NONE ctermfg=8 guifg=#002b36 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
	hi pandocTableZebraDark term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
	hi pandocTableZebraLight term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=8 guibg=#002b36 ctermul=NONE guisp=NONE
	hi SignatureMarkText term=bold cterm=bold gui=bold ctermfg=15 guifg=#dddddd ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
else # light
	if has('gui_running')
		hi Normal term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
	else
		if !&termguicolors
			set t_Co=16
		endif
		if get(get(g:, 'solarized9_set', {}), 'transparent', v:true)
			hi Normal term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
		else
			hi Normal term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
		endif
	endif
	hi ColorColumn term=reverse cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi Cursor term=NONE cterm=NONE gui=NONE ctermfg=15 guifg=#fdf6e3 ctermbg=11 guibg=#657b83 ctermul=NONE guisp=NONE
	hi CursorColumn term=reverse cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=7 guibg=#F5F2DC ctermul=NONE guisp=NONE
	hi CursorLine term=NONE cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi DiffAdd term=underline,reverse cterm=NONE gui=NONE ctermfg=2 guifg=#859900 ctermbg=7 guibg=#eee8d5 ctermul=2 guisp=#859900
	hi DiffChange term=underline,reverse cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=7 guibg=#eee8d5 ctermul=3 guisp=#b58900
	hi DiffDelete term=underline,reverse cterm=bold gui=bold ctermfg=1 guifg=#dc322f ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi DiffText term=bold,underline,reverse cterm=NONE gui=bold ctermfg=4 guifg=#268bd2 ctermbg=7 guibg=#eee8d5 ctermul=4 guisp=#268bd2
	hi FoldColumn term=reverse cterm=NONE gui=NONE ctermfg=11 guifg=#657b83 ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi Folded term=underline,reverse cterm=bold gui=bold ctermfg=11 guifg=#657b83 ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi LineNr term=reverse cterm=NONE gui=NONE ctermfg=12 guifg=#839496 ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi NonText term=bold cterm=bold gui=bold ctermfg=12 guifg=#839496 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
	hi Pmenu term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi PmenuSbar term=reverse cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=14 guibg=#93a1a1 ctermul=NONE guisp=NONE
	hi PmenuSel term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
	hi PmenuThumb term=reverse cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=11 guibg=#657b83 ctermul=NONE guisp=NONE
	hi SignColumn term=reverse cterm=NONE gui=NONE ctermfg=11 guifg=#657b83 ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi SpecialKey term=bold cterm=bold gui=bold ctermfg=12 guifg=#839496 ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi StatusLine term=bold,reverse cterm=bold,reverse gui=bold,reverse ctermfg=10 guifg=#586e75 ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi StatusLineNC term=reverse cterm=reverse gui=reverse ctermfg=12 guifg=#839496 ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi TabLine term=underline cterm=underline gui=underline ctermfg=11 guifg=#657b83 ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi TabLineSel term=underline,bold cterm=underline,bold gui=underline,bold ctermfg=0 guifg=#073642 ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
	hi ToolbarButton term=bold,reverse cterm=bold gui=bold ctermfg=14 guifg=#93a1a1 ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
	hi ToolbarLine term=reverse cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
	hi VertSplit term=NONE cterm=NONE gui=NONE ctermfg=14 guifg=#93a1a1 ctermbg=14 guibg=#93a1a1 ctermul=NONE guisp=NONE
	hi Visual term=reverse cterm=reverse gui=reverse ctermfg=14 guifg=#93a1a1 ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
	hi VisualNOS term=reverse cterm=reverse gui=reverse ctermfg=NONE guifg=NONE ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi WildMenu term=reverse cterm=reverse gui=reverse ctermfg=0 guifg=#073642 ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi ALEErrorSign term=NONE cterm=bold gui=bold ctermfg=1 guifg=#dc322f ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
	hi ALEErrorSignLineNr term=NONE cterm=NONE gui=NONE ctermfg=15 guifg=#fdf6e3 ctermbg=1 guibg=#dc322f ctermul=NONE guisp=NONE
	hi ALEInfoSign term=NONE cterm=bold gui=bold ctermfg=6 guifg=#2aa198 ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
	hi ALEInfoSignLineNr term=NONE cterm=NONE gui=NONE ctermfg=15 guifg=#fdf6e3 ctermbg=6 guibg=#2aa198 ctermul=NONE guisp=NONE
	hi ALEWarningSign term=NONE cterm=bold gui=bold ctermfg=3 guifg=#b58900 ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
	hi ALEWarningSignLineNr term=NONE cterm=NONE gui=NONE ctermfg=15 guifg=#fdf6e3 ctermbg=3 guibg=#b58900 ctermul=NONE guisp=NONE
	hi GitGutterAddInvisible term=NONE cterm=NONE gui=NONE ctermfg=15 guifg=#fdf6e3 ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
	hi GitGutterChangeInvisible term=NONE cterm=NONE gui=NONE ctermfg=15 guifg=#fdf6e3 ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
	hi GitGutterDeleteInvisible term=NONE cterm=NONE gui=NONE ctermfg=15 guifg=#fdf6e3 ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
	hi GlyphPalette0 term=NONE cterm=NONE gui=NONE ctermfg=15 guifg=#fdf6e3 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
	hi GlyphPalette15 term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
	hi GlyphPalette7 term=NONE cterm=NONE gui=NONE ctermfg=8 guifg=#002b36 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
	hi GlyphPalette8 term=NONE cterm=NONE gui=NONE ctermfg=7 guifg=#eee8d5 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
	hi pandocTableZebraDark term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
	hi pandocTableZebraLight term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
	hi SignatureMarkText term=bold cterm=bold gui=bold ctermfg=0 guifg=#dddddd ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
endif
# common {{{
hi Added term=bold cterm=NONE gui=NONE ctermfg=2 guifg=#859900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Bold term=bold cterm=bold gui=bold ctermul=NONE guisp=NONE
hi BoldItalic term=bold,italic cterm=bold,italic gui=bold,italic ctermul=NONE guisp=NONE
hi Changed term=bold cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Comment term=NONE cterm=NONE gui=NONE ctermfg=14 guifg=#93a1a1 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi ComplMatchIns term=NONE cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Conceal term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Constant term=bold cterm=NONE gui=NONE ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi CursorIM term=NONE cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi CursorLineNr term=NONE cterm=bold gui=bold ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Directory term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Error term=bold cterm=reverse,bold gui=reverse,bold ctermfg=1 guifg=#dc322f ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
hi ErrorMsg term=reverse,bold cterm=reverse gui=reverse ctermfg=1 guifg=#dc322f ctermbg=7 guibg=#eee8d5 ctermul=NONE guisp=NONE
hi Identifier term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Ignore term=NONE cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi IncSearch term=standout cterm=standout gui=standout ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Italic term=italic cterm=italic gui=italic ctermul=NONE guisp=NONE
hi lCursor term=NONE cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=fg guibg=fg ctermul=NONE guisp=NONE
hi MatchParen term=reverse,bold cterm=reverse,bold gui=reverse,bold ctermfg=NONE guifg=NONE ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi ModeMsg term=NONE cterm=NONE gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi MoreMsg term=NONE cterm=NONE gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi MsgArea term=NONE cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi PreProc term=NONE cterm=NONE gui=NONE ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Question term=bold cterm=bold gui=bold ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Removed term=reverse,strikethrough cterm=NONE gui=NONE ctermfg=1 guifg=#dc322f ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Search term=reverse cterm=reverse gui=reverse ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Special term=bold cterm=NONE gui=NONE ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi SpellBad term=underline,italic cterm=underline,italic gui=undercurl ctermfg=NONE guifg=NONE ctermbg=NONE guibg=NONE ctermul=9 guisp=#cb4b16
hi SpellCap term=underline,italic cterm=underline,italic gui=undercurl ctermfg=NONE guifg=NONE ctermbg=NONE guibg=NONE ctermul=13 guisp=#6c71c4
hi SpellLocal term=underline,italic cterm=underline,italic gui=undercurl ctermfg=NONE guifg=NONE ctermbg=NONE guibg=NONE ctermul=3 guisp=#b58900
hi SpellRare term=underline,italic cterm=underline,italic gui=undercurl ctermfg=NONE guifg=NONE ctermbg=NONE guibg=NONE ctermul=6 guisp=#2aa198
hi Statement term=NONE cterm=NONE gui=NONE ctermfg=2 guifg=#859900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Title term=bold cterm=bold gui=bold ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Todo term=underline,bold cterm=bold gui=bold ctermfg=5 guifg=#d33682 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Type term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi Underlined term=underline cterm=underline gui=underline ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi WarningMsg term=bold cterm=bold gui=bold ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi ALEError term=underline cterm=underline gui=undercurl ctermfg=1 guifg=#dc322f ctermbg=NONE guibg=NONE ctermul=1 guisp=#dc322f
hi ALEInfo term=underline cterm=underline gui=undercurl ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=6 guisp=#2aa198
hi ALEWarning term=NONE cterm=underline gui=undercurl ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=3 guisp=#b58900
hi ConId term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi cPreCondit term=NONE cterm=NONE gui=NONE ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi gitcommitBranch term=NONE cterm=bold gui=bold ctermfg=5 guifg=#d33682 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi gitcommitComment term=NONE cterm=NONE gui=NONE ctermfg=10 guifg=#586e75 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi gitcommitDiscardedFile term=NONE cterm=bold gui=bold ctermfg=1 guifg=#dc322f ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi gitcommitdiscardedtype term=NONE cterm=NONE gui=NONE ctermfg=1 guifg=#dc322f ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi gitcommitFile term=NONE cterm=bold gui=bold ctermfg=12 guifg=#839496 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi gitcommitHeader term=NONE cterm=NONE gui=NONE ctermfg=10 guifg=#586e75 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi gitcommitOnBranch term=NONE cterm=bold gui=bold ctermfg=10 guifg=#586e75 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi gitcommitSelectedFile term=NONE cterm=bold gui=bold ctermfg=2 guifg=#859900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi gitcommitselectedtype term=NONE cterm=NONE gui=NONE ctermfg=2 guifg=#859900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi gitcommitUnmerged term=NONE cterm=bold gui=bold ctermfg=2 guifg=#859900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi gitcommitUnmergedFile term=NONE cterm=bold gui=bold ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi gitcommitUntrackedFile term=NONE cterm=bold gui=bold ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GitGutterAdd term=bold cterm=bold gui=bold ctermfg=2 guifg=#859900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GitGutterAddIntraLine term=NONE cterm=reverse gui=reverse ctermfg=NONE guifg=NONE ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GitGutterChange term=bold cterm=bold gui=bold ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GitGutterDelete term=bold cterm=bold gui=bold ctermfg=1 guifg=#dc322f ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GitGutterDeleteIntraLine term=NONE cterm=reverse gui=reverse ctermfg=NONE guifg=NONE ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GlyphPalette1 term=NONE cterm=NONE gui=NONE ctermfg=1 guifg=#dc322f ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GlyphPalette10 term=NONE cterm=NONE gui=NONE ctermfg=10 guifg=#586e75 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GlyphPalette11 term=NONE cterm=NONE gui=NONE ctermfg=11 guifg=#657b83 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GlyphPalette12 term=NONE cterm=NONE gui=NONE ctermfg=12 guifg=#839496 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GlyphPalette13 term=NONE cterm=NONE gui=NONE ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GlyphPalette14 term=NONE cterm=NONE gui=NONE ctermfg=14 guifg=#93a1a1 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GlyphPalette2 term=NONE cterm=NONE gui=NONE ctermfg=2 guifg=#859900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GlyphPalette3 term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GlyphPalette4 term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GlyphPalette5 term=NONE cterm=NONE gui=NONE ctermfg=5 guifg=#d33682 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GlyphPalette6 term=NONE cterm=NONE gui=NONE ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi GlyphPalette9 term=NONE cterm=NONE gui=NONE ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi helpExample term=NONE cterm=NONE gui=NONE ctermfg=14 guifg=#93a1a1 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi helpHyperTextEntry term=NONE cterm=NONE gui=NONE ctermfg=2 guifg=#859900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi helpHyperTextJump term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi helpNote term=NONE cterm=NONE gui=NONE ctermfg=5 guifg=#d33682 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi helpOption term=NONE cterm=NONE gui=NONE ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi helpVim term=NONE cterm=NONE gui=NONE ctermfg=5 guifg=#d33682 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi hs_DeclareFunction term=NONE cterm=NONE gui=NONE ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi hs_hlFunctionName term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi hs_OpFunctionName term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi hsImport term=NONE cterm=NONE gui=NONE ctermfg=5 guifg=#d33682 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi hsImportLabel term=NONE cterm=NONE gui=NONE ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi hsModuleName term=NONE cterm=NONE gui=NONE ctermfg=2 guifg=#859900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi hsNiceOperator term=NONE cterm=NONE gui=NONE ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi hsStatement term=NONE cterm=NONE gui=NONE ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi hsString term=NONE cterm=NONE gui=NONE ctermfg=11 guifg=#657b83 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi hsStructure term=NONE cterm=NONE gui=NONE ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi hsType term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi hsTypedef term=NONE cterm=NONE gui=NONE ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi hsVarSym term=NONE cterm=NONE gui=NONE ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi htmlArg term=NONE cterm=NONE gui=NONE ctermfg=11 guifg=#657b83 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi htmlEndTag term=NONE cterm=NONE gui=NONE ctermfg=10 guifg=#586e75 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi htmlSpecialTagName term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi htmlTag term=NONE cterm=NONE gui=NONE ctermfg=10 guifg=#586e75 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi htmlTagN term=NONE cterm=bold gui=bold ctermfg=14 guifg=#93a1a1 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi htmlTagName term=NONE cterm=bold gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi javaScript term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocBlockQuote term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocBlockQuoteLeader1 term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocBlockQuoteLeader2 term=NONE cterm=NONE gui=NONE ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocBlockQuoteLeader3 term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocBlockQuoteLeader4 term=NONE cterm=NONE gui=NONE ctermfg=1 guifg=#dc322f ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocBlockQuoteLeader5 term=NONE cterm=NONE gui=NONE ctermfg=12 guifg=#839496 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocBlockQuoteLeader6 term=NONE cterm=NONE gui=NONE ctermfg=10 guifg=#586e75 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocCitation term=NONE cterm=NONE gui=NONE ctermfg=5 guifg=#d33682 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocCitationDelim term=NONE cterm=NONE gui=NONE ctermfg=5 guifg=#d33682 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocCitationID term=NONE cterm=NONE gui=NONE ctermfg=5 guifg=#d33682 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocCitationRef term=NONE cterm=NONE gui=NONE ctermfg=5 guifg=#d33682 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocComment term=NONE cterm=NONE gui=NONE ctermfg=10 guifg=#586e75 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocDefinitionBlock term=NONE cterm=NONE gui=NONE ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocDefinitionIndctr term=NONE cterm=bold gui=bold ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocDefinitionTerm term=NONE cterm=standout gui=standout ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocEmphasis term=NONE cterm=NONE gui=NONE ctermfg=12 guifg=#839496 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocEmphasisDefinition term=NONE cterm=NONE gui=NONE ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocEmphasisHeading term=NONE cterm=bold gui=bold ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocEmphasisNested term=NONE cterm=bold gui=bold ctermfg=12 guifg=#839496 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocEmphasisNestedDefinition term=NONE cterm=bold gui=bold ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocEmphasisNestedHeading term=NONE cterm=bold gui=bold ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocEmphasisNestedTable term=NONE cterm=bold gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocEmphasisTable term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocEscapePair term=NONE cterm=bold gui=bold ctermfg=1 guifg=#dc322f ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocFootnote term=NONE cterm=NONE gui=NONE ctermfg=2 guifg=#859900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocFootnoteDefLink term=NONE cterm=bold gui=bold ctermfg=2 guifg=#859900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocFootnoteInline term=NONE cterm=bold gui=bold ctermfg=2 guifg=#859900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocFootnoteLink term=NONE cterm=NONE gui=NONE ctermfg=2 guifg=#859900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocHeading term=NONE cterm=bold gui=bold ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocHeadingMarker term=NONE cterm=bold gui=bold ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocImageCaption term=NONE cterm=bold gui=bold ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocLinkDefinition term=NONE cterm=NONE gui=NONE ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=11 guisp=#657b83
hi pandocLinkDefinitionID term=NONE cterm=bold gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocLinkDelim term=NONE cterm=NONE gui=NONE ctermfg=10 guifg=#586e75 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocLinkLabel term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocLinkText term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocLinkTitle term=NONE cterm=NONE gui=NONE ctermfg=11 guifg=#657b83 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocLinkTitleDelim term=NONE cterm=NONE gui=NONE ctermfg=10 guifg=#586e75 ctermbg=NONE guibg=NONE ctermul=11 guisp=#657b83
hi pandocLinkURL term=NONE cterm=NONE gui=NONE ctermfg=11 guifg=#657b83 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocListMarker term=NONE cterm=NONE gui=NONE ctermfg=5 guifg=#d33682 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocListReference term=NONE cterm=NONE gui=NONE ctermfg=5 guifg=#d33682 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocMetadata term=NONE cterm=bold gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocMetadataDelim term=NONE cterm=NONE gui=NONE ctermfg=10 guifg=#586e75 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocMetadataKey term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocNonBreakingSpace term=NONE cterm=reverse gui=reverse ctermfg=1 guifg=#dc322f ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocRule term=NONE cterm=bold gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocRuleLine term=NONE cterm=bold gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrikeout term=NONE cterm=reverse gui=reverse ctermfg=10 guifg=#586e75 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrikeoutDefinition term=NONE cterm=reverse gui=reverse ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrikeoutHeading term=NONE cterm=reverse gui=reverse ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrikeoutTable term=NONE cterm=reverse gui=reverse ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrongEmphasis term=NONE cterm=bold gui=bold ctermfg=12 guifg=#839496 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrongEmphasisDefinition term=NONE cterm=bold gui=bold ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrongEmphasisEmphasis term=NONE cterm=bold gui=bold ctermfg=12 guifg=#839496 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrongEmphasisEmphasisDefinition term=NONE cterm=bold gui=bold ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrongEmphasisEmphasisHeading term=NONE cterm=bold gui=bold ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrongEmphasisEmphasisTable term=NONE cterm=bold gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrongEmphasisHeading term=NONE cterm=bold gui=bold ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrongEmphasisNested term=NONE cterm=bold gui=bold ctermfg=12 guifg=#839496 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrongEmphasisNestedDefinition term=NONE cterm=bold gui=bold ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrongEmphasisNestedHeading term=NONE cterm=bold gui=bold ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrongEmphasisNestedTable term=NONE cterm=bold gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStrongEmphasisTable term=NONE cterm=bold gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocStyleDelim term=NONE cterm=NONE gui=NONE ctermfg=10 guifg=#586e75 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocSubscript term=NONE cterm=NONE gui=NONE ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocSubscriptDefinition term=NONE cterm=NONE gui=NONE ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocSubscriptHeading term=NONE cterm=bold gui=bold ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocSubscriptTable term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocSuperscript term=NONE cterm=NONE gui=NONE ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocSuperscriptDefinition term=NONE cterm=NONE gui=NONE ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocSuperscriptHeading term=NONE cterm=bold gui=bold ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocSuperscriptTable term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocTable term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocTableStructure term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocTitleBlock term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocTitleBlockTitle term=NONE cterm=bold gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocTitleComment term=NONE cterm=bold gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocVerbatimBlock term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocVerbatimInline term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocVerbatimInlineDefinition term=NONE cterm=NONE gui=NONE ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocVerbatimInlineHeading term=NONE cterm=bold gui=bold ctermfg=9 guifg=#cb4b16 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi pandocVerbatimInlineTable term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi perlHereDoc term=NONE cterm=NONE gui=NONE ctermfg=14 guifg=#93a1a1 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi perlStatementFileDesc term=NONE cterm=NONE gui=NONE ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi perlVarPlain term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi rubyBoolean term=NONE cterm=NONE gui=NONE ctermfg=5 guifg=#d33682 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi rubyDefine term=NONE cterm=bold gui=bold ctermfg=14 guifg=#93a1a1 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi SignatureMarkerText term=NONE cterm=NONE gui=NONE ctermfg=2 guifg=#859900 ctermbg=0 guibg=#073642 ctermul=NONE guisp=NONE
hi texmathmatcher term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi texmathzonex term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi texreflabel term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi texstatement term=NONE cterm=NONE gui=NONE ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi VarId term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi vimCmdSep term=NONE cterm=bold gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi vimCommand term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi vimCommentString term=NONE cterm=NONE gui=NONE ctermfg=13 guifg=#6c71c4 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi vimGroup term=NONE cterm=bold gui=bold ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi vimHiGroup term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi vimHiLink term=NONE cterm=NONE gui=NONE ctermfg=4 guifg=#268bd2 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi vimIsCommand term=NONE cterm=NONE gui=NONE ctermfg=11 guifg=#657b83 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi vimSynMtchOpt term=NONE cterm=NONE gui=NONE ctermfg=3 guifg=#b58900 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi vimSynType term=NONE cterm=NONE gui=NONE ctermfg=6 guifg=#2aa198 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
hi! link PreInsert Added
hi! link helpBoldItalic BoldItalic
hi! link vim9Boolean Boolean
hi! link diffChanged Changed
hi! link vimSynCcharValue Character
hi! link UndotreeHelp Comment
hi! link UndotreeSeq Comment
hi! link diffComment Comment
hi! link luaComment Comment
hi! link pythonComment Comment
hi! link vim9Comment Comment
hi! link vimComment Comment
hi! link vimScriptDelim Comment
hi! link luaCond Conditional
hi! link luaCondElse Conditional
hi! link pythonConditional Conditional
hi! link Boolean Constant
hi! link Character Constant
hi! link Number Constant
hi! link String Constant
hi! link UndotreeBranch Constant
hi! link diffBDiffer Constant
hi! link diffCommon Constant
hi! link diffDiffer Constant
hi! link diffIdentical Constant
hi! link diffIsA Constant
hi! link diffNoEOL Constant
hi! link diffOnly Constant
hi! link luaConstant Constant
hi! link vim9Null Constant
hi! link vimHiCtermColor Constant
hi! link vimSleepArg Constant
hi! link vimTerminalKillOptionArg Constant
hi! link vimTerminalSizeOptionArg Constant
hi! link vimTerminalTypeOptionArg Constant
hi! link lspReference CursorColumn
hi! link QuickFixLine CursorLine
hi! link GitGutterAddLineNr CursorLineNr
hi! link GitGutterChangeLineNr CursorLineNr
hi! link GitGutterDeleteLineNr CursorLineNr
hi! link pythonDecorator Define
hi! link pythonDoctestValue Define
hi! link hsDelimTypeExport Delimiter
hi! link hsImportParams Delimiter
hi! link vim9SearchDelim Delimiter
hi! link vimBracket Delimiter
hi! link vimLambdaBrace Delimiter
hi! link vimParenSep Delimiter
hi! link vimSearchDelim Delimiter
hi! link vimSep Delimiter
hi! link vimSubstDelim Delimiter
hi! link vimSynIskeywordSep Delimiter
hi! link GitGutterAddLine DiffAdd
hi! link GitGutterChangeLine DiffChange
hi! link GitGutterDeleteLine DiffDelete
hi! link DiffTextAdd DiffText
hi! link GlyphPaletteDirectory Directory
hi! link LspErrorHighlight Error
hi! link LspErrorText Error
hi! link luaError Error
hi! link luaParenError Error
hi! link vimElseIfErr Error
hi! link vimError Error
hi! link vimOperError Error
hi! link vimSortOptionsError Error
hi! link vimUserCmdAttrError Error
hi! link vimUserCmdError Error
hi! link pythonException Exception
hi! link CursorLineFold FoldColumn
hi! link UndotreeFirstNode Function
hi! link UndotreeHelpKey Function
hi! link UndotreeTimeStamp Function
hi! link jsFuncCall Function
hi! link luaFunction Function
hi! link luaMetaMethod Function
hi! link pythonBuiltin Function
hi! link pythonDecoratorName Function
hi! link pythonFunction Function
hi! link vimFunc Function
hi! link vimFuncName Function
hi! link vimUserFunc Function
hi! link Function Identifier
hi! link UndotreeHead Identifier
hi! link diffLine Identifier
hi! link luaFunc Identifier
hi! link pythonClassVar Identifier
hi! link vim9Super Identifier
hi! link vim9This Identifier
hi! link vimOptionVar Identifier
hi! link vimOptionVarName Identifier
hi! link vimSpecFile Identifier
hi! link vimVar Identifier
hi! link vimVarScope Identifier
hi! link vimVimVar Identifier
hi! link vimVimVarName Identifier
hi! link CurSearch IncSearch
hi! link pythonInclude Include
hi! link helpItalic Italic
hi! link vim9Extends Keyword
hi! link vim9Implements Keyword
hi! link luaLabel Label
hi! link LineNrAbove LineNr
hi! link LineNrBelow LineNr
hi! link UndotreeSavedBig MatchParen
hi! link EndOfBuffer NonText
hi! link vimNonText NonText
hi! link LspCodeActionText Normal
hi! link LspHintHighlight Normal
hi! link LspHintText Normal
hi! link LspInformationHighlight Normal
hi! link LspInformationText Normal
hi! link Terminal Normal
hi! link vimGroupName Normal
hi! link vimWildcardBracketCharacter Normal
hi! link Float Number
hi! link luaNumber Number
hi! link pythonNumber Number
hi! link vimCount Number
hi! link vimHiNmbr Number
hi! link vimMark Number
hi! link vimMenuPriority Number
hi! link vimNumber Number
hi! link vimSubstCount Number
hi! link luaOperator Operator
hi! link pythonOperator Operator
hi! link PmenuExtra Pmenu
hi! link PmenuKind Pmenu
hi! link CocMenuSel PmenuSel
hi! link PmenuExtraSel PmenuSel
hi! link PmenuKindSel PmenuSel
hi! link PopupSelected PmenuSel
hi! link Define PreProc
hi! link Include PreProc
hi! link Macro PreProc
hi! link PreCondit PreProc
hi! link diffIndexLine PreProc
hi! link diffSubname PreProc
hi! link vim9CommentTitle PreProc
hi! link vimCommentTitle PreProc
hi! link vimEnvvar PreProc
hi! link vimHiAttrib PreProc
hi! link vimMenuName PreProc
hi! link vimOption PreProc
hi! link vimShebang PreProc
hi! link UndotreeNode Question
hi! link diffRemoved Removed
hi! link luaFor Repeat
hi! link luaRepeat Repeat
hi! link pythonRepeat Repeat
hi! link CursorLineSign SignColumn
hi! link debugBreakpoint SignColumn
hi! link debugPC SignColumn
hi! link Debug Special
hi! link Delimiter Special
hi! link SpecialChar Special
hi! link SpecialComment Special
hi! link Tag Special
hi! link helpSpecial Special
hi! link pythonDoctest Special
hi! link pythonEscape Special
hi! link pythonFStringDelimiter Special
hi! link vim9Vim9ScriptArg Special
hi! link vimAutocmdBufferPattern Special
hi! link vimAutocmdMod Special
hi! link vimAutocmdPatternEscape Special
hi! link vimContinue Special
hi! link vimDoautocmdMod Special
hi! link vimEscape Special
hi! link vimFunctionMod Special
hi! link vimGroupSpecial Special
hi! link vimImportAutoload Special
hi! link vimLetHeredocStart Special
hi! link vimLetHeredocStop Special
hi! link vimMenuClear Special
hi! link vimMenuStatus Special
hi! link vimNotation Special
hi! link vimRedirEnd Special
hi! link vimSortOptions Special
hi! link vimSubstFlags Special
hi! link vimSynOption Special
hi! link vimUniqOptions Special
hi! link vimUserCmdAttr Special
hi! link vimVimgrepFlags Special
hi! link vimWildcard Special
hi! link luaSpecial SpecialChar
hi! link vimCmplxRepeat SpecialChar
hi! link vimCtrlChar SpecialChar
hi! link vimPatSep SpecialChar
hi! link vimRegister SpecialChar
hi! link vimSubstSubstr SpecialChar
hi! link Conditional Statement
hi! link Exception Statement
hi! link Keyword Statement
hi! link Label Statement
hi! link Operator Statement
hi! link Repeat Statement
hi! link UndotreeCurrent Statement
hi! link UndotreeNodeCurrent Statement
hi! link diffAdded Statement
hi! link luaStatement Statement
hi! link pythonAsync Statement
hi! link pythonStatement Statement
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineNC
hi! link luaString String
hi! link luaString2 String
hi! link pythonBytes String
hi! link pythonFString String
hi! link pythonQuotes String
hi! link pythonRawBytes String
hi! link pythonRawFString String
hi! link pythonRawString String
hi! link pythonString String
hi! link vimString String
hi! link luaTable Structure
hi! link pythonClass Structure
hi! link pythonExceptions Structure
hi! link TabLineFill TabLine
hi! link TabPanel TabLine
hi! link TabPanelFill TabLineFill
hi! link TabPanelSel TabLineSel
hi! link LspWarningHighlight Todo
hi! link LspWarningText Todo
hi! link luaTodo Todo
hi! link pythonTodo Todo
hi! link vimTodo Todo
hi! link PmenuMatch Type
hi! link PmenuMatchSel Type
hi! link StorageClass Type
hi! link Structure Type
hi! link Typedef Type
hi! link UndotreeHelpTitle Type
hi! link UndotreeNext Type
hi! link diffFile Type
hi! link pythonType Type
hi! link rubySymbol Type
hi! link vimAutoEvent Type
hi! link vimAutoEventGlob Type
hi! link vimHiClear Type
hi! link vimHiTerm Type
hi! link vimPattern Type
hi! link vimSpecial Type
hi! link vimSynCase Type
hi! link vimSynConceal Type
hi! link vimSynFoldlevel Type
hi! link vimSynIskeyword Type
hi! link vimSynReg Type
hi! link vimSynSpell Type
hi! link vimSyncCcomment Type
hi! link vimSyncClear Type
hi! link vimSyncFromstart Type
hi! link vimSyncKey Type
hi! link vimSyncLinebreak Type
hi! link vimSyncLinecont Type
hi! link vimSyncLines Type
hi! link vimSyncMatch Type
hi! link vimSyncNone Type
hi! link vimSyncRegion Type
hi! link vimType Type
hi! link MessageWindow WarningMsg
hi! link PopupNotification WarningMsg
hi! link UndotreeSavedSmall WarningMsg
hi! link vimWarn WarningMsg
hi! link ALEStyleError ALEError
hi! link ALEStyleErrorSign ALEErrorSign
hi! link ALEStyleErrorSignLineNr ALEErrorSignLineNr
hi! link ALEStyleWarning ALEWarning
hi! link ALEStyleWarningSign ALEWarningSign
hi! link ALEStyleWarningSignLineNr ALEWarningSignLineNr
hi! link GitGutterChangeDelete GitGutterChange
hi! link GitGutterChangeDeleteInvisible GitGutterChangeInvisible
hi! link GitGutterChangeDeleteLine GitGutterChangeLine
hi! link GitGutterChangeDeleteLineNr GitGutterChangeLineNr
hi! link LspErrorVirtualText LspErrorText
hi! link LspHintVirtualText LspHintText
hi! link LspInformationVirtualText LspInformationText
hi! link LspWarningVirtualText LspWarningText
hi! link diffNewFile diffFile
hi! link diffOldFile diffFile
hi! link gitcommitNoBranch gitcommitBranch
hi! link gitcommitDiscarded gitcommitComment
hi! link gitcommitSelected gitcommitComment
hi! link gitcommitUntracked gitcommitComment
hi! link gitcommitDiscardedArrow gitcommitDiscardedFile
hi! link gitcommitSelectedArrow gitcommitSelectedFile
hi! link gitcommitUnmergedArrow gitcommitUnmergedFile
hi! link hsModuleStartLabel hsStructure
hi! link hsModuleWhereLabel hsModuleStartLabel
hi! link luaCommentDelimiter luaComment
hi! link luaSymbolOperator luaOperator
hi! link luaStringDelimiter luaString
hi! link pandocEscapedCharacter pandocEscapePair
hi! link pandocLineBreak pandocEscapePair
hi! link pandocMetadataTitle pandocMetadata
hi! link pandocTableStructureEnd pandocTableStructre
hi! link pandocTableStructureTop pandocTableStructre
hi! link pandocCodeBlock pandocVerbatimBlock
hi! link pandocCodeBlockDelim pandocVerbatimBlock
hi! link pandocVerbatimBlockDeep pandocVerbatimBlock
hi! link pythonEllipsis pythonBuiltin
hi! link pythonUnicodeEscape pythonEscape
hi! link pythonTripleQuotes pythonQuotes
hi! link vim9EnumImplementedInterfaceComment vim9Comment
hi! link vim9EnumNameComment vim9Comment
hi! link vim9EnumNameContinueComment vim9Comment
hi! link vim9EnumValueListCommaComment vim9Comment
hi! link vim9ForInComment vim9Comment
hi! link vim9LambdaOperatorComment vim9Comment
hi! link vimDefComment vim9Comment
hi! link vim9EnumImplements vim9Implements
hi! link vimOper Operator
hi! link vimBang vimOper
hi! link vim9LambdaOperator vimOper
hi! link vim9TypeEquals vimOper
hi! link vimFunctionParamEquals vimOper
hi! link vimLambdaOperator vimOper
hi! link vimRedirFileOperator vimOper
hi! link vimRedirRegisterOperator vimOper
hi! link vimRedirVariableOperator vimOper
hi! link vimAugroupBang vimBang
hi! link vimAutocmdBang vimBang
hi! link vimBehaveBang vimBang
hi! link vimCommandModifierBang vimBang
hi! link vimDefBang vimBang
hi! link vimDelfunctionBang vimBang
hi! link vimExFilterBang vimBang
hi! link vimFunctionBang vimBang
hi! link vimGrepBang vimBang
hi! link vimHiBang vimBang
hi! link vimLockvarBang vimBang
hi! link vimMakeBang vimBang
hi! link vimMapBang vimBang
hi! link vimMenuBang vimBang
hi! link vimProfileBang vimBang
hi! link vimRedirBang vimBang
hi! link vimSetBang vimBang
hi! link vimSleepBang vimBang
hi! link vimSortBang vimBang
hi! link vimUniqBang vimBang
hi! link vimUnletBang vimBang
hi! link vimVimgrepBang vimBang
hi! link vimBehaveModel vimBehave
hi! link vimMapLeader vimBracket
hi! link vimMapMod vimBracket
hi! link vim9Abstract vimCommand
hi! link vim9AbstractDef vimCommand
hi! link vim9Class vimCommand
hi! link vim9Const vimCommand
hi! link vim9Enum vimCommand
hi! link vim9Export vimCommand
hi! link vim9Final vimCommand
hi! link vim9For vimCommand
hi! link vim9Interface vimCommand
hi! link vim9MethodDef vimCommand
hi! link vim9Public vimCommand
hi! link vim9Static vimCommand
hi! link vim9Type vimCommand
hi! link vim9Var vimCommand
hi! link vim9Vim9Script vimCommand
hi! link vimAbb vimCommand
hi! link vimAugroupKey vimCommand
hi! link vimAutocmd vimCommand
hi! link vimBehave vimCommand
hi! link vimCall vimCommand
hi! link vimCatch vimCommand
hi! link vimCommandModifier vimCommand
hi! link vimCompilerSet vimCommand
hi! link vimCondHL vimCommand
hi! link vimConst vimCommand
hi! link vimDebuggreedy vimCommand
hi! link vimDef vimCommand
hi! link vimDefer vimCommand
hi! link vimDelFunction vimCommand
hi! link vimDelcommand vimCommand
hi! link vimDoautocmd vimCommand
hi! link vimEcho vimCommand
hi! link vimEchohl vimCommand
hi! link vimElse vimCommand
hi! link vimEnddef vimCommand
hi! link vimEndfunction vimCommand
hi! link vimEndif vimCommand
hi! link vimEval vimCommand
hi! link vimExFilter vimCommand
hi! link vimExMark vimCommand
hi! link vimFTCmd vimCommand
hi! link vimFor vimCommand
hi! link vimFuncEcho vimCommand
hi! link vimFunction vimCommand
hi! link vimGrep vimCommand
hi! link vimGrepAdd vimCommand
hi! link vimHelpgrep vimCommand
hi! link vimHighlight vimCommand
hi! link vimImport vimCommand
hi! link vimLet vimCommand
hi! link vimLockvar vimCommand
hi! link vimLua vimCommand
hi! link vimMake vimCommand
hi! link vimMakeadd vimCommand
hi! link vimMap vimCommand
hi! link vimMatch vimCommand
hi! link vimMenu vimCommand
hi! link vimMzScheme vimCommand
hi! link vimNormal vimCommand
hi! link vimNotFunc vimCommand
hi! link vimPerl vimCommand
hi! link vimProfdel vimCommand
hi! link vimProfile vimCommand
hi! link vimPython vimCommand
hi! link vimPython3 vimCommand
hi! link vimPythonX vimCommand
hi! link vimRedir vimCommand
hi! link vimRuby vimCommand
hi! link vimSet vimCommand
hi! link vimSleep vimCommand
hi! link vimSort vimCommand
hi! link vimSubst vimCommand
hi! link vimSynColor vimCommand
hi! link vimSynLink vimCommand
hi! link vimSynMenu vimCommand
hi! link vimSyntax vimCommand
hi! link vimTcl vimCommand
hi! link vimTerminal vimCommand
hi! link vimThrow vimCommand
hi! link vimUniq vimCommand
hi! link vimUnlet vimCommand
hi! link vimUnlockvar vimCommand
hi! link vimUserCmd vimCommand
hi! link vimUserCmdKey vimCommand
hi! link vimVimgrep vimCommand
hi! link vimVimgrepadd vimCommand
hi! link vimWincmd vimCommand
hi! link vim9LineComment vimComment
hi! link vimContinueComment vimComment
hi! link vimFunctionComment vimComment
hi! link vimKeymapLineComment vimComment
hi! link vimKeymapTailComment vimComment
hi! link vimLineComment vimComment
hi! link vimMenutranslateComment vimComment
hi! link vimMtchComment vimComment
hi! link vimSetComment vimComment
hi! link vim9EnumNameContinue vimContinue
hi! link vimForInContinue vimContinue
hi! link vimOperContinue vimContinue
hi! link vimTerminalContinue vimContinue
hi! link vim9ContinueComment vimContinueComment
hi! link vimForInContinueComment vimContinueComment
hi! link vimOperContinueComment vimContinueComment
hi! link vimTerminalContinueComment vimContinueComment
hi! link vim9MethodDefComment vimDefComment
hi! link vim9CommentError vimError
hi! link vim9Func vimError
hi! link vim9TypeAliasError vimError
hi! link vimAugroupError vimError
hi! link vimBehaveError vimError
hi! link vimCollClassErr vimError
hi! link vimCommentError vimError
hi! link vimErrSetting vimError
hi! link vimFTError vimError
hi! link vimFunctionError vimError
hi! link vimHiAttribList vimError
hi! link vimHiCtermError vimError
hi! link vimHiKeyError vimError
hi! link vimMapModErr vimError
hi! link vimMarkArgError vimError
hi! link vimPatSepErr vimError
hi! link vimShebangError vimError
hi! link vimSubstFlagErr vimError
hi! link vimSynCaseError vimError
hi! link vimSynConcealError vimError
hi! link vimSynError vimError
hi! link vimSynFoldlevelError vimError
hi! link vimSynIskeywordError vimError
hi! link vimSynSpellError vimError
hi! link vimSyncError vimError
hi! link vimQuoteEscape vimEscape
hi! link vimStringInterpolationBrace vimEscape
hi! link vim9MethodName vimFuncName
hi! link vim9MethodNameError vimFunctionError
hi! link vimEchohlNone vimGroup
hi! link vimHLGroup vimGroup
hi! link vimHiNone vimGroup
hi! link vimMatchGroup vimGroup
hi! link vimMatchNone vimGroup
hi! link vimSyncGroup vimGroupName
hi! link vimSyncGroupName vimGroupName
hi! link vimFgBgAttrib vimHiAttrib
hi! link vimHiCTerm vimHiTerm
hi! link vimHiCtermFgBg vimHiTerm
hi! link vimHiCtermfont vimHiTerm
hi! link vimHiCtermul vimHiTerm
hi! link vimHiGui vimHiTerm
hi! link vimHiGuiFgBg vimHiTerm
hi! link vimHiGuiFont vimHiTerm
hi! link vimHiStartStop vimHiTerm
hi! link vimImportAs vimImport
hi! link vim9KeymapLineComment vimKeymapLineComment
hi! link vimScriptHeredocStart vimLetHeredocStart
hi! link vimScriptHeredocStop vimLetHeredocStop
hi! link vimUnmap vimMap
hi! link vimMenuMod vimMapMod
hi! link vimAddress vimMark
hi! link vimPlainMark vimMark
hi! link vimSynMenuPath vimMenuName
hi! link vimMapLeaderKey vimNotation
hi! link vimMenuNotation vimNotation
hi! link vimFunctionSID vimNotation
hi! link vimMapModKey vimFunctionSID
hi! link vimHiGuiRgb vimNumber
hi! link vimLockvarDepth vimNumber
hi! link vimMarkNumber vimNumber
hi! link vimSetAll vimOption
hi! link vimSetMod vimOption
hi! link vimSetTermcap vimOption
hi! link vim9LambdaParen vimParenSep
hi! link vimPatSepR vimPatSep
hi! link vimPatSepZ vimPatSep
hi! link vimRedirRegister vimRegister
hi! link vimLetRegister vimRegister
hi! link vim9LhsRegister vimLetRegister
hi! link vimAutocmdPatternSep vimSep
hi! link vimSetSep vimSep
hi! link vimSpecFileMod vimSpecFile
hi! link vimProfdelArg vimSpecial
hi! link vimProfileArg vimSpecial
hi! link vimTerminalOption vimSpecial
hi! link vimUserCmdAttrAddr vimSpecial
hi! link vimUserCmdAttrComplete vimSpecial
hi! link vimUserCmdAttrNargs vimSpecial
hi! link vimUserCmdAttrRange vimSpecial
hi! link vim9Search vimString
hi! link vimContinueString vimString
hi! link vimInsert vimString
hi! link vimLetHeredoc vimString
hi! link vimNotPatSep vimString
hi! link vimPatSepZone vimString
hi! link vimSearch vimString
hi! link vimStringCont vimString
hi! link vimStringEnd vimString
hi! link vimSubstTwoBS vimString
hi! link vimSynPatRange vimString
hi! link vimSynRegPat vimString
hi! link vimSynNotPatRange vimSynRegPat
hi! link vimSubst1 vimSubst
hi! link vimGroupAdd vimSynOption
hi! link vimGroupRem vimSynOption
hi! link vimSynCchar vimSynOption
hi! link vimSynKeyOpt vimSynOption
hi! link vimSynMtchGrp vimSynOption
hi! link vimSynNextgroup vimSynOption
hi! link vimSynRegOpt vimSynOption
hi! link vimSynContains vimSynOption
hi! link vimSynKeyContainedin vimSynContains
hi! link vimFTOption vimSynType
hi! link vim9VariableType vimType
hi! link vim9VariableTypeAny vimType
hi! link vimTypeAny vimType
hi! link vimDelcommandAttr vimUserCmdAttr
hi! link vimUserCmdAttrKey vimUserCmdAttr
hi! link vim9ConstructorDefParam vimVar
hi! link vim9LhsVariable vimVar
hi! link vim9Variable vimVar
hi! link vimDefParam vimVar
hi! link vimFBVar vimVar
hi! link vimFunctionParam vimVar
hi! link vimLetVar vimVar
hi! link vimUserCmdAttrCompleteFunc vimVar
hi! link vimFunctionScope vimVarScope
hi! link vimBufnrWarn vimWarn
hi! link vimWildcardBraceComma vimWildcard
hi! link vimWildcardBracket vimWildcard
hi! link vimWildcardBracketCaret vimWildcard
hi! link vimWildcardBracketCharacterClass vimWildcard
hi! link vimWildcardBracketCollatingSymbol vimWildcard
hi! link vimWildcardBracketEnd vimWildcard
hi! link vimWildcardBracketEquivalenceClass vimWildcard
hi! link vimWildcardBracketEscape vimWildcard
hi! link vimWildcardBracketHyphen vimWildcard
hi! link vimWildcardBracketStart vimWildcard
hi! link vimWildcardEscape vimWildcard
hi! link vimWildcardInterval vimWildcard
hi! link vimWildcardQuestion vimWildcard
hi! link vimWildcardStar vimWildcard
hi! link vimWildcardBracketRightBracket vimWildcardBracketCharacter
