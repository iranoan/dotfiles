vim9script
# GUI 環境の設定を ON/OFF トグルとフォント・サイズ変更の関数
scriptencoding utf-8

def GuiOptionM(): void
	if &guioptions =~# 'M'
		silent set guioptions-=M
		if exists('g:did_install_default_menus')
			unlet g:did_install_default_menus
		endif
		if exists('g:did_install_syntax_menu')
			unlet g:did_install_syntax_menu
		endif
		execute 'source' resolve(globpath(&runtimepath, 'menu.vim', 1, 1)[0])
	endif
enddef

export def Menu()
	call GuiOptionM()
	if &guioptions =~# 'm'
		set guioptions-=m
	else
		set guioptions+=m
	endif
enddef

export def Toolbar()
	call GuiOptionM()
	if &guioptions =~# 'T'
		set guioptions-=T
	else
		set guioptions+=T
	endif
enddef

export def FontSize(size: number): void # フォント・サイズを増減
	# size: 増減させる数値
	var f_size: number = str2nr(matchstr(&guifont, '\(\d\+\ze,\|\d\+$\)'))
	var F_size: number = f_size + size
	var columns: number = (&columns * 100 * f_size / F_size + 50) / 100
	var lines: number = (&lines * 100 * f_size / F_size + 50) / 100
	&guifont = substitute(&guifont, '\(\d\+\ze,\|\d\+$\)', F_size, 'g')
	&columns = columns
	&lines = lines
enddef

def EnableGnomeExtension(ls: list<string>): bool # Gnome Extension ls の何れかが使えるか?
	# 複数の内どれかがあれば呼べる場合があるので、list<string> にしている
	var extensions: list<string> = systemlist(['dconf', 'read', '/org/gnome/shell/enabled-extensions'])
	->get(0, '[]')
	->eval()

	for s in ls
		if match(extensions, $'^\<{s}@') != -1
			return true
		endif
	endfor
	return false
enddef

def GnomeGetWinId(): number # Wayland でも Gnome 環境で Windows-ID 取得 (Window Calls 拡張機能が必要)
	var id: number

	if split($XDG_CURRENT_DESKTOP, ':')->index('GNOME') == -1
		return 0
	endif
	if !EnableGnomeExtension(['window-calls'])
		return 0
	endif
	var title_pattern: string = '\%("title":"\%([^"]\|\\"\)\+"\|\\"title\\":\\"\%([^"]\|\\\{3}"\)\+"\)'
	# 開いているファイルやブラウザでのウェブ検索キーワードによって変化するウィンドウ・タイトル情報を削除
	# 検索キーワードの最初が通常で、後半が ", ' 両方を含む場合
	var gdbus_out: string = system(['gdbus', 'call', '--session', '--dest', 'org.gnome.Shell', '--object-path', '/org/gnome/Shell/Extensions/Windows', '--method', 'org.gnome.Shell.Extensions.Windows.List'])
	                          ->substitute($'\%({title_pattern},\|,{title_pattern}\ze}}\)', '', 'g')
	#                           検索キーの後半がtitleキーが最後にある場合、前半がそれ以外 (通常ありえない title キーしかない場合は考慮していない)

	if gdbus_out =~# '^("' # 開いているファイルやブラウザでのウェブ検索キーワードに ", ' 両方を含む場合
		gdbus_out = matchstr(gdbus_out, '^("\zs.*\ze",\s*)\_s*$')
			           ->substitute('\\"', '"', 'g') # キー自身も \" で挟まれているので " のみにする
	else
		gdbus_out = matchstr(gdbus_out, '^(''\zs.*\ze'',\s*)\_s*$')
	endif
	return js_decode(gdbus_out)
			->filter((_, v) => v.wm_class_instance ==# 'gvim')[0].id
enddef

export def GnomeTopLeft(): void # Wayland でも Gnome なら GVim のウィンドウを左上に (Window Calls に加えて ubuntu-dock/dash-to-dock 何れかの拡張機能が必要)
	var id: number
	var x: number
	var y: number
	var doc_postion: string

	id = GnomeGetWinId()
	if id == 0
		return
	endif
	if EnableGnomeExtension(['ubuntu-dock', 'dash-to-dock'])
		doc_postion = systemlist(['dconf', 'read', '/org/gnome/shell/extensions/dash-to-dock/dock-position'])[0]
		if doc_postion ==? "'left'"
			x = str2nr(system(['dconf', 'read', '/org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size'])) + 1
			y = 17
		elseif doc_postion ==? "'top'"
			y = str2nr(system(['dconf', 'read', '/org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size'])) + 17
		endif
	endif
	if EnableGnomeExtension(['dash-to-panel'])
		if system(['dconf', 'read', '/org/gnome/shell/extensions/dash-to-panel/window-preview-title-position'])->match("'TOP'") != -1
			y = str2nr(system(['dconf', 'read', '/org/gnome/shell/extensions/dash-to-panel/appicon-margin']))
				+ str2nr(system(['dconf', 'read', '/org/gnome/shell/extensions/dash-to-panel/appicon-padding']))
				+ str2nr(system(['dconf', 'read', '/org/gnome/shell/extensions/dash-to-panel/panel-size']))
		endif
		systemlist(['gdbus', 'call', '--session', '--dest', 'org.gnome.Shell', '--object-path', '/org/gnome/Shell/Extensions/Windows', '--method', 'org.gnome.Shell.Extensions.Windows.Move', id, x, y])
	endif
enddef

export def GnomeActive(): void # Wayland でも Gnome なら GVim のウィンドウをアクティブに (Window Calls 拡張機能が必要)
	var id: number = GnomeGetWinId()

	if id != 0
		systemlist(['gdbus', 'call', '--session', '--dest', 'org.gnome.Shell', '--object-path', '/org/gnome/Shell/Extensions/Windows', '--method', 'org.gnome.Shell.Extensions.Windows.Activate', id])
	endif
enddef
