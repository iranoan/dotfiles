vim9script
scriptencoding utf-8

hi clear
g:colors_name = 'suiboku'

g:terminal_ansi_colors = [
	'#1d221f', #  0 Inkstone   dark background                        # black           30 40
	'#dc322f', #  1 Vermilion                                         # red             31 41
	'#309c00', #  2 KOSHIABURA                                        # green           32 42
	'#b48000', #  3 Ochre                                             # yellow          33 43
	'#0080bd', #  4 SEIRAN                                            # blue            34 44
	'#e14096', #  5 Lotus                                             # magenta         35 45
	'#4f5fff', #  6 Iris                                              # cyan            36 46
	'#e6e1d1', #  7 Fog        light sub background / dark foreground # white           37 47
	'#29302b', #  8 AOZUMI     dark sub background / light foreground # light black     90 100
	'#ff786e', #  9 Peony                                             # light red       91 101
	'#00886a', # 10 Bamboo                                            # light green     92 102
	'#e65310', # 11 Persimmon                                         # light yellow    93 103
	'#6d736d', # 12 Ash        light sub foreground    unmatch term→ # light blue      94 104
	'#966fe1', # 13 Violet                                            # light magenta   95 105
	'#8c8a7d', # 14 Gray       dark sub foreground     unmatch term→ # light cyan      96 106
	'#f7f2e1'  # 15 WASHI      light background                       # light white     97 107
]

if !&termguicolors
	set t_Co=16
endif

var suiboku: dict<bool> = get(g:, 'suiboku', {italic: false, transparent: true})
var italic: bool = get(suiboku, 'italic', false)

if &background ==# 'dark'
	if has('gui_running')
		hi Normal term=NONE cterm=NONE ctermfg=7 ctermbg=0 ctermul=NONE gui=NONE guifg=#e6e1d1 guibg=#1d221f guisp=NONE
	else
		if !&termguicolors
			set t_Co=16
		endif
		if get(suiboku, 'transparent', true)
			hi Normal term=NONE cterm=NONE ctermfg=7 ctermbg=NONE ctermul=NONE gui=NONE guifg=#e6e1d1 guibg=NONE guisp=NONE
		else
			hi Normal term=NONE cterm=NONE ctermfg=7 ctermbg=0 ctermul=NONE gui=NONE guifg=#e6e1d1 guibg=#1d221f guisp=NONE
		endif
	endif
	if italic
		hi Comment term=italic cterm=italic ctermfg=14 ctermbg=NONE ctermul=NONE gui=italic guifg=#8c8a7d guibg=NONE guisp=NONE
		hi ErrorMsg term=italic,reverse,bold cterm=reverse ctermfg=1 ctermbg=15 ctermul=NONE gui=reverse guifg=#dc322f guibg=#f7f2e1 guisp=NONE
		hi Folded term=italic,reverse,underline cterm=bold ctermfg=14 ctermbg=8 ctermul=NONE gui=bold guifg=#8c8a7d guibg=#29302b guisp=NONE
		hi TabLine term=italic,underline cterm=italic,underline ctermfg=14 ctermbg=8 ctermul=NONE gui=italic,underline guifg=#8c8a7d guibg=#29302b guisp=NONE
	else
		hi Comment term=NONE cterm=NONE ctermfg=14 ctermbg=NONE ctermul=NONE gui=NONE guifg=#8c8a7d guibg=NONE guisp=NONE
		hi ErrorMsg term=reverse,bold cterm=reverse ctermfg=1 ctermbg=15 ctermul=NONE gui=reverse guifg=#dc322f guibg=#f7f2e1 guisp=NONE
		hi Folded term=reverse,underline cterm=bold ctermfg=14 ctermbg=8 ctermul=NONE gui=bold guifg=#8c8a7d guibg=#29302b guisp=NONE
		hi TabLine term=underline cterm=underline ctermfg=14 ctermbg=8 ctermul=NONE gui=underline guifg=#8c8a7d guibg=#29302b guisp=NONE
	endif
	hi ColorColumn term=reverse cterm=NONE ctermfg=NONE ctermbg=8 ctermul=NONE gui=NONE guifg=NONE guibg=#29302b guisp=NONE
	hi Cursor term=NONE cterm=NONE ctermfg=0 ctermbg=14 ctermul=NONE gui=NONE guifg=#1d221f guibg=#8c8a7d guisp=NONE
	hi CursorColumn term=reverse cterm=NONE ctermfg=NONE ctermbg=8 ctermul=NONE gui=NONE guifg=NONE guibg=#29302b guisp=NONE
	hi CursorLine term=NONE cterm=NONE ctermfg=NONE ctermbg=8 ctermul=NONE gui=NONE guifg=NONE guibg=#29302b guisp=NONE
	hi DiffAdd term=underline,reverse cterm=NONE ctermfg=2 ctermbg=8 ctermul=2 gui=NONE guifg=#309c00 guibg=#29302b guisp=#309c00
	hi DiffChange term=underline,reverse cterm=NONE ctermfg=3 ctermbg=8 ctermul=3 gui=NONE guifg=#b48000 guibg=#29302b guisp=#b48000
	hi DiffDelete term=underline,reverse cterm=bold ctermfg=1 ctermbg=8 ctermul=NONE gui=bold guifg=#dc322f guibg=#29302b guisp=NONE
	hi DiffText term=bold,underline,reverse cterm=NONE ctermfg=4 ctermbg=8 ctermul=4 gui=bold guifg=#0080bd guibg=#29302b guisp=#0080bd
	hi Error term=bold cterm=reverse,bold ctermfg=1 ctermbg=15 ctermul=NONE gui=reverse,bold guifg=#dc322f guibg=#f7f2e1 guisp=NONE
	hi FoldColumn term=reverse cterm=NONE ctermfg=14 ctermbg=8 ctermul=NONE gui=NONE guifg=#8c8a7d guibg=#29302b guisp=NONE
	hi LineNr term=reverse cterm=NONE ctermfg=12 ctermbg=8 ctermul=NONE gui=NONE guifg=#6d736d guibg=#29302b guisp=NONE
	hi NonText term=bold cterm=bold ctermfg=14 ctermbg=NONE ctermul=NONE gui=bold guifg=#8c8a7d guibg=NONE guisp=NONE
	hi Pmenu term=NONE cterm=NONE ctermfg=14 ctermbg=8 ctermul=NONE gui=NONE guifg=#8c8a7d guibg=#29302b guisp=NONE
	hi PmenuSel term=NONE cterm=NONE ctermfg=7 ctermbg=0 ctermul=NONE gui=NONE guifg=#e6e1d1 guibg=#1d221f guisp=NONE
	hi PmenuSbar term=reverse cterm=NONE ctermfg=NONE ctermbg=12 ctermul=NONE gui=NONE guifg=NONE guibg=#6d736d guisp=NONE
	hi PmenuThumb term=reverse cterm=NONE ctermfg=NONE ctermbg=14 ctermul=NONE gui=NONE guifg=NONE guibg=#8c8a7d guisp=NONE
	hi SignColumn term=reverse cterm=NONE ctermfg=14 ctermbg=8 ctermul=NONE gui=NONE guifg=#8c8a7d guibg=#29302b guisp=NONE
	hi SpecialKey term=bold cterm=bold ctermfg=14 ctermbg=8 ctermul=NONE gui=bold guifg=#8c8a7d guibg=#29302b guisp=NONE
	hi StatusLine term=bold cterm=bold ctermfg=0 ctermbg=14 ctermul=NONE gui=bold guifg=#1d221f guibg=#8c8a7d guisp=NONE
	hi StatusLineNC term=NONE cterm=NONE ctermfg=8 ctermbg=12 ctermul=NONE gui=NONE guifg=#29302b guibg=#6d736d guisp=NONE
	hi TabLineSel term=underline,bold cterm=underline,bold ctermfg=7 ctermbg=0 ctermul=NONE gui=underline,bold guifg=#e6e1d1 guibg=#1d221f guisp=NONE
	hi ToolbarButton term=bold,reverse cterm=bold ctermfg=14 ctermbg=8 ctermul=NONE gui=bold guifg=#8c8a7d guibg=#29302b guisp=NONE
	hi ToolbarLine term=reverse cterm=NONE ctermfg=NONE ctermbg=8 ctermul=NONE gui=NONE guifg=NONE guibg=#29302b guisp=NONE
	hi VertSplit term=NONE cterm=NONE ctermfg=12 ctermbg=12 ctermul=NONE gui=NONE guifg=#6d736d guibg=#6d736d guisp=NONE
	hi Visual term=reverse cterm=reverse ctermfg=14 ctermbg=0 ctermul=NONE gui=reverse guifg=#8c8a7d guibg=#1d221f guisp=NONE
	hi VisualNOS term=reverse cterm=reverse ctermfg=NONE ctermbg=8 ctermul=NONE gui=reverse guifg=NONE guibg=#29302b guisp=NONE
	hi WildMenu term=bold cterm=reverse ctermfg=7 ctermbg=8 ctermul=NONE gui=reverse guifg=#e6e1d1 guibg=#29302b guisp=NONE
	hi ALEErrorSign term=NONE cterm=bold ctermfg=1 ctermbg=8 ctermul=NONE gui=bold guifg=#dc322f guibg=#29302b guisp=NONE
	hi ALEErrorSignLineNr term=NONE cterm=NONE ctermfg=8 ctermbg=1 ctermul=NONE gui=NONE guifg=#29302b guibg=#dc322f guisp=NONE
	hi ALEInfoSign term=NONE cterm=bold ctermfg=10 ctermbg=8 ctermul=NONE gui=bold guifg=#00886a guibg=#29302b guisp=NONE
	hi ALEInfoSignLineNr term=NONE cterm=NONE ctermfg=8 ctermbg=10 ctermul=NONE gui=NONE guifg=#29302b guibg=#00886a guisp=NONE
	hi ALEWarningSign term=NONE cterm=bold ctermfg=3 ctermbg=8 ctermul=NONE gui=bold guifg=#b48000 guibg=#29302b guisp=NONE
	hi ALEWarningSignLineNr term=NONE cterm=NONE ctermfg=8 ctermbg=3 ctermul=NONE gui=NONE guifg=#29302b guibg=#b48000 guisp=NONE
	hi GitGutterAddInvisible term=reverse cterm=NONE ctermfg=8 ctermbg=14 ctermul=NONE gui=NONE guifg=#29302b guibg=#8c8a7d guisp=NONE
	hi GlyphPalette0 term=NONE cterm=NONE ctermfg=8 ctermbg=NONE ctermul=NONE gui=NONE guifg=#29302b guibg=NONE guisp=NONE
	hi GlyphPalette7 term=NONE cterm=NONE ctermfg=7 ctermbg=NONE ctermul=NONE gui=NONE guifg=#e6e1d1 guibg=NONE guisp=NONE
	hi GlyphPalette8 term=NONE cterm=NONE ctermfg=0 ctermbg=NONE ctermul=NONE gui=NONE guifg=#1d221f guibg=NONE guisp=NONE
	hi GlyphPalette15 term=NONE cterm=NONE ctermfg=7 ctermbg=NONE ctermul=NONE gui=NONE guifg=#e6e1d1 guibg=NONE guisp=NONE
	hi pandocTableZebraDark term=NONE cterm=NONE ctermfg=4 ctermbg=8 ctermul=NONE gui=NONE guifg=#0080bd guibg=#29302b guisp=NONE
	hi pandocTableZebraLight term=NONE cterm=NONE ctermfg=4 ctermbg=0 ctermul=NONE gui=NONE guifg=#0080bd guibg=#1d221f guisp=NONE
	hi SignatureMarkText term=bold cterm=bold ctermfg=7 ctermbg=8 ctermul=NONE gui=bold guifg=#e6e1d1 guibg=#29302b guisp=NONE
	hi pandocLinkDefinition term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=14 gui=NONE guifg=#00886a guibg=NONE guisp=#8c8a7d
	hi pandocLinkTitleDelim term=NONE cterm=NONE ctermfg=12 ctermbg=NONE ctermul=14 gui=NONE guifg=#6d736d guibg=NONE guisp=#8c8a7d
	hi StatusLineLeft term=bold cterm=bold ctermfg=0 ctermbg=2 gui=bold guifg=#1d221f guibg=#309c00
	hi StatusLineRight term=bold cterm=bold ctermfg=0 ctermbg=3 gui=bold guifg=#1d221f guibg=#b48000
	hi StatusGit term=bold cterm=bold ctermfg=0 ctermbg=10 gui=bold guifg=#1d221f guibg=#00886a
	hi helpExample term=NONE cterm=NONE ctermfg=14 ctermbg=NONE ctermul=NONE gui=NONE guifg=#8c8a7d guibg=NONE guisp=NONE
else # light
	if has('gui_running')
		hi Normal term=NONE cterm=NONE ctermfg=8 ctermbg=15 ctermul=NONE gui=NONE guifg=#29302b guibg=#f7f2e1 guisp=NONE
	else
		if !&termguicolors
			set t_Co=16
		endif
		if get(suiboku, 'transparent', true)
			hi Normal term=NONE cterm=NONE ctermfg=8 ctermbg=NONE ctermul=NONE gui=NONE guifg=#29302b guibg=NONE guisp=NONE
		else
			hi Normal term=NONE cterm=NONE ctermfg=8 ctermbg=15 ctermul=NONE gui=NONE guifg=#29302b guibg=#f7f2e1 guisp=NONE
		endif
	endif
	if italic
		hi Comment term=italic cterm=italic ctermfg=12 ctermbg=NONE ctermul=NONE gui=italic guifg=#6d736d guibg=NONE guisp=NONE
		hi ErrorMsg term=italic,reverse,bold cterm=reverse ctermfg=1 ctermbg=0 ctermul=NONE gui=reverse guifg=#dc322f guibg=#1d221f guisp=NONE
		hi Folded term=italic,underline,reverse cterm=bold ctermfg=12 ctermbg=7 ctermul=NONE gui=bold guifg=#6d736d guibg=#e6e1d1 guisp=NONE
		hi TabLine term=italic,underline cterm=italic,underline ctermfg=12 ctermbg=7 ctermul=NONE gui=italic,underline guifg=#6d736d guibg=#e6e1d1 guisp=NONE
	else
		hi Comment term=NONE cterm=NONE ctermfg=12 ctermbg=NONE ctermul=NONE gui=NONE guifg=#6d736d guibg=NONE guisp=NONE
		hi ErrorMsg term=reverse,bold cterm=reverse ctermfg=1 ctermbg=0 ctermul=NONE gui=reverse guifg=#dc322f guibg=#1d221f guisp=NONE
		hi Folded term=underline,reverse cterm=bold ctermfg=12 ctermbg=7 ctermul=NONE gui=bold guifg=#6d736d guibg=#e6e1d1 guisp=NONE
		hi TabLine term=underline cterm=underline ctermfg=12 ctermbg=7 ctermul=NONE gui=underline guifg=#6d736d guibg=#e6e1d1 guisp=NONE
	endif
	hi ColorColumn term=reverse cterm=NONE ctermfg=NONE ctermbg=7 ctermul=NONE gui=NONE guifg=NONE guibg=#e6e1d1 guisp=NONE
	hi Cursor term=NONE cterm=NONE ctermfg=7 ctermbg=12 ctermul=NONE gui=NONE guifg=#e6e1d1 guibg=#6d736d guisp=NONE
	hi CursorColumn term=reverse cterm=NONE ctermfg=NONE ctermbg=7 ctermul=NONE gui=NONE guifg=NONE guibg=#e6e1d1 guisp=NONE
	hi CursorLine term=NONE cterm=NONE ctermfg=NONE ctermbg=7 ctermul=NONE gui=NONE guifg=NONE guibg=#e6e1d1 guisp=NONE
	hi DiffAdd term=underline,reverse cterm=NONE ctermfg=2 ctermbg=7 ctermul=2 gui=NONE guifg=#309c00 guibg=#e6e1d1 guisp=#309c00
	hi DiffChange term=underline,reverse cterm=NONE ctermfg=3 ctermbg=7 ctermul=3 gui=NONE guifg=#b48000 guibg=#e6e1d1 guisp=#b48000
	hi DiffDelete term=underline,reverse cterm=bold ctermfg=1 ctermbg=7 ctermul=NONE gui=bold guifg=#dc322f guibg=#e6e1d1 guisp=NONE
	hi DiffText term=bold,underline,reverse cterm=NONE ctermfg=4 ctermbg=7 ctermul=4 gui=bold guifg=#0080bd guibg=#e6e1d1 guisp=#0080bd
	hi Error term=bold cterm=reverse,bold ctermfg=1 ctermbg=0 ctermul=NONE gui=reverse,bold guifg=#dc322f guibg=#1d221f guisp=NONE
	hi FoldColumn term=reverse cterm=NONE ctermfg=12 ctermbg=7 ctermul=NONE gui=NONE guifg=#6d736d guibg=#e6e1d1 guisp=NONE
	hi LineNr term=reverse cterm=NONE ctermfg=14 ctermbg=7 ctermul=NONE gui=NONE guifg=#8c8a7d guibg=#e6e1d1 guisp=NONE
	hi NonText term=bold cterm=bold ctermfg=14 ctermbg=NONE ctermul=NONE gui=bold guifg=#8c8a7d guibg=NONE guisp=NONE
	hi Pmenu term=NONE cterm=NONE ctermfg=12 ctermbg=15 ctermul=NONE gui=NONE guifg=#6d736d guibg=#f7f2e1 guisp=NONE
	hi PmenuSel term=NONE cterm=NONE ctermfg=0 ctermbg=7 ctermul=NONE gui=NONE guifg=#1d221f guibg=#e6e1d1 guisp=NONE
	hi PmenuSbar term=reverse cterm=NONE ctermfg=NONE ctermbg=14 ctermul=NONE gui=NONE guifg=NONE guibg=#8c8a7d guisp=NONE
	hi PmenuThumb term=reverse cterm=NONE ctermfg=NONE ctermbg=12 ctermul=NONE gui=NONE guifg=NONE guibg=#6d736d guisp=NONE
	hi SignColumn term=reverse cterm=NONE ctermfg=12 ctermbg=7 ctermul=NONE gui=NONE guifg=#6d736d guibg=#e6e1d1 guisp=NONE
	hi SpecialKey term=bold cterm=bold ctermfg=14 ctermbg=7 ctermul=NONE gui=bold guifg=#8c8a7d guibg=#e6e1d1 guisp=NONE
	hi StatusLine term=bold cterm=bold ctermfg=15 ctermbg=12 ctermul=NONE gui=bold guifg=#f7f2e1 guibg=#6d736d guisp=NONE
	hi StatusLineNC term=NONE cterm=NONE ctermfg=7 ctermbg=14 ctermul=NONE gui=NONE guifg=#e6e1d1 guibg=#8c8a7d guisp=NONE
	hi TabLineSel term=underline,bold cterm=underline,bold ctermfg=8 ctermbg=15 ctermul=NONE gui=underline,bold guifg=#29302b guibg=#f7f2e1 guisp=NONE
	hi ToolbarButton term=bold,reverse cterm=bold ctermfg=14 ctermbg=15 ctermul=NONE gui=bold guifg=#8c8a7d guibg=#f7f2e1 guisp=NONE
	hi ToolbarLine term=reverse cterm=NONE ctermfg=NONE ctermbg=15 ctermul=NONE gui=NONE guifg=NONE guibg=#f7f2e1 guisp=NONE
	hi VertSplit term=NONE cterm=NONE ctermfg=14 ctermbg=14 ctermul=NONE gui=NONE guifg=#8c8a7d guibg=#8c8a7d guisp=NONE
	hi Visual term=reverse cterm=reverse ctermfg=12 ctermbg=15 ctermul=NONE gui=reverse guifg=#6d736d guibg=#f7f2e1 guisp=NONE
	hi VisualNOS term=reverse cterm=reverse ctermfg=NONE ctermbg=7 ctermul=NONE gui=reverse guifg=NONE guibg=#e6e1d1 guisp=NONE
	hi WildMenu term=reverse cterm=reverse ctermfg=8 ctermbg=7 ctermul=NONE gui=reverse guifg=#29302b guibg=#e6e1d1 guisp=NONE
	hi ALEErrorSign term=NONE cterm=bold ctermfg=1 ctermbg=15 ctermul=NONE gui=bold guifg=#dc322f guibg=#f7f2e1 guisp=NONE
	hi ALEErrorSignLineNr term=NONE cterm=NONE ctermfg=7 ctermbg=1 ctermul=NONE gui=NONE guifg=#e6e1d1 guibg=#dc322f guisp=NONE
	hi ALEInfoSign term=NONE cterm=bold ctermfg=10 ctermbg=15 ctermul=NONE gui=bold guifg=#00886a guibg=#f7f2e1 guisp=NONE
	hi ALEInfoSignLineNr term=NONE cterm=NONE ctermfg=7 ctermbg=10 ctermul=NONE gui=NONE guifg=#e6e1d1 guibg=#00886a guisp=NONE
	hi ALEWarningSign term=NONE cterm=bold ctermfg=3 ctermbg=15 ctermul=NONE gui=bold guifg=#b48000 guibg=#f7f2e1 guisp=NONE
	hi ALEWarningSignLineNr term=NONE cterm=NONE ctermfg=7 ctermbg=3 ctermul=NONE gui=NONE guifg=#e6e1d1 guibg=#b48000 guisp=NONE
	hi GitGutterAddInvisible term=reverse cterm=NONE ctermfg=7 ctermbg=12 ctermul=NONE gui=NONE guifg=#e6e1d1 guibg=#6d736d guisp=NONE
	hi GlyphPalette0 term=NONE cterm=NONE ctermfg=7 ctermbg=NONE ctermul=NONE gui=NONE guifg=#e6e1d1 guibg=NONE guisp=NONE
	hi GlyphPalette7 term=NONE cterm=NONE ctermfg=8 ctermbg=NONE ctermul=NONE gui=NONE guifg=#29302b guibg=NONE guisp=NONE
	hi GlyphPalette8 term=NONE cterm=NONE ctermfg=7 ctermbg=NONE ctermul=NONE gui=NONE guifg=#e6e1d1 guibg=NONE guisp=NONE
	hi GlyphPalette15 term=NONE cterm=NONE ctermfg=8 ctermbg=NONE ctermul=NONE gui=NONE guifg=#29302b guibg=NONE guisp=NONE
	hi pandocTableZebraDark term=NONE cterm=NONE ctermfg=4 ctermbg=15 ctermul=NONE gui=NONE guifg=#0080bd guibg=#f7f2e1 guisp=NONE
	hi pandocTableZebraLight term=NONE cterm=NONE ctermfg=4 ctermbg=7 ctermul=NONE gui=NONE guifg=#0080bd guibg=#e6e1d1 guisp=NONE
	hi SignatureMarkText term=bold cterm=bold ctermfg=8 ctermbg=15 ctermul=NONE gui=bold guifg=#29302b guibg=#f7f2e1 guisp=NONE
	hi pandocLinkDefinition term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=12 gui=NONE guifg=#00886a guibg=NONE guisp=#6d736d
	hi pandocLinkTitleDelim term=NONE cterm=NONE ctermfg=12 ctermbg=NONE ctermul=12 gui=NONE guifg=#6d736d guibg=NONE guisp=#6d736d
	hi StatusLineLeft term=bold cterm=bold ctermfg=15 ctermbg=2 gui=bold guifg=#f7f2e1 guibg=#309c00
	hi StatusLineRight term=bold cterm=bold ctermfg=15 ctermbg=3 gui=bold guifg=#f7f2e1 guibg=#b48000
	hi StatusGit term=bold cterm=bold ctermfg=7 ctermbg=10 gui=bold guifg=#e6e1d1 guibg=#00886a
	hi helpExample term=NONE cterm=NONE ctermfg=12 ctermbg=NONE ctermul=NONE gui=NONE guifg=#6d736d guibg=NONE guisp=NONE
endif
# common {{{
if italic
	hi Changed term=italic,bold cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b48000 guibg=NONE guisp=NONE
	hi Constant term=italic,bold cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#00886a guibg=NONE guisp=NONE
	hi Boolean term=italic,bold cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#4f5fff guibg=NONE guisp=NONE
	hi CursorLineNr term=bold,italic,reverse,underline cterm=bold ctermfg=3 ctermbg=NONE ctermul=NONE gui=bold guifg=#b48000 guibg=NONE guisp=NONE
	hi Identifier term=italic cterm=NONE ctermfg=13 ctermbg=NONE ctermul=NONE gui=NONE guifg=#966fe1 guibg=NONE guisp=NONE
	hi Function term=italic cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#0080bd guibg=NONE guisp=NONE
	hi IncSearch term=italic,standout cterm=standout ctermfg=11 ctermbg=NONE ctermul=NONE gui=standout guifg=#e65310 guibg=NONE guisp=NONE
	hi PreProc term=italic cterm=NONE ctermfg=11 ctermbg=NONE ctermul=NONE gui=NONE guifg=#e65310 guibg=NONE guisp=NONE
	hi Search term=italic,reverse cterm=reverse ctermfg=3 ctermbg=NONE ctermul=NONE gui=reverse guifg=#b48000 guibg=NONE guisp=NONE
	hi Special term=italic,bold cterm=NONE ctermfg=9 ctermbg=NONE ctermul=NONE gui=NONE guifg=#ff786e guibg=NONE guisp=NONE
	hi SpellBad term=underline,italic cterm=underline,italic ctermfg=NONE ctermbg=NONE ctermul=11 gui=undercurl guifg=NONE guibg=NONE guisp=#e65310
	hi SpellCap term=underline,italic cterm=underline,italic ctermfg=NONE ctermbg=NONE ctermul=13 gui=undercurl guifg=NONE guibg=NONE guisp=#966fe1
	hi SpellLocal term=underline,italic cterm=underline,italic ctermfg=NONE ctermbg=NONE ctermul=3 gui=undercurl guifg=NONE guibg=NONE guisp=#b48000
	hi SpellRare term=underline,italic cterm=underline,italic ctermfg=NONE ctermbg=NONE ctermul=4 gui=undercurl guifg=NONE guibg=NONE guisp=#0080bd
	hi pandocEmphasis term=italic cterm=italic ctermfg=6 ctermbg=NONE ctermul=NONE gui=italic guifg=#4f5fff guibg=NONE guisp=NONE
	hi pandocEmphasisDefinition term=italic cterm=italic ctermfg=13 ctermbg=NONE ctermul=NONE gui=italic guifg=#966fe1 guibg=NONE guisp=NONE
	hi pandocEmphasisTable term=italic cterm=italic ctermfg=4 ctermbg=NONE ctermul=NONE gui=italic guifg=#0080bd guibg=NONE guisp=NONE
else
	hi Changed term=bold cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b48000 guibg=NONE guisp=NONE
	hi Constant term=bold cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#00886a guibg=NONE guisp=NONE
	hi Boolean term=bold cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#4f5fff guibg=NONE guisp=NONE
	hi CursorLineNr term=bold,reverse,underline cterm=bold ctermfg=3 ctermbg=NONE ctermul=NONE gui=bold guifg=#b48000 guibg=NONE guisp=NONE
	hi Identifier term=NONE cterm=NONE ctermfg=13 ctermbg=NONE ctermul=NONE gui=NONE guifg=#966fe1 guibg=NONE guisp=NONE
	hi Function term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#0080bd guibg=NONE guisp=NONE
	hi IncSearch term=standout cterm=standout ctermfg=11 ctermbg=NONE ctermul=NONE gui=standout guifg=#e65310 guibg=NONE guisp=NONE
	hi PreProc term=NONE cterm=NONE ctermfg=11 ctermbg=NONE ctermul=NONE gui=NONE guifg=#e65310 guibg=NONE guisp=NONE
	hi Search term=reverse cterm=reverse ctermfg=3 ctermbg=NONE ctermul=NONE gui=reverse guifg=#b48000 guibg=NONE guisp=NONE
	hi Special term=bold cterm=NONE ctermfg=9 ctermbg=NONE ctermul=NONE gui=NONE guifg=#ff786e guibg=NONE guisp=NONE
	hi SpellBad term=underline cterm=underline ctermfg=NONE ctermbg=NONE ctermul=11 gui=undercurl guifg=NONE guibg=NONE guisp=#e65310
	hi SpellCap term=underline cterm=underline ctermfg=NONE ctermbg=NONE ctermul=13 gui=undercurl guifg=NONE guibg=NONE guisp=#966fe1
	hi SpellLocal term=underline cterm=underline ctermfg=NONE ctermbg=NONE ctermul=3 gui=undercurl guifg=NONE guibg=NONE guisp=#b48000
	hi SpellRare term=underline cterm=underline ctermfg=NONE ctermbg=NONE ctermul=4 gui=undercurl guifg=NONE guibg=NONE guisp=#0080bd
	hi pandocEmphasis term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#4f5fff guibg=NONE guisp=NONE
	hi pandocEmphasisDefinition term=NONE cterm=NONE ctermfg=13 ctermbg=NONE ctermul=NONE gui=NONE guifg=#966fe1 guibg=NONE guisp=NONE
	hi pandocEmphasisTable term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#0080bd guibg=NONE guisp=NONE
endif
hi Added term=bold cterm=NONE ctermfg=2 ctermbg=NONE ctermul=NONE gui=NONE guifg=#309c00 guibg=NONE guisp=NONE
hi Bold term=bold cterm=bold ctermul=NONE gui=bold guisp=NONE
hi BoldItalic term=bold,italic cterm=bold,italic ctermul=NONE gui=bold,italic guisp=NONE
hi ComplMatchIns term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE ctermul=NONE gui=NONE guifg=NONE guibg=NONE guisp=NONE
hi Conceal term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#0080bd guibg=NONE guisp=NONE
hi CursorIM term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE ctermul=NONE gui=NONE guifg=NONE guibg=NONE guisp=NONE
hi Directory term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#0080bd guibg=NONE guisp=NONE
hi Ignore term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE ctermul=NONE gui=NONE guifg=NONE guibg=NONE guisp=NONE
hi Italic term=italic cterm=italic ctermul=NONE gui=italic guisp=NONE
hi lCursor term=NONE cterm=NONE ctermfg=NONE ctermbg=fg ctermul=NONE gui=NONE guifg=NONE guibg=fg guisp=NONE
hi MatchParen term=reverse,bold cterm=reverse,bold ctermfg=NONE ctermbg=NONE ctermul=NONE gui=reverse,bold guifg=NONE guibg=NONE guisp=NONE
hi ModeMsg term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#0080bd guibg=NONE guisp=NONE
hi MoreMsg term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#0080bd guibg=NONE guisp=NONE
hi MsgArea term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE ctermul=NONE gui=NONE guifg=NONE guibg=NONE guisp=NONE
hi Question term=bold cterm=bold ctermfg=10 ctermbg=NONE ctermul=NONE gui=bold guifg=#00886a guibg=NONE guisp=NONE
hi Removed term=reverse,strikethrough cterm=NONE ctermfg=1 ctermbg=NONE ctermul=NONE gui=NONE guifg=#dc322f guibg=NONE guisp=NONE
hi Statement term=NONE cterm=NONE ctermfg=2 ctermbg=NONE ctermul=NONE gui=NONE guifg=#309c00 guibg=NONE guisp=NONE
hi Title term=bold cterm=bold ctermfg=11 ctermbg=NONE ctermul=NONE gui=bold guifg=#e65310 guibg=NONE guisp=NONE
hi Todo term=underline,bold cterm=bold ctermfg=5 ctermbg=NONE ctermul=NONE gui=bold guifg=#e14096 guibg=NONE guisp=NONE
hi Type term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b48000 guibg=NONE guisp=NONE
hi Underlined term=underline cterm=underline ctermfg=13 ctermbg=NONE ctermul=NONE gui=underline guifg=#966fe1 guibg=NONE guisp=NONE
hi WarningMsg term=bold cterm=bold ctermfg=11 ctermbg=NONE ctermul=NONE gui=bold guifg=#e65310 guibg=NONE guisp=NONE
hi ALEError term=underline cterm=underline ctermfg=1 ctermbg=NONE ctermul=1 gui=undercurl guifg=#dc322f guibg=NONE guisp=#dc322f
hi ALEInfo term=underline cterm=underline ctermfg=10 ctermbg=NONE ctermul=10 gui=undercurl guifg=#00886a guibg=NONE guisp=#00886a
hi ALEWarning term=NONE cterm=underline ctermfg=3 ctermbg=NONE ctermul=3 gui=undercurl guifg=#b48000 guibg=NONE guisp=#b48000
hi cPreCondit term=NONE cterm=NONE ctermfg=11 ctermbg=NONE ctermul=NONE gui=NONE guifg=#e65310 guibg=NONE guisp=NONE
hi gitcommitDiscardedFile term=NONE cterm=bold ctermfg=1 ctermbg=NONE ctermul=NONE gui=bold guifg=#dc322f guibg=NONE guisp=NONE
hi gitcommitFile term=NONE cterm=bold ctermfg=13 ctermbg=NONE ctermul=NONE gui=bold guifg=#966fe1 guibg=NONE guisp=NONE
hi gitcommitOnBranch term=NONE cterm=bold ctermfg=12 ctermbg=NONE ctermul=NONE gui=bold guifg=#6d736d guibg=NONE guisp=NONE
hi gitcommitSelectedFile term=NONE cterm=bold ctermfg=2 ctermbg=NONE ctermul=NONE gui=bold guifg=#309c00 guibg=NONE guisp=NONE
hi gitcommitUnmergedFile term=NONE cterm=bold ctermfg=3 ctermbg=NONE ctermul=NONE gui=bold guifg=#b48000 guibg=NONE guisp=NONE
hi gitcommitUntrackedFile term=NONE cterm=bold ctermfg=10 ctermbg=NONE ctermul=NONE gui=bold guifg=#00886a guibg=NONE guisp=NONE
hi helpNote term=NONE cterm=NONE ctermfg=5 ctermbg=NONE ctermul=NONE gui=NONE guifg=#e14096 guibg=NONE guisp=NONE
hi helpOption term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#00886a guibg=NONE guisp=NONE
hi hs_DeclareFunction term=NONE cterm=NONE ctermfg=11 ctermbg=NONE ctermul=NONE gui=NONE guifg=#e65310 guibg=NONE guisp=NONE
hi htmlTagN term=NONE cterm=bold ctermfg=14 ctermbg=NONE ctermul=NONE gui=bold guifg=#8c8a7d guibg=NONE guisp=NONE
hi htmlTagName term=NONE cterm=bold ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#0080bd guibg=NONE guisp=NONE
hi pandocDefinitionBlock term=NONE cterm=NONE ctermfg=13 ctermbg=NONE ctermul=NONE gui=NONE guifg=#966fe1 guibg=NONE guisp=NONE
hi pandocDefinitionTerm term=NONE cterm=standout ctermfg=13 ctermbg=NONE ctermul=NONE gui=standout guifg=#966fe1 guibg=NONE guisp=NONE
hi pandocEmphasisHeading term=NONE cterm=bold ctermfg=11 ctermbg=NONE ctermul=NONE gui=bold guifg=#e65310 guibg=NONE guisp=NONE
hi pandocEmphasisNested term=NONE cterm=bold ctermfg=6 ctermbg=NONE ctermul=NONE gui=bold guifg=#4f5fff guibg=NONE guisp=NONE
hi pandocNonBreakingSpace term=NONE cterm=reverse ctermfg=1 ctermbg=NONE ctermul=NONE gui=reverse guifg=#dc322f guibg=NONE guisp=NONE
hi pandocStrikeout term=NONE cterm=reverse ctermfg=12 ctermbg=NONE ctermul=NONE gui=reverse guifg=#6d736d guibg=NONE guisp=NONE
hi pandocStrikeoutDefinition term=NONE cterm=reverse ctermfg=13 ctermbg=NONE ctermul=NONE gui=reverse guifg=#966fe1 guibg=NONE guisp=NONE
hi pandocStrikeoutHeading term=NONE cterm=reverse ctermfg=11 ctermbg=NONE ctermul=NONE gui=reverse guifg=#e65310 guibg=NONE guisp=NONE
hi pandocStrikeoutTable term=NONE cterm=reverse ctermfg=4 ctermbg=NONE ctermul=NONE gui=reverse guifg=#0080bd guibg=NONE guisp=NONE
hi rubyDefine term=NONE cterm=bold ctermfg=14 ctermbg=NONE ctermul=NONE gui=bold guifg=#8c8a7d guibg=NONE guisp=NONE
hi SignatureMarkerText term=NONE cterm=NONE ctermfg=2 ctermbg=8 ctermul=NONE gui=NONE guifg=#309c00 guibg=#29302b guisp=NONE
hi! link Character Constant
hi! link Conditional Statement
hi! link CurSearch IncSearch
hi! link CursorLineFold FoldColumn
hi! link CursorLineSign SignColumn
hi! link Debug Special
hi! link Define PreProc
hi! link Delimiter Special
hi! link DiffTextAdd DiffText
hi! link EndOfBuffer NonText
hi! link Exception Statement
hi! link Float Number
hi! link Include PreProc
hi! link Keyword Statement
hi! link Label Statement
hi! link LineNrAbove LineNr
hi! link LineNrBelow LineNr
hi! link Macro PreProc
hi! link MessageWindow WarningMsg
hi! link Number Constant
hi! link Operator Statement
hi! link PmenuExtra Pmenu
hi! link PmenuExtraSel PmenuSel
hi! link PmenuKind Pmenu
hi! link PmenuKindSel PmenuSel
hi! link PmenuMatch Type
hi! link PmenuMatchSel Type
hi! link PopupNotification WarningMsg
hi! link PopupSelected PmenuSel
hi! link PreCondit PreProc
hi! link PopupSelected Added
hi! link QuickFixLine CursorLine
hi! link Repeat Statement
hi! link SpecialChar Special
hi! link SpecialComment Special
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineNC
hi! link StorageClass Type
hi! link String Constant
hi! link Structure Type
hi! link TabLineFill TabLine
hi! link TabPanel TabLine
hi! link TabPanelFill TabLineFill
hi! link TabPanelSel TabLineSel
hi! link Tag Special
hi! link Terminal Normal
hi! link Typedef Type
hi! link ConId Type
hi! link gitcommitBranch Todo
hi! link gitcommitComment Comment
hi! link gitcommitdiscardedtype Removed
hi! link gitcommitHeader helpExample
hi! link gitcommitselectedtype Statement
hi! link gitcommitUnmerged gitcommitSelectedFile
hi! link GitGutterAdd DiffAdd
hi! link GitGutterChange DiffChange
hi! link GitGutterChangeInvisible GitGutterAddInvisible
hi! link GitGutterDelete DiffDelete
hi! link GitGutterDeleteInvisible GitGutterAddInvisible
hi! link GlyphPalette1 Removed
hi! link GlyphPalette2 Statement
hi! link GlyphPalette3 Type
hi! link GlyphPalette4 Conceal
hi! link GlyphPalette5 helpNote
hi! link GlyphPalette6 helpOption
hi! link GlyphPalette9 hs_DeclareFunction
hi! link GlyphPalette10 helpExample
hi! link GlyphPalette11 Special
hi! link GlyphPalette12 Boolean
hi! link GlyphPalette13 pandocDefinitionBlock
hi! link GlyphPalette14 Todo
hi! link helpHyperTextEntry Statement
hi! link helpHyperTextJump Conceal
hi! link helpSpecial Special
hi! link helpVim helpNote
hi! link hs_hlFunctionName Conceal
hi! link hs_OpFunctionName Type
hi! link hsImport helpNote
hi! link hsImportLabel helpOption
hi! link hsModuleName Statement
hi! link hsNiceOperator helpOption
hi! link hsStatement helpOption
hi! link hsString helpExample
hi! link hsStructure helpOption
hi! link hsType Type
hi! link hsTypedef helpOption
hi! link hsVarSym helpOption
hi! link htmlArg helpExample
hi! link htmlEndTag helpExample
hi! link htmlSpecialTagName Tag
hi! link htmlTag helpExample
hi! link javaScript Type
hi! link pandocBlockQuote Conceal
hi! link pandocBlockQuoteLeader1 Conceal
hi! link pandocBlockQuoteLeader2 helpOption
hi! link pandocBlockQuoteLeader3 Type
hi! link pandocBlockQuoteLeader4 Removed
hi! link pandocBlockQuoteLeader5 pandocEmphasisNested
hi! link pandocBlockQuoteLeader6 helpExample
hi! link pandocCitation helpNote
hi! link pandocCitationDelim helpNote
hi! link pandocCitationID helpNote
hi! link pandocCitationRef helpNote
hi! link pandocComment Comment
hi! link pandocDefinitionIndctr gitcommitFile
hi! link pandocEmphasisNestedDefinition gitcommitFile
hi! link pandocEmphasisNestedHeading pandocEmphasisHeading
hi! link pandocEmphasisNestedTable htmlTagName
hi! link pandocEscapePair gitcommitDiscardedFile
hi! link pandocFootnote Statement
hi! link pandocFootnoteDefLink gitcommitSelectedFile
hi! link pandocFootnoteInline gitcommitSelectedFile
hi! link pandocFootnoteLink Statement
hi! link pandocHeading pandocEmphasisHeading
hi! link pandocHeadingMarker pandocEmphasisHeading
hi! link pandocImageCaption gitcommitFile
hi! link pandocLinkDefinitionID htmlTagName
hi! link pandocLinkDelim helpExample
hi! link pandocLinkLabel Conceal
hi! link pandocLinkText Conceal
hi! link pandocLinkTitle helpExample
hi! link pandocLinkURL helpExample
hi! link pandocListMarker helpNote
hi! link pandocListReference helpNote
hi! link pandocMetadata htmlTagName
hi! link pandocMetadataDelim helpExample
hi! link pandocMetadataKey Conceal
hi! link pandocRule htmlTagName
hi! link pandocRuleLine htmlTagName
hi! link pandocStrongEmphasis pandocEmphasisNested
hi! link pandocStrongEmphasisDefinition gitcommitFile
hi! link pandocStrongEmphasisEmphasis pandocEmphasisNested
hi! link pandocStrongEmphasisEmphasisDefinition gitcommitFile
hi! link pandocStrongEmphasisEmphasisHeading pandocEmphasisHeading
hi! link pandocStrongEmphasisEmphasisTable htmlTagName
hi! link pandocStrongEmphasisHeading pandocEmphasisHeading
hi! link pandocStrongEmphasisNested pandocEmphasisNested
hi! link pandocStrongEmphasisNestedDefinition gitcommitFile
hi! link pandocStrongEmphasisNestedHeading pandocEmphasisHeading
hi! link pandocStrongEmphasisNestedTable htmlTagName
hi! link pandocStrongEmphasisTable htmlTagName
hi! link pandocStyleDelim helpExample
hi! link pandocSubscript pandocDefinitionBlock
hi! link pandocSubscriptDefinition pandocDefinitionBlock
hi! link pandocSubscriptHeading pandocEmphasisHeading
hi! link pandocSubscriptTable Conceal
hi! link pandocSuperscript pandocDefinitionBlock
hi! link pandocSuperscriptDefinition pandocDefinitionBlock
hi! link pandocSuperscriptHeading pandocEmphasisHeading
hi! link pandocSuperscriptTable Conceal
hi! link pandocTable Conceal
hi! link pandocTableStructure Conceal
hi! link pandocTitleBlock Conceal
hi! link pandocTitleBlockTitle htmlTagName
hi! link pandocTitleComment htmlTagName
hi! link pandocVerbatimBlock Type
hi! link pandocVerbatimInline Type
hi! link pandocVerbatimInlineDefinition pandocDefinitionBlock
hi! link pandocVerbatimInlineHeading pandocEmphasisHeading
hi! link pandocVerbatimInlineTable Conceal
hi! link perlHereDoc helpExample
hi! link perlStatementFileDesc helpOption
hi! link perlVarPlain Type
hi! link rubyBoolean Boolean
hi! link rubyBoolean helpNote
hi! link rubyDefine Define
hi! link VarId Conceal
hi! link vimCmdSep htmlTagName
hi! link vimCommand Statement
hi! link vimCommentString String
hi! link vimGroup htmlTagName
hi! link vimHiGroup Conceal
hi! link vimHiLink Conceal
hi! link vimIsCommand helpExample
hi! link vimSynMtchOpt Type
hi! link vimSynType helpOption
