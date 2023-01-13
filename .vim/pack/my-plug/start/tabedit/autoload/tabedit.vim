" :TabEdit
" 指定されたバッファ/ファイルがあればそれをアクティブにし、無ければ開く
" 複数指定では、最初に見つかった分をアクティブに

scriptencoding utf-8
scriptversion 4

let s:save_cpo = &cpoptions
set cpoptions&vim

function! s:goto_win(windows) abort  " windows[] をアクティブ候補に
	if a:windows == []
		return v:false
	endif
	let l:tabnr = tabpagenr()
	" 現在のタブに有るか?
	for l:w in a:windows
		if win_id2tabwin(l:w)[0] == l:tabnr
			let s:win_id = s:win_id ? s:win_id : l:w
			return v:true
		endif
	endfor
	" 他のタブも含めて開いているか?
	for l:w in a:windows
		let s:win_id = s:win_id ? s:win_id : l:w
		return v:true
	endfor
	return v:false
endfunction

function! s:open_buffer(f) abort " バッファ番号の可能性を探り有れば開く
	let l:n = str2nr(a:f)
	if l:n != a:f || strlen(l:n) != strlen(a:f)  " 値/文字列としての幅のどちらか違うので数字ではない→バッファ場号の可能性なし
		return v:false
	endif
	for l:v in getbufinfo()
		if l:v.bufnr == l:n  " バッファ番号が見つかった
			if s:goto_win(l:v.windows)
				return v:true
			endif
			" バッファは有ったが hidden
			execute 'silent tab sbuffer ' .. a:f
			let s:win_id = s:win_id ? s:win_id : winnr()
			return v:true
		endif
	endfor
	return v:false
endfunction

function! s:open_file(f) abort  " ファイル a:f を開く
	for l:v in getbufinfo()
		if a:f != l:v.name
			continue
		endif
		if s:goto_win(l:v.windows)
			return
		endif
		execute 'silent tab sbuffer ' .. l:v.bufnr
		let s:win_id = s:win_id ? s:win_id : winnr()
		return
	endfor
	if wordcount().bytes == 0 && &modified == 0
		execute 'edit ' .. a:f
	else
		execute 'silent tabedit ' .. a:f
	endif
	let s:win_id = s:win_id ? s:win_id : winnr()
endfunction

function! s:open(f, pwd) abort  " a:f (バッファ番号、もしくはファイル名) を開く
	let l:full = s:to_fullpath(a:f, a:pwd)
	if getftype(l:full) ==? 'files'  " ファイルが存在するなら無条件で開く
		call s:open_file(l:full)
	elseif getftype(l:full) ==? 'dir'  " ディレクトリなら Fern で開く
		execute 'tabedit | Fern ' .. l:full
	elseif !s:open_buffer(a:f)
		call s:open_file(l:full)
	endif
endfunction

function! s:to_fullpath(f, pwd) abort " フルパスに変換
	" 単純に let l:full = fnamemodify(a:f, ':p') だと、複数ファイルを開くときに先に開いたファイルに左右される
	if has('win32') || has('win32unix')
		if match(a:f, '^\w:') == 0
			return a:f
		endif
		return a:pwd .. '/' .. a:f
	else
		if match(a:f, '^/') == 0
			return a:f
		endif
		if match(a:f, '^\~/') == 0
			return getenv('HOME') .. strpart(a:f, 1)
		else
			return a:pwd .. '/' .. a:f
		endif
	endif
endfunction

function! tabedit#tabedit(...) abort
	if a:000 == []
		tabedit
		return
	endif
	let s:win_id = 0  " 終了後最初に見つかった/開いたアクティブにする候補の初期値 (有り得ない 0 としておく)
	let l:pwd = getcwd()
	for l:files in a:000
		let l:glob = glob(l:files)
		if l:glob ==? ''
			call s:open(l:files, l:pwd)
		else
			for l:f in split(l:glob)
				call s:open(l:f, l:pwd)
			endfor
		endif
	endfor
	call win_gotoid(s:win_id)
	redraw  " これが無いとタグが切り替わったように見えない
	unlet s:win_id
endfunction

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
