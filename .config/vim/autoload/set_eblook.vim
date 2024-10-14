scriptencoding utf-8

function set_eblook#setup() abort
	let g:eblook_no_default_key_mappings = 1 "デフォルトのキーマッピング<Leader>yと<Leader><C-Y>を登録しない
	packadd eblook.vim
	unlet g:eblook_no_default_key_mappings " 読み込み時のみ使われるので、読み込みが終われば削除する
	let g:eblook_dictlist1 = [
				\{
				\ 'book': expand('~/EPWING/readers/'),
				\ 'name': 'plus',
				\ 'title': '研究社リーダーズ＋プラスＶ２',
				\},
				\{
				\ 'book': expand('~/EPWING/Genius/'),
				\ 'name': 'genius',
				\ 'title': 'ジーニアス英和大辞典',
				\},
				\]
	let g:eblook_dictlist2 = [
				\{
				\ 'book': expand('~/EPWING/Gakken/'),
				\ 'name': 'kanjigen',
				\ 'title': '漢字源',
				\},
				\{
				\ 'book': expand('~/EPWING/kohjien/'),
				\ 'name': 'koujien',
				\ 'title': '広辞苑　第四版',
				\},
				\{
				\ 'book': expand('~/EPWING/Gakken/'),
				\ 'name': 'kokugo',
				\ 'title': '現代新国語辞典',
				\},
				\]
	" let g:eblook_viewers = { " デフォルト {{{
	" 			\'jpeg': 'xdg-open %s &',
	" 			\'bmp': 'xdg-open %s &',
	" 			\'pbm': 'xdg-open %s &',
	" 			\'wav': 'xdg-open %s &',
	" 			\'mpg': 'xdg-open %s &',
	" 			\}
	" }}}
	" autocmd FuncUndefined eblook#* " ←が何故か動作しないのでマップし直す
	augroup EblookMAP
		autocmd!
		autocmd FileType eblook call set_eblook#filetype()
	augroup END
	xnoremap <silent><Leader>eb <Cmd>call set_eblook#searchVisual()<CR>
	nnoremap <silent><Leader>eb <Cmd>call set_eblook#searchWord()<CR>
endfunction

def set_eblook#undo_ftplugin(): void
	setlocal spell< list<
	nunmap <buffer><F1>
	unlet! b:did_ftplugin_user_after b:did_ftplugin_user
enddef

def set_eblook#filetype(): void
	set list
	setlocal nospell nolist
	nnoremap <buffer><F1> <Cmd>call set_eblook#help()<CR>
	# ↑プラグインで nolist に設定されるので list に指定し直し setlocal で指定し直す
	if exists('b:undo_ftplugin')
		b:undo_ftplugin ..= ' | call set_eblook#undo_ftplugin()'
	else
		b:undo_ftplugin = 'call set_eblook#undo_ftplugin()'
	endif
enddef

def set_eblook#help(): void
	if &filetype !=# 'eblook'
		return
	endif
	var bufn = bufname()
	if bufn =~# '_eblook_entry_\d\+'
		execute('help eblook-usage-entry')
	elseif bufn =~# '_eblook_content_\d\+'
		execute('help eblook-usage-content')
	endif
	return
enddef

def s:search(s: string): void # 使う辞書グループの分岐して検索する
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

def set_eblook#searchWord(): void
	s:search(expand('<cword>'))
enddef

def set_eblook#searchVisual(): void
	var save_reg: dict<any> = getreginfo('a')
	silent execute "normal! \<Esc>"
	silent execute 'normal! `<' .. visualmode() .. '`>"ay'
	s:search(
		substitute(@a, '\a\zs\s*\n\s*\ze\a', ' ', 'g')
			->substitute('\s*\n\s*', '', 'g')
			->substitute('^\s\+', '', 'g')
			->substitute('\s\+$', '', 'g')
	)
	setreg('a', save_reg)
enddef
