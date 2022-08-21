vim9script
# <space> はページ送りに {{{2
scriptencoding utf-8

def page_down#main()  # ファイル最後の行が表示されていればスクロールしない
	if line('w$') == line('$') # 最終行表示
		if line('w0') == line('w$') # 最終行でも表示先頭行と最終行が同じなら折り返されている部分が非表示の可能性→カーソル移動
			execute 'normal!' 2 * winheight(0) - winline() - 1 .. 'gj'
		endif
	elseif line('w0') != line('w$') # 一行で 1 ページ全体だと、<PageDown> では折り返されている部分が飛ばされるので分ける
		execute "normal! \<PageDown>"
	else
		var pos = line('.')
		execute 'normal!' winheight(0) - winline() + 1 .. 'gj'
		if line('.') != pos # 移動前に表示していた次の行までカーソル移動して、行番号が異なれば行の最後まで表示されていた
			call cursor(pos, 0) # 一旦前の位置に移動し次で次行を画面最上部に表示
			normal! jzt
		else # 行の途中まで表示していた
			execute 'normal!' winheight(0) - 2 .. 'gj'
			# ↑追加で 1 ページ分カーソル移動←本当はページ先頭に戻したいがやり方がわからない
			if line('.') != pos # カーソル移動して行番号異なれば、以降の行まで移動した
				call cursor(pos, 0) # 一旦前の位置に移動し次で行末の表示先頭桁に移動
				normal! $g^
			endif
		endif
	endif
enddef
