vim9script
scriptencoding utf-8

# eblook のセットアップ {{{1
# 以前は関数にしていたが
# autocmd FuncUndefined eblook#*
# が上手く動作しない
g:eblook_no_default_key_mappings = 1 #デフォルトのキーマッピング<Leader>yと<Leader><C-Y>を登録しない
packadd eblook.vim
unlet g:eblook_no_default_key_mappings # 読み込み時のみ使われるので、読み込みが終われば削除する
g:eblook_dictlist1 = [
			{
				book: expand('~/EPWING/readers/'),
				name: 'plus',
				title: '研究社リーダーズ+プラスV2',
			},
			{
				book: expand('~/EPWING/Genius/'),
				name: 'genius',
				title: 'ジーニアス英和大辞典',
			}
			]
g:eblook_dictlist2 = [
			{
				book: expand('~/EPWING/Gakken/'),
				name: 'kanjigen',
				title: '漢字源',
			},
			{
				book: expand('~/EPWING/kohjien/'),
				name: 'koujien',
				title: '広辞苑 第四版',
			},
			{
				book: expand('~/EPWING/Gakken/'),
				'name': 'kokugo',
				'title': '現代新国語辞典',
			}
			]
# g:eblook_viewers = { # デフォルト {{{
# 			jpeg: 'xdg-open %s &',
# 			bmp: 'xdg-open %s &',
# 			pbm: 'xdg-open %s &',
# 			wav: 'xdg-open %s &',
# 			mpg: 'xdg-open %s &',
# 			}
# }}}
augroup EblookMAP
	autocmd!
	autocmd FileType eblook Filetype()
augroup END
# }}}1

export def UndoFtplugin(): void
	setlocal spell< list<
	nunmap <buffer><F1>
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
enddef

def Filetype(): void
	set list
	setlocal nospell nolist
	# ↑プラグインで nolist に設定されるので list に指定し直し setlocal で指定し直す
	nnoremap <buffer><F1> <ScriptCmd>Help()<CR>
	if exists('b:undo_ftplugin')
		b:undo_ftplugin ..= ' | call set_eblook#UndoFtplugin()'
	else
		b:undo_ftplugin = 'call set_eblook#UndoFtplugin()'
	endif
enddef

def Help(): void
	var bufn = bufname()
	if bufn =~# '_eblook_entry_\d\+'
		execute('help eblook-usage-entry')
	elseif bufn =~# '_eblook_content_\d\+'
		execute('help eblook-usage-content')
	endif
	return
enddef

def Search(s: string): void # 使う辞書グループの分岐して検索する
	var ss: string = s
	if ss ==# ''
		ss = input('Input search word: ')
		if ss ==# ''
			return
		endif
	endif
	ss = substitute(ss, '^\(["'']\)\([^"'']\+\)\1$', '\2', '')
	if ss =~? '[^''"A-Z]'
		eblook#Search(2, ss, 0)
	else
		eblook#Search(1, ss, 0)
	endif
enddef

export def SearchWord(): void
	Search(expand('<cword>'))
enddef

export def SearchVisual(): void
	var save_reg: dict<any> = getreginfo('a')
	silent execute "normal! \<Esc>"
	silent execute 'normal! `<' .. visualmode() .. '`>"ay'
	Search(
		substitute(@a, '\a\zs\s*\n\s*\ze\a', ' ', 'g')
			->substitute('\s*\n\s*', '', 'g')
			->substitute('^\s\+', '', 'g')
			->substitute('\s\+$', '', 'g')
	)
	setreg('a', save_reg)
enddef
