vim9script
scriptencoding utf-8

hi clear
g:colors_name = 'solarized9'

g:terminal_ansi_colors = [
	'#073642', # base02   | 0
	'#dc322f', # red      | 1
	'#859900', # green    | 2
	'#b58900', # yellow   | 3
	'#268bd2', # blue     | 4
	'#d33682', # magenta  | 5
	'#2aa198', # cyan     | 6
	'#eee8d5', # base2    | 7
	'#002b36', # base03   | 8
	'#cb4b16', # orange   | 9
	'#586e75', # base01   | 10
	'#b3ad00', # Citrine  | 11
	'#26ab7b', # Viridian | 12
	'#6c71c4', # violet   | 13
	'#93a1a1', # base1    | 14
	'#fdf6e3'  # base3    | 15
]
	# 元は
	# '#657b83',	#	base00	11	Cyan
	# '#839496',	#	base0 	12	Red

if !&termguicolors
	set t_Co=16
endif

def HlReverce(name: string, hl: string): dict<any>
	var h: dict<any> = hlget(hl)[0]
	def HlGetDic(s: string): dict<bool>
		return get(h, s, {})
	enddef
	def HlGetStr(s: string): string
		return get(h, s, get(hlget('Normal')[0], s, 'NONE'))
	enddef
	return {
		name: name,
		term: HlGetDic('term'),
		cterm: HlGetDic('cterm'),
		ctermbg: HlGetStr('ctermfg'),
		ctermfg: HlGetStr('ctermbg'),
		ctermul: HlGetStr('ctermul'),
		gui: HlGetDic('gui'),
		guibg: HlGetStr('guifg'),
		guifg: HlGetStr('guibg'),
		guisp: HlGetStr('guisp')
	}
enddef
var solarized9 = get(g:, 'solarized9', {italic: false, transparent: true})
var italic = get(solarized9, 'italic', false)

if &background ==# 'dark'
	if has('gui_running')
		hi Normal term=NONE cterm=NONE gui=NONE ctermfg=7 guifg=#eee8d5 ctermbg=8 guibg=#002b36 ctermul=NONE guisp=NONE
	else
		if !&termguicolors
			set t_Co=16
		endif
		if get(get(g:, 'solarized9', {}), 'transparent', true)
			hi Normal term=NONE cterm=NONE gui=NONE ctermfg=7 guifg=#eee8d5 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
		else
			hi Normal term=NONE cterm=NONE gui=NONE ctermfg=7 guifg=#eee8d5 ctermbg=8 guibg=#002b36 ctermul=NONE guisp=NONE
		endif
	endif
	if italic
		hi Comment term=italic cterm=italic ctermfg=14 ctermbg=NONE ctermul=NONE gui=italic guifg=#93a1a1 guibg=NONE guisp=NONE
		hi Folded term=italic,reverse,underline cterm=bold ctermfg=14 ctermbg=0 ctermul=NONE gui=bold guifg=#93a1a1 guibg=#073642 guisp=NONE
		hi TabLine term=italic,underline cterm=italic,underline ctermfg=14 ctermbg=0 ctermul=NONE gui=italic,underline guifg=#93a1a1 guibg=#073642 guisp=NONE
	else
		hi Comment term=NONE cterm=NONE ctermfg=14 ctermbg=NONE ctermul=NONE gui=NONE guifg=#93a1a1 guibg=NONE guisp=NONE
		hi Folded term=reverse,underline cterm=bold ctermfg=14 ctermbg=0 ctermul=NONE gui=bold guifg=#93a1a1 guibg=#073642 guisp=NONE
		hi TabLine term=underline cterm=underline ctermfg=14 ctermbg=0 ctermul=NONE gui=underline guifg=#93a1a1 guibg=#073642 guisp=NONE
	endif
	hi ColorColumn term=reverse cterm=NONE ctermfg=NONE ctermbg=0 ctermul=NONE gui=NONE guifg=NONE guibg=#073642 guisp=NONE
	hi Cursor term=NONE cterm=NONE ctermfg=8 ctermbg=14 ctermul=NONE gui=NONE guifg=#002b36 guibg=#93a1a1 guisp=NONE
	hi CursorColumn term=reverse cterm=NONE ctermfg=NONE ctermbg=0 ctermul=NONE gui=NONE guifg=NONE guibg=#073642 guisp=NONE
	hi CursorLine term=NONE cterm=NONE ctermfg=NONE ctermbg=0 ctermul=NONE gui=NONE guifg=NONE guibg=#073642 guisp=NONE
	hi DiffAdd term=underline,reverse cterm=NONE ctermfg=2 ctermbg=0 ctermul=2 gui=NONE guifg=#859900 guibg=#073642 guisp=#859900
	hi DiffChange term=underline,reverse cterm=NONE ctermfg=3 ctermbg=0 ctermul=3 gui=NONE guifg=#b58900 guibg=#073642 guisp=#b58900
	hi DiffDelete term=underline,reverse cterm=bold ctermfg=1 ctermbg=0 ctermul=NONE gui=bold guifg=#dc322f guibg=#073642 guisp=NONE
	hi DiffText term=bold,underline,reverse cterm=NONE ctermfg=4 ctermbg=0 ctermul=4 gui=bold guifg=#268bd2 guibg=#073642 guisp=#268bd2
	hi FoldColumn term=reverse cterm=NONE ctermfg=14 ctermbg=0 ctermul=NONE gui=NONE guifg=#93a1a1 guibg=#073642 guisp=NONE
	hi LineNr term=reverse cterm=NONE ctermfg=10 ctermbg=0 ctermul=NONE gui=NONE guifg=#586e75 guibg=#073642 guisp=NONE
	hi NonText term=bold cterm=bold ctermfg=14 ctermbg=NONE ctermul=NONE gui=bold guifg=#93a1a1 guibg=NONE guisp=NONE
	hi Pmenu term=NONE cterm=NONE ctermfg=14 ctermbg=0 ctermul=NONE gui=NONE guifg=#93a1a1 guibg=#073642 guisp=NONE
	hi PmenuSbar term=reverse cterm=NONE ctermfg=NONE ctermbg=10 ctermul=NONE gui=NONE guifg=NONE guibg=#586e75 guisp=NONE
	hi PmenuThumb term=reverse cterm=NONE ctermfg=NONE ctermbg=14 ctermul=NONE gui=NONE guifg=NONE guibg=#93a1a1 guisp=NONE
	hi SignColumn term=reverse cterm=NONE ctermfg=14 ctermbg=0 ctermul=NONE gui=NONE guifg=#93a1a1 guibg=#073642 guisp=NONE
	hi SpecialKey term=bold cterm=bold ctermfg=14 ctermbg=0 ctermul=NONE gui=bold guifg=#93a1a1 guibg=#073642 guisp=NONE
	hi StatusLine term=bold,reverse cterm=bold,reverse ctermfg=14 ctermbg=0 ctermul=NONE gui=bold,reverse guifg=#93a1a1 guibg=#073642 guisp=NONE
	hi StatusLineNC term=reverse cterm=reverse ctermfg=10 ctermbg=0 ctermul=NONE gui=reverse guifg=#586e75 guibg=#073642 guisp=NONE
	hi TabLineSel term=underline,bold cterm=underline,bold ctermfg=7 ctermbg=8 ctermul=NONE gui=underline,bold guifg=#eee8d5 guibg=#002b36 guisp=NONE
	hi ToolbarButton term=bold,reverse cterm=bold ctermfg=14 ctermbg=0 ctermul=NONE gui=bold guifg=#93a1a1 guibg=#073642 guisp=NONE
	hi ToolbarLine term=reverse cterm=NONE ctermfg=NONE ctermbg=0 ctermul=NONE gui=NONE guifg=NONE guibg=#073642 guisp=NONE
	hi VertSplit term=NONE cterm=NONE ctermfg=10 ctermbg=10 ctermul=NONE gui=NONE guifg=#586e75 guibg=#586e75 guisp=NONE
	hi Visual term=reverse cterm=reverse ctermfg=10 ctermbg=8 ctermul=NONE gui=reverse guifg=#93a1a1 guibg=#002b36 guisp=NONE
	hi VisualNOS term=reverse cterm=reverse ctermfg=NONE ctermbg=0 ctermul=NONE gui=reverse guifg=NONE guibg=#073642 guisp=NONE
	hi WildMenu term=bold cterm=reverse ctermfg=7 ctermbg=0 ctermul=NONE gui=reverse guifg=#eee8d5 guibg=#073642 guisp=NONE
	hi ALEErrorSign term=NONE cterm=bold ctermfg=1 ctermbg=0 ctermul=NONE gui=bold guifg=#dc322f guibg=#073642 guisp=NONE
	hi ALEErrorSignLineNr term=NONE cterm=NONE ctermfg=0 ctermbg=1 ctermul=NONE gui=NONE guifg=#073642 guibg=#dc322f guisp=NONE
	hi ALEInfoSign term=NONE cterm=bold ctermfg=6 ctermbg=0 ctermul=NONE gui=bold guifg=#2aa198 guibg=#073642 guisp=NONE
	hi ALEInfoSignLineNr term=NONE cterm=NONE ctermfg=0 ctermbg=6 ctermul=NONE gui=NONE guifg=#073642 guibg=#2aa198 guisp=NONE
	hi ALEWarningSign term=NONE cterm=bold ctermfg=3 ctermbg=0 ctermul=NONE gui=bold guifg=#b58900 guibg=#073642 guisp=NONE
	hi ALEWarningSignLineNr term=NONE cterm=NONE ctermfg=0 ctermbg=3 ctermul=NONE gui=NONE guifg=#073642 guibg=#b58900 guisp=NONE
	hi GlyphPalette0 term=NONE cterm=NONE ctermfg=0 ctermbg=NONE ctermul=NONE gui=NONE guifg=#073642 guibg=NONE guisp=NONE
	hi GlyphPalette15 term=NONE cterm=NONE ctermfg=15 ctermbg=NONE ctermul=NONE gui=NONE guifg=#fdf6e3 guibg=NONE guisp=NONE
	hi GlyphPalette7 term=NONE cterm=NONE ctermfg=7 ctermbg=NONE ctermul=NONE gui=NONE guifg=#eee8d5 guibg=NONE guisp=NONE
	hi GlyphPalette8 term=NONE cterm=NONE ctermfg=8 ctermbg=NONE ctermul=NONE gui=NONE guifg=#002b36 guibg=NONE guisp=NONE
	hi pandocTableZebraDark term=NONE cterm=NONE ctermfg=4 ctermbg=0 ctermul=NONE gui=NONE guifg=#268bd2 guibg=#073642 guisp=NONE
	hi pandocTableZebraLight term=NONE cterm=NONE ctermfg=4 ctermbg=8 ctermul=NONE gui=NONE guifg=#268bd2 guibg=#002b36 guisp=NONE
	hi SignatureMarkText term=bold cterm=bold ctermfg=15 ctermbg=0 ctermul=NONE gui=bold guifg=#fdf6e3 guibg=#073642 guisp=NONE
	hi vimIsCommand term=NONE cterm=NONE ctermfg=14 ctermbg=NONE ctermul=NONE gui=NONE guifg=#93a1a1 guibg=NONE guisp=NONE
	hi pandocLinkTitle term=NONE cterm=NONE ctermfg=14 ctermbg=NONE ctermul=NONE gui=NONE guifg=#93a1a1 guibg=NONE guisp=NONE
	hi hsString term=NONE cterm=NONE ctermfg=14 ctermbg=NONE ctermul=NONE gui=NONE guifg=#93a1a1 guibg=NONE guisp=NONE
	hi htmlArg term=NONE cterm=NONE ctermfg=14 ctermbg=NONE ctermul=NONE gui=NONE guifg=#93a1a1 guibg=NONE guisp=NONE
	hi pandocLinkDefinition term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=14 gui=NONE guifg=#2aa198 guibg=NONE guisp=#93a1a1
	hi pandocLinkTitleDelim term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=14 gui=NONE guifg=#586e75 guibg=NONE guisp=#93a1a1
	hi pandocLinkURL term=NONE cterm=NONE ctermfg=14 ctermbg=NONE ctermul=NONE gui=NONE guifg=#93a1a1 guibg=NONE guisp=NONE
	hi StatusLineLeft term=bold cterm=bold ctermfg=8 ctermbg=2 gui=bold guifg=#002b36 guibg=#859900
	hi StatusLineRight term=bold cterm=bold ctermfg=8 ctermbg=3 gui=bold guifg=#002b36 guibg=#b58900
	hi StatusGit term=bold cterm=bold ctermfg=8 ctermbg=6 gui=bold guifg=#002b36 guibg=#2aa198
else # light
	if has('gui_running')
		hi Normal term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
	else
		if !&termguicolors
			set t_Co=16
		endif
		if get(get(g:, 'solarized9', {}), 'transparent', true)
			hi Normal term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=NONE guibg=NONE ctermul=NONE guisp=NONE
		else
			hi Normal term=NONE cterm=NONE gui=NONE ctermfg=0 guifg=#073642 ctermbg=15 guibg=#fdf6e3 ctermul=NONE guisp=NONE
		endif
	endif
	if italic
		hi Comment term=italic cterm=italic ctermfg=10 ctermbg=NONE ctermul=NONE gui=italic guifg=#586e75 guibg=NONE guisp=NONE
		hi Folded term=italic,underline,reverse cterm=bold ctermfg=10 ctermbg=7 ctermul=NONE gui=bold guifg=#586e75 guibg=#eee8d5 guisp=NONE
		hi TabLine term=italic,underline cterm=italic,underline ctermfg=10 ctermbg=7 ctermul=NONE gui=italic,underline guifg=#586e75 guibg=#eee8d5 guisp=NONE
	else
		hi Comment term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
		hi Folded term=underline,reverse cterm=bold ctermfg=10 ctermbg=7 ctermul=NONE gui=bold guifg=#586e75 guibg=#eee8d5 guisp=NONE
		hi TabLine term=underline cterm=underline ctermfg=10 ctermbg=7 ctermul=NONE gui=underline guifg=#586e75 guibg=#eee8d5 guisp=NONE
	endif
	hi ColorColumn term=reverse cterm=NONE ctermfg=NONE ctermbg=7 ctermul=NONE gui=NONE guifg=NONE guibg=#eee8d5 guisp=NONE
	hi Cursor term=NONE cterm=NONE ctermfg=15 ctermbg=10 ctermul=NONE gui=NONE guifg=#fdf6e3 guibg=#586e75 guisp=NONE
	hi CursorColumn term=reverse cterm=NONE ctermfg=NONE ctermbg=7 ctermul=NONE gui=NONE guifg=NONE guibg=#eee8d5 guisp=NONE
	hi CursorLine term=NONE cterm=NONE ctermfg=NONE ctermbg=7 ctermul=NONE gui=NONE guifg=NONE guibg=#eee8d5 guisp=NONE
	hi DiffAdd term=underline,reverse cterm=NONE ctermfg=2 ctermbg=7 ctermul=2 gui=NONE guifg=#859900 guibg=#eee8d5 guisp=#859900
	hi DiffChange term=underline,reverse cterm=NONE ctermfg=3 ctermbg=7 ctermul=3 gui=NONE guifg=#b58900 guibg=#eee8d5 guisp=#b58900
	hi DiffDelete term=underline,reverse cterm=bold ctermfg=1 ctermbg=7 ctermul=NONE gui=bold guifg=#dc322f guibg=#eee8d5 guisp=NONE
	hi DiffText term=bold,underline,reverse cterm=NONE ctermfg=4 ctermbg=7 ctermul=4 gui=bold guifg=#268bd2 guibg=#eee8d5 guisp=#268bd2
	hi FoldColumn term=reverse cterm=NONE ctermfg=10 ctermbg=7 ctermul=NONE gui=NONE guifg=#586e75 guibg=#eee8d5 guisp=NONE
	hi LineNr term=reverse cterm=NONE ctermfg=14 ctermbg=7 ctermul=NONE gui=NONE guifg=#93a1a1 guibg=#eee8d5 guisp=NONE
	hi NonText term=bold cterm=bold ctermfg=14 ctermbg=NONE ctermul=NONE gui=bold guifg=#93a1a1 guibg=NONE guisp=NONE
	hi Pmenu term=NONE cterm=NONE ctermfg=0 ctermbg=7 ctermul=NONE gui=NONE guifg=#073642 guibg=#eee8d5 guisp=NONE
	hi PmenuSbar term=reverse cterm=NONE ctermfg=NONE ctermbg=14 ctermul=NONE gui=NONE guifg=NONE guibg=#93a1a1 guisp=NONE
	hi PmenuThumb term=reverse cterm=NONE ctermfg=NONE ctermbg=10 ctermul=NONE gui=NONE guifg=NONE guibg=#586e75 guisp=NONE
	hi SignColumn term=reverse cterm=NONE ctermfg=10 ctermbg=7 ctermul=NONE gui=NONE guifg=#586e75 guibg=#eee8d5 guisp=NONE
	hi SpecialKey term=bold cterm=bold ctermfg=14 ctermbg=7 ctermul=NONE gui=bold guifg=#93a1a1 guibg=#eee8d5 guisp=NONE
	hi StatusLine term=bold,reverse cterm=bold,reverse ctermfg=10 ctermbg=7 ctermul=NONE gui=bold,reverse guifg=#586e75 guibg=#eee8d5 guisp=NONE
	hi StatusLineNC term=reverse cterm=reverse ctermfg=14 ctermbg=7 ctermul=NONE gui=reverse guifg=#93a1a1 guibg=#eee8d5 guisp=NONE
	hi TabLineSel term=underline,bold cterm=underline,bold ctermfg=0 ctermbg=15 ctermul=NONE gui=underline,bold guifg=#073642 guibg=#fdf6e3 guisp=NONE
	hi ToolbarButton term=bold,reverse cterm=bold ctermfg=14 ctermbg=15 ctermul=NONE gui=bold guifg=#93a1a1 guibg=#fdf6e3 guisp=NONE
	hi ToolbarLine term=reverse cterm=NONE ctermfg=NONE ctermbg=15 ctermul=NONE gui=NONE guifg=NONE guibg=#fdf6e3 guisp=NONE
	hi VertSplit term=NONE cterm=NONE ctermfg=14 ctermbg=14 ctermul=NONE gui=NONE guifg=#93a1a1 guibg=#93a1a1 guisp=NONE
	hi Visual term=reverse cterm=reverse ctermfg=14 ctermbg=15 ctermul=NONE gui=reverse guifg=#586e75 guibg=#fdf6e3 guisp=NONE
	hi VisualNOS term=reverse cterm=reverse ctermfg=NONE ctermbg=7 ctermul=NONE gui=reverse guifg=NONE guibg=#eee8d5 guisp=NONE
	hi WildMenu term=reverse cterm=reverse ctermfg=0 ctermbg=7 ctermul=NONE gui=reverse guifg=#073642 guibg=#eee8d5 guisp=NONE
	hi ALEErrorSign term=NONE cterm=bold ctermfg=1 ctermbg=15 ctermul=NONE gui=bold guifg=#dc322f guibg=#fdf6e3 guisp=NONE
	hi ALEErrorSignLineNr term=NONE cterm=NONE ctermfg=15 ctermbg=1 ctermul=NONE gui=NONE guifg=#fdf6e3 guibg=#dc322f guisp=NONE
	hi ALEInfoSign term=NONE cterm=bold ctermfg=6 ctermbg=15 ctermul=NONE gui=bold guifg=#2aa198 guibg=#fdf6e3 guisp=NONE
	hi ALEInfoSignLineNr term=NONE cterm=NONE ctermfg=15 ctermbg=6 ctermul=NONE gui=NONE guifg=#fdf6e3 guibg=#2aa198 guisp=NONE
	hi ALEWarningSign term=NONE cterm=bold ctermfg=3 ctermbg=15 ctermul=NONE gui=bold guifg=#b58900 guibg=#fdf6e3 guisp=NONE
	hi ALEWarningSignLineNr term=NONE cterm=NONE ctermfg=15 ctermbg=3 ctermul=NONE gui=NONE guifg=#fdf6e3 guibg=#b58900 guisp=NONE
	hi GlyphPalette0 term=NONE cterm=NONE ctermfg=15 ctermbg=NONE ctermul=NONE gui=NONE guifg=#fdf6e3 guibg=NONE guisp=NONE
	hi GlyphPalette15 term=NONE cterm=NONE ctermfg=0 ctermbg=NONE ctermul=NONE gui=NONE guifg=#073642 guibg=NONE guisp=NONE
	hi GlyphPalette7 term=NONE cterm=NONE ctermfg=8 ctermbg=NONE ctermul=NONE gui=NONE guifg=#002b36 guibg=NONE guisp=NONE
	hi GlyphPalette8 term=NONE cterm=NONE ctermfg=7 ctermbg=NONE ctermul=NONE gui=NONE guifg=#eee8d5 guibg=NONE guisp=NONE
	hi pandocTableZebraDark term=NONE cterm=NONE ctermfg=4 ctermbg=15 ctermul=NONE gui=NONE guifg=#268bd2 guibg=#fdf6e3 guisp=NONE
	hi pandocTableZebraLight term=NONE cterm=NONE ctermfg=4 ctermbg=7 ctermul=NONE gui=NONE guifg=#268bd2 guibg=#eee8d5 guisp=NONE
	hi SignatureMarkText term=bold cterm=bold ctermfg=0 ctermbg=15 ctermul=NONE gui=bold guifg=#073642 guibg=#fdf6e3 guisp=NONE
	hi vimIsCommand term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
	hi pandocLinkTitle term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
	hi hsString term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
	hi htmlArg term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
	hi pandocLinkDefinition term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=10 gui=NONE guifg=#2aa198 guibg=NONE guisp=#586e75
	hi pandocLinkTitleDelim term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=10 gui=NONE guifg=#586e75 guibg=NONE guisp=#586e75
	hi pandocLinkURL term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
	hi StatusLineLeft term=bold cterm=bold ctermfg=7 ctermbg=2 gui=bold guifg=#eee8d5 guibg=#859900
	hi StatusLineRight term=bold cterm=bold ctermfg=7 ctermbg=3 gui=bold guifg=#eee8d5 guibg=#b58900
	hi StatusGit term=bold cterm=bold ctermfg=7 ctermbg=6 gui=bold guifg=#eee8d5 guibg=#2aa198
endif
# common {{{
if italic
	hi Changed term=italic,bold cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
	hi Constant term=italic,bold cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#2aa198 guibg=NONE guisp=NONE
	hi CursorLineNr term=bold,italic,reverse,underline cterm=bold ctermfg=3 ctermbg=NONE ctermul=NONE gui=bold guifg=#b58900 guibg=NONE guisp=NONE
	hi ErrorMsg term=italic,reverse,bold cterm=reverse ctermfg=1 ctermbg=7 ctermul=NONE gui=reverse guifg=#dc322f guibg=#eee8d5 guisp=NONE
	hi Identifier term=italic cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
	hi IncSearch term=italic,standout cterm=standout ctermfg=9 ctermbg=NONE ctermul=NONE gui=standout guifg=#cb4b16 guibg=NONE guisp=NONE
	hi PreProc term=italic cterm=NONE ctermfg=9 ctermbg=NONE ctermul=NONE gui=NONE guifg=#cb4b16 guibg=NONE guisp=NONE
	hi Search term=italic,reverse cterm=reverse ctermfg=3 ctermbg=NONE ctermul=NONE gui=reverse guifg=#b58900 guibg=NONE guisp=NONE
	hi Special term=italic,bold cterm=NONE ctermfg=9 ctermbg=NONE ctermul=NONE gui=NONE guifg=#cb4b16 guibg=NONE guisp=NONE
	hi SpellBad term=underline,italic cterm=underline,italic ctermfg=NONE ctermbg=NONE ctermul=9 gui=undercurl guifg=NONE guibg=NONE guisp=#cb4b16
	hi SpellCap term=underline,italic cterm=underline,italic ctermfg=NONE ctermbg=NONE ctermul=13 gui=undercurl guifg=NONE guibg=NONE guisp=#6c71c4
	hi SpellLocal term=underline,italic cterm=underline,italic ctermfg=NONE ctermbg=NONE ctermul=3 gui=undercurl guifg=NONE guibg=NONE guisp=#b58900
	hi SpellRare term=underline,italic cterm=underline,italic ctermfg=NONE ctermbg=NONE ctermul=6 gui=undercurl guifg=NONE guibg=NONE guisp=#2aa198
	hi gitcommitComment term=italic cterm=italic ctermfg=10 ctermbg=NONE ctermul=NONE gui=italic guifg=#586e75 guibg=NONE guisp=NONE
	hi htmlSpecialTagName term=italic cterm=italic ctermfg=4 ctermbg=NONE ctermul=NONE gui=italic guifg=#268bd2 guibg=NONE guisp=NONE
	hi pandocComment term=italic cterm=italic ctermfg=10 ctermbg=NONE ctermul=NONE gui=italic guifg=#586e75 guibg=NONE guisp=NONE
	hi pandocEmphasis term=italic cterm=italic ctermfg=12 ctermbg=NONE ctermul=NONE gui=italic guifg=#26ab7b guibg=NONE guisp=NONE
	hi pandocEmphasisDefinition term=italic cterm=italic ctermfg=13 ctermbg=NONE ctermul=NONE gui=italic guifg=#6c71c4 guibg=NONE guisp=NONE
	hi pandocEmphasisTable term=italic cterm=italic ctermfg=4 ctermbg=NONE ctermul=NONE gui=italic guifg=#268bd2 guibg=NONE guisp=NONE
else
	hi Changed term=bold cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
	hi Constant term=bold cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#2aa198 guibg=NONE guisp=NONE
	hi CursorLineNr term=bold,reverse,underline cterm=bold ctermfg=3 ctermbg=NONE ctermul=NONE gui=bold guifg=#b58900 guibg=NONE guisp=NONE
	hi ErrorMsg term=reverse,bold cterm=reverse ctermfg=1 ctermbg=7 ctermul=NONE gui=reverse guifg=#dc322f guibg=#eee8d5 guisp=NONE
	hi Identifier term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
	hi IncSearch term=standout cterm=standout ctermfg=9 ctermbg=NONE ctermul=NONE gui=standout guifg=#cb4b16 guibg=NONE guisp=NONE
	hi PreProc term=NONE cterm=NONE ctermfg=9 ctermbg=NONE ctermul=NONE gui=NONE guifg=#cb4b16 guibg=NONE guisp=NONE
	hi Search term=reverse cterm=reverse ctermfg=3 ctermbg=NONE ctermul=NONE gui=reverse guifg=#b58900 guibg=NONE guisp=NONE
	hi Special term=bold cterm=NONE ctermfg=9 ctermbg=NONE ctermul=NONE gui=NONE guifg=#cb4b16 guibg=NONE guisp=NONE
	hi SpellBad term=underline cterm=underline ctermfg=NONE ctermbg=NONE ctermul=9 gui=undercurl guifg=NONE guibg=NONE guisp=#cb4b16
	hi SpellCap term=underline cterm=underline ctermfg=NONE ctermbg=NONE ctermul=13 gui=undercurl guifg=NONE guibg=NONE guisp=#6c71c4
	hi SpellLocal term=underline cterm=underline ctermfg=NONE ctermbg=NONE ctermul=3 gui=undercurl guifg=NONE guibg=NONE guisp=#b58900
	hi SpellRare term=underline cterm=underline ctermfg=NONE ctermbg=NONE ctermul=6 gui=undercurl guifg=NONE guibg=NONE guisp=#2aa198
	hi gitcommitComment term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
	hi htmlSpecialTagName term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
	hi pandocComment term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
	hi pandocEmphasis term=NONE cterm=NONE ctermfg=12 ctermbg=NONE ctermul=NONE gui=NONE guifg=#26ab7b guibg=NONE guisp=NONE
	hi pandocEmphasisDefinition term=NONE cterm=NONE ctermfg=13 ctermbg=NONE ctermul=NONE gui=NONE guifg=#6c71c4 guibg=NONE guisp=NONE
	hi pandocEmphasisTable term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
endif
hi Added term=bold cterm=NONE ctermfg=2 ctermbg=NONE ctermul=NONE gui=NONE guifg=#859900 guibg=NONE guisp=NONE
hi Bold term=bold cterm=bold ctermul=NONE gui=bold guisp=NONE
hi BoldItalic term=bold,italic cterm=bold,italic ctermul=NONE gui=bold,italic guisp=NONE
hi ComplMatchIns term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE ctermul=NONE gui=NONE guifg=NONE guibg=NONE guisp=NONE
hi Conceal term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi CursorIM term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE ctermul=NONE gui=NONE guifg=NONE guibg=NONE guisp=NONE
hi Directory term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi Error term=bold cterm=reverse,bold ctermfg=1 ctermbg=7 ctermul=NONE gui=reverse,bold guifg=#dc322f guibg=#eee8d5 guisp=NONE
hi Ignore term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE ctermul=NONE gui=NONE guifg=NONE guibg=NONE guisp=NONE
hi Italic term=italic cterm=italic ctermul=NONE gui=italic guisp=NONE
hi lCursor term=NONE cterm=NONE ctermfg=NONE ctermbg=fg ctermul=NONE gui=NONE guifg=NONE guibg=fg guisp=NONE
hi MatchParen term=reverse,bold cterm=reverse,bold ctermfg=NONE ctermbg=NONE ctermul=NONE gui=reverse,bold guifg=NONE guibg=NONE guisp=NONE
hi ModeMsg term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi MoreMsg term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi MsgArea term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE ctermul=NONE gui=NONE guifg=NONE guibg=NONE guisp=NONE
hi Question term=bold cterm=bold ctermfg=6 ctermbg=NONE ctermul=NONE gui=bold guifg=#2aa198 guibg=NONE guisp=NONE
hi Removed term=reverse,strikethrough cterm=NONE ctermfg=1 ctermbg=NONE ctermul=NONE gui=NONE guifg=#dc322f guibg=NONE guisp=NONE
hi Statement term=NONE cterm=NONE ctermfg=2 ctermbg=NONE ctermul=NONE gui=NONE guifg=#859900 guibg=NONE guisp=NONE
hi Title term=bold cterm=bold ctermfg=9 ctermbg=NONE ctermul=NONE gui=bold guifg=#cb4b16 guibg=NONE guisp=NONE
hi Todo term=underline,bold cterm=bold ctermfg=5 ctermbg=NONE ctermul=NONE gui=bold guifg=#d33682 guibg=NONE guisp=NONE
hi Type term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi Underlined term=underline cterm=underline ctermfg=13 ctermbg=NONE ctermul=NONE gui=underline guifg=#6c71c4 guibg=NONE guisp=NONE
hi WarningMsg term=bold cterm=bold ctermfg=9 ctermbg=NONE ctermul=NONE gui=bold guifg=#cb4b16 guibg=NONE guisp=NONE
hi ALEError term=underline cterm=underline ctermfg=1 ctermbg=NONE ctermul=1 gui=undercurl guifg=#dc322f guibg=NONE guisp=#dc322f
hi ALEInfo term=underline cterm=underline ctermfg=6 ctermbg=NONE ctermul=6 gui=undercurl guifg=#2aa198 guibg=NONE guisp=#2aa198
hi ALEWarning term=NONE cterm=underline ctermfg=3 ctermbg=NONE ctermul=3 gui=undercurl guifg=#b58900 guibg=NONE guisp=#b58900
hi ConId term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi cPreCondit term=NONE cterm=NONE ctermfg=9 ctermbg=NONE ctermul=NONE gui=NONE guifg=#cb4b16 guibg=NONE guisp=NONE
hi gitcommitBranch term=NONE cterm=bold ctermfg=5 ctermbg=NONE ctermul=NONE gui=bold guifg=#d33682 guibg=NONE guisp=NONE
hi gitcommitDiscardedFile term=NONE cterm=bold ctermfg=1 ctermbg=NONE ctermul=NONE gui=bold guifg=#dc322f guibg=NONE guisp=NONE
hi gitcommitdiscardedtype term=NONE cterm=NONE ctermfg=1 ctermbg=NONE ctermul=NONE gui=NONE guifg=#dc322f guibg=NONE guisp=NONE
hi gitcommitFile term=NONE cterm=bold ctermfg=12 ctermbg=NONE ctermul=NONE gui=bold guifg=#26ab7b guibg=NONE guisp=NONE
hi gitcommitHeader term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
hi gitcommitOnBranch term=NONE cterm=bold ctermfg=10 ctermbg=NONE ctermul=NONE gui=bold guifg=#586e75 guibg=NONE guisp=NONE
hi gitcommitSelectedFile term=NONE cterm=bold ctermfg=2 ctermbg=NONE ctermul=NONE gui=bold guifg=#859900 guibg=NONE guisp=NONE
hi gitcommitselectedtype term=NONE cterm=NONE ctermfg=2 ctermbg=NONE ctermul=NONE gui=NONE guifg=#859900 guibg=NONE guisp=NONE
hi gitcommitUnmerged term=NONE cterm=bold ctermfg=2 ctermbg=NONE ctermul=NONE gui=bold guifg=#859900 guibg=NONE guisp=NONE
hi gitcommitUnmergedFile term=NONE cterm=bold ctermfg=3 ctermbg=NONE ctermul=NONE gui=bold guifg=#b58900 guibg=NONE guisp=NONE
hi gitcommitUntrackedFile term=NONE cterm=bold ctermfg=6 ctermbg=NONE ctermul=NONE gui=bold guifg=#2aa198 guibg=NONE guisp=NONE
hi GlyphPalette1 term=NONE cterm=NONE ctermfg=1 ctermbg=NONE ctermul=NONE gui=NONE guifg=#dc322f guibg=NONE guisp=NONE
hi GlyphPalette2 term=NONE cterm=NONE ctermfg=2 ctermbg=NONE ctermul=NONE gui=NONE guifg=#859900 guibg=NONE guisp=NONE
hi GlyphPalette3 term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi GlyphPalette4 term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi GlyphPalette5 term=NONE cterm=NONE ctermfg=5 ctermbg=NONE ctermul=NONE gui=NONE guifg=#d33682 guibg=NONE guisp=NONE
hi GlyphPalette6 term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#2aa198 guibg=NONE guisp=NONE
hi GlyphPalette9 term=NONE cterm=NONE ctermfg=9 ctermbg=NONE ctermul=NONE gui=NONE guifg=#cb4b16 guibg=NONE guisp=NONE
hi GlyphPalette10 term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
hi GlyphPalette11 term=NONE cterm=NONE ctermfg=11 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b3ad00 guibg=NONE guisp=NONE
hi GlyphPalette12 term=NONE cterm=NONE ctermfg=12 ctermbg=NONE ctermul=NONE gui=NONE guifg=#26ab7b guibg=NONE guisp=NONE
hi GlyphPalette13 term=NONE cterm=NONE ctermfg=13 ctermbg=NONE ctermul=NONE gui=NONE guifg=#6c71c4 guibg=NONE guisp=NONE
hi GlyphPalette14 term=NONE cterm=NONE ctermfg=14 ctermbg=NONE ctermul=NONE gui=NONE guifg=#93a1a1 guibg=NONE guisp=NONE
hi helpExample term=NONE cterm=NONE ctermfg=14 ctermbg=NONE ctermul=NONE gui=NONE guifg=#93a1a1 guibg=NONE guisp=NONE
hi helpHyperTextEntry term=NONE cterm=NONE ctermfg=2 ctermbg=NONE ctermul=NONE gui=NONE guifg=#859900 guibg=NONE guisp=NONE
hi helpHyperTextJump term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi helpNote term=NONE cterm=NONE ctermfg=5 ctermbg=NONE ctermul=NONE gui=NONE guifg=#d33682 guibg=NONE guisp=NONE
hi helpOption term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#2aa198 guibg=NONE guisp=NONE
hi helpVim term=NONE cterm=NONE ctermfg=5 ctermbg=NONE ctermul=NONE gui=NONE guifg=#d33682 guibg=NONE guisp=NONE
hi hs_DeclareFunction term=NONE cterm=NONE ctermfg=9 ctermbg=NONE ctermul=NONE gui=NONE guifg=#cb4b16 guibg=NONE guisp=NONE
hi hs_hlFunctionName term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi hs_OpFunctionName term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi hsImport term=NONE cterm=NONE ctermfg=5 ctermbg=NONE ctermul=NONE gui=NONE guifg=#d33682 guibg=NONE guisp=NONE
hi hsImportLabel term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#2aa198 guibg=NONE guisp=NONE
hi hsModuleName term=NONE cterm=NONE ctermfg=2 ctermbg=NONE ctermul=NONE gui=NONE guifg=#859900 guibg=NONE guisp=NONE
hi hsNiceOperator term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#2aa198 guibg=NONE guisp=NONE
hi hsStatement term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#2aa198 guibg=NONE guisp=NONE
hi hsStructure term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#2aa198 guibg=NONE guisp=NONE
hi hsType term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi hsTypedef term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#2aa198 guibg=NONE guisp=NONE
hi hsVarSym term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#2aa198 guibg=NONE guisp=NONE
hi htmlEndTag term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
hi htmlTag term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
hi htmlTagN term=NONE cterm=bold ctermfg=14 ctermbg=NONE ctermul=NONE gui=bold guifg=#93a1a1 guibg=NONE guisp=NONE
hi htmlTagName term=NONE cterm=bold ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi javaScript term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi pandocBlockQuote term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocBlockQuoteLeader1 term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocBlockQuoteLeader2 term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#2aa198 guibg=NONE guisp=NONE
hi pandocBlockQuoteLeader3 term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi pandocBlockQuoteLeader4 term=NONE cterm=NONE ctermfg=1 ctermbg=NONE ctermul=NONE gui=NONE guifg=#dc322f guibg=NONE guisp=NONE
hi pandocBlockQuoteLeader5 term=NONE cterm=NONE ctermfg=12 ctermbg=NONE ctermul=NONE gui=NONE guifg=#26ab7b guibg=NONE guisp=NONE
hi pandocBlockQuoteLeader6 term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
hi pandocCitation term=NONE cterm=NONE ctermfg=5 ctermbg=NONE ctermul=NONE gui=NONE guifg=#d33682 guibg=NONE guisp=NONE
hi pandocCitationDelim term=NONE cterm=NONE ctermfg=5 ctermbg=NONE ctermul=NONE gui=NONE guifg=#d33682 guibg=NONE guisp=NONE
hi pandocCitationID term=NONE cterm=NONE ctermfg=5 ctermbg=NONE ctermul=NONE gui=NONE guifg=#d33682 guibg=NONE guisp=NONE
hi pandocCitationRef term=NONE cterm=NONE ctermfg=5 ctermbg=NONE ctermul=NONE gui=NONE guifg=#d33682 guibg=NONE guisp=NONE
hi pandocDefinitionBlock term=NONE cterm=NONE ctermfg=13 ctermbg=NONE ctermul=NONE gui=NONE guifg=#6c71c4 guibg=NONE guisp=NONE
hi pandocDefinitionIndctr term=NONE cterm=bold ctermfg=13 ctermbg=NONE ctermul=NONE gui=bold guifg=#6c71c4 guibg=NONE guisp=NONE
hi pandocDefinitionTerm term=NONE cterm=standout ctermfg=13 ctermbg=NONE ctermul=NONE gui=standout guifg=#6c71c4 guibg=NONE guisp=NONE
hi pandocEmphasisHeading term=NONE cterm=bold ctermfg=9 ctermbg=NONE ctermul=NONE gui=bold guifg=#cb4b16 guibg=NONE guisp=NONE
hi pandocEmphasisNested term=NONE cterm=bold ctermfg=12 ctermbg=NONE ctermul=NONE gui=bold guifg=#26ab7b guibg=NONE guisp=NONE
hi pandocEmphasisNestedDefinition term=NONE cterm=bold ctermfg=13 ctermbg=NONE ctermul=NONE gui=bold guifg=#6c71c4 guibg=NONE guisp=NONE
hi pandocEmphasisNestedHeading term=NONE cterm=bold ctermfg=9 ctermbg=NONE ctermul=NONE gui=bold guifg=#cb4b16 guibg=NONE guisp=NONE
hi pandocEmphasisNestedTable term=NONE cterm=bold ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocEscapePair term=NONE cterm=bold ctermfg=1 ctermbg=NONE ctermul=NONE gui=bold guifg=#dc322f guibg=NONE guisp=NONE
hi pandocFootnote term=NONE cterm=NONE ctermfg=2 ctermbg=NONE ctermul=NONE gui=NONE guifg=#859900 guibg=NONE guisp=NONE
hi pandocFootnoteDefLink term=NONE cterm=bold ctermfg=2 ctermbg=NONE ctermul=NONE gui=bold guifg=#859900 guibg=NONE guisp=NONE
hi pandocFootnoteInline term=NONE cterm=bold ctermfg=2 ctermbg=NONE ctermul=NONE gui=bold guifg=#859900 guibg=NONE guisp=NONE
hi pandocFootnoteLink term=NONE cterm=NONE ctermfg=2 ctermbg=NONE ctermul=NONE gui=NONE guifg=#859900 guibg=NONE guisp=NONE
hi pandocHeading term=NONE cterm=bold ctermfg=9 ctermbg=NONE ctermul=NONE gui=bold guifg=#cb4b16 guibg=NONE guisp=NONE
hi pandocHeadingMarker term=NONE cterm=bold ctermfg=9 ctermbg=NONE ctermul=NONE gui=bold guifg=#cb4b16 guibg=NONE guisp=NONE
hi pandocImageCaption term=NONE cterm=bold ctermfg=13 ctermbg=NONE ctermul=NONE gui=bold guifg=#6c71c4 guibg=NONE guisp=NONE
hi pandocLinkDefinitionID term=NONE cterm=bold ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocLinkDelim term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
hi pandocLinkLabel term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocLinkText term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocListMarker term=NONE cterm=NONE ctermfg=5 ctermbg=NONE ctermul=NONE gui=NONE guifg=#d33682 guibg=NONE guisp=NONE
hi pandocListReference term=NONE cterm=NONE ctermfg=5 ctermbg=NONE ctermul=NONE gui=NONE guifg=#d33682 guibg=NONE guisp=NONE
hi pandocMetadata term=NONE cterm=bold ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocMetadataDelim term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
hi pandocMetadataKey term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocNonBreakingSpace term=NONE cterm=reverse ctermfg=1 ctermbg=NONE ctermul=NONE gui=reverse guifg=#dc322f guibg=NONE guisp=NONE
hi pandocRule term=NONE cterm=bold ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocRuleLine term=NONE cterm=bold ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocStrikeout term=NONE cterm=reverse ctermfg=10 ctermbg=NONE ctermul=NONE gui=reverse guifg=#586e75 guibg=NONE guisp=NONE
hi pandocStrikeoutDefinition term=NONE cterm=reverse ctermfg=13 ctermbg=NONE ctermul=NONE gui=reverse guifg=#6c71c4 guibg=NONE guisp=NONE
hi pandocStrikeoutHeading term=NONE cterm=reverse ctermfg=9 ctermbg=NONE ctermul=NONE gui=reverse guifg=#cb4b16 guibg=NONE guisp=NONE
hi pandocStrikeoutTable term=NONE cterm=reverse ctermfg=4 ctermbg=NONE ctermul=NONE gui=reverse guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocStrongEmphasis term=NONE cterm=bold ctermfg=12 ctermbg=NONE ctermul=NONE gui=bold guifg=#26ab7b guibg=NONE guisp=NONE
hi pandocStrongEmphasisDefinition term=NONE cterm=bold ctermfg=13 ctermbg=NONE ctermul=NONE gui=bold guifg=#6c71c4 guibg=NONE guisp=NONE
hi pandocStrongEmphasisEmphasis term=NONE cterm=bold ctermfg=12 ctermbg=NONE ctermul=NONE gui=bold guifg=#26ab7b guibg=NONE guisp=NONE
hi pandocStrongEmphasisEmphasisDefinition term=NONE cterm=bold ctermfg=13 ctermbg=NONE ctermul=NONE gui=bold guifg=#6c71c4 guibg=NONE guisp=NONE
hi pandocStrongEmphasisEmphasisHeading term=NONE cterm=bold ctermfg=9 ctermbg=NONE ctermul=NONE gui=bold guifg=#cb4b16 guibg=NONE guisp=NONE
hi pandocStrongEmphasisEmphasisTable term=NONE cterm=bold ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocStrongEmphasisHeading term=NONE cterm=bold ctermfg=9 ctermbg=NONE ctermul=NONE gui=bold guifg=#cb4b16 guibg=NONE guisp=NONE
hi pandocStrongEmphasisNested term=NONE cterm=bold ctermfg=12 ctermbg=NONE ctermul=NONE gui=bold guifg=#26ab7b guibg=NONE guisp=NONE
hi pandocStrongEmphasisNestedDefinition term=NONE cterm=bold ctermfg=13 ctermbg=NONE ctermul=NONE gui=bold guifg=#6c71c4 guibg=NONE guisp=NONE
hi pandocStrongEmphasisNestedHeading term=NONE cterm=bold ctermfg=9 ctermbg=NONE ctermul=NONE gui=bold guifg=#cb4b16 guibg=NONE guisp=NONE
hi pandocStrongEmphasisNestedTable term=NONE cterm=bold ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocStrongEmphasisTable term=NONE cterm=bold ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocStyleDelim term=NONE cterm=NONE ctermfg=10 ctermbg=NONE ctermul=NONE gui=NONE guifg=#586e75 guibg=NONE guisp=NONE
hi pandocSubscript term=NONE cterm=NONE ctermfg=13 ctermbg=NONE ctermul=NONE gui=NONE guifg=#6c71c4 guibg=NONE guisp=NONE
hi pandocSubscriptDefinition term=NONE cterm=NONE ctermfg=13 ctermbg=NONE ctermul=NONE gui=NONE guifg=#6c71c4 guibg=NONE guisp=NONE
hi pandocSubscriptHeading term=NONE cterm=bold ctermfg=9 ctermbg=NONE ctermul=NONE gui=bold guifg=#cb4b16 guibg=NONE guisp=NONE
hi pandocSubscriptTable term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocSuperscript term=NONE cterm=NONE ctermfg=13 ctermbg=NONE ctermul=NONE gui=NONE guifg=#6c71c4 guibg=NONE guisp=NONE
hi pandocSuperscriptDefinition term=NONE cterm=NONE ctermfg=13 ctermbg=NONE ctermul=NONE gui=NONE guifg=#6c71c4 guibg=NONE guisp=NONE
hi pandocSuperscriptHeading term=NONE cterm=bold ctermfg=9 ctermbg=NONE ctermul=NONE gui=bold guifg=#cb4b16 guibg=NONE guisp=NONE
hi pandocSuperscriptTable term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocTable term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocTableStructure term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocTitleBlock term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocTitleBlockTitle term=NONE cterm=bold ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocTitleComment term=NONE cterm=bold ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi pandocVerbatimBlock term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi pandocVerbatimInline term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi pandocVerbatimInlineDefinition term=NONE cterm=NONE ctermfg=13 ctermbg=NONE ctermul=NONE gui=NONE guifg=#6c71c4 guibg=NONE guisp=NONE
hi pandocVerbatimInlineHeading term=NONE cterm=bold ctermfg=9 ctermbg=NONE ctermul=NONE gui=bold guifg=#cb4b16 guibg=NONE guisp=NONE
hi pandocVerbatimInlineTable term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi perlHereDoc term=NONE cterm=NONE ctermfg=14 ctermbg=NONE ctermul=NONE gui=NONE guifg=#93a1a1 guibg=NONE guisp=NONE
hi perlStatementFileDesc term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#2aa198 guibg=NONE guisp=NONE
hi perlVarPlain term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi rubyBoolean term=NONE cterm=NONE ctermfg=5 ctermbg=NONE ctermul=NONE gui=NONE guifg=#d33682 guibg=NONE guisp=NONE
hi rubyDefine term=NONE cterm=bold ctermfg=14 ctermbg=NONE ctermul=NONE gui=bold guifg=#93a1a1 guibg=NONE guisp=NONE
hi SignatureMarkerText term=NONE cterm=NONE ctermfg=2 ctermbg=0 ctermul=NONE gui=NONE guifg=#859900 guibg=#073642 guisp=NONE
hi texmathmatcher term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi texmathzonex term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi texreflabel term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi texstatement term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#2aa198 guibg=NONE guisp=NONE
hi VarId term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi vimCmdSep term=NONE cterm=bold ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi vimCommand term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi vimCommentString term=NONE cterm=NONE ctermfg=13 ctermbg=NONE ctermul=NONE gui=NONE guifg=#6c71c4 guibg=NONE guisp=NONE
hi vimGroup term=NONE cterm=bold ctermfg=4 ctermbg=NONE ctermul=NONE gui=bold guifg=#268bd2 guibg=NONE guisp=NONE
hi vimHiGroup term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi vimHiLink term=NONE cterm=NONE ctermfg=4 ctermbg=NONE ctermul=NONE gui=NONE guifg=#268bd2 guibg=NONE guisp=NONE
hi vimSynMtchOpt term=NONE cterm=NONE ctermfg=3 ctermbg=NONE ctermul=NONE gui=NONE guifg=#b58900 guibg=NONE guisp=NONE
hi vimSynType term=NONE cterm=NONE ctermfg=6 ctermbg=NONE ctermul=NONE gui=NONE guifg=#2aa198 guibg=NONE guisp=NONE
hi! link GitGutterAdd DiffAdd
hi! link BitGutterChange DiffChange
hi! link GitGutterDelete DiffDelete
hlset([HlReverce('GitGutterAddInvisible', 'SignColumn')])
hi! link GitGutterChangeInvisible GitGutterAddInvisible
hi! link GitGutterDeleteInvisible GitGutterAddInvisible
hi! link Boolean Constant
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
hi! link Function Identifier
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
hi! link PmenuSel Normal
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
hi! link helpSpecial Special
