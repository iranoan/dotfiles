scriptencoding utf-8

function! set_surroundTag#main(cmd) abort
	call pack_manage#SetMAP('surroundTag', a:cmd, [
				\ #{ mode: 'n', buffer: 1, key: '<leader>tt', method: 1, cmd: 'SurroundTag <span\ class="tcy">'},
				\ #{ mode: 'x', buffer: 1, key: '<leader>tt', method: 1, cmd: 'SurroundTag <span\ class="tcy">'},
				\ #{ mode: 'n', buffer: 1, key: '<leader>tr', method: 1, cmd: 'SurroundTag <ruby> <rp>(</rp><rt></rt><rp>)</rp>'},
				\ #{ mode: 'x', buffer: 1, key: '<leader>tr', method: 1, cmd: 'SurroundTag <ruby> <rp>(</rp><rt></rt><rp>)</rp>'},
				\ ] )
	" マップの付け直し↓ただし隠しバッファの場合付け直しが行われない制限が有る
	for b in getbufinfo()
		let t = getbufvar(b.bufnr, '&filetype')
		if t ==# 'html' || t ==# 'xhtml'
			for w in b.windows
				call win_execute(w, 'nnoremap <silent><buffer><leader>tt <Cmd>SurroundTag <span\ class="tcy"><CR>')
				call win_execute(w, 'xnoremap <silent><buffer><leader>tt <Cmd>SurroundTag <span\ class="tcy"><CR>')
				call win_execute(w, 'nnoremap <silent><buffer><leader>tr <Cmd>SurroundTag <ruby> <rp>(</rp><rt></rt><rp>)</rp><CR>')
				call win_execute(w, 'xnoremap <silent><buffer><leader>tr <Cmd>SurroundTag <ruby> <rp>(</rp><rt></rt><rp>)</rp><CR>')
				break " 複数ウィンドウで開いていても、バッファ単位のマッピングなので
			endfor
		endif
	endfor
	augroup SurroundTag
		autocmd!
		autocmd FileType html,xhtml nnoremap <silent><buffer><leader>tt <Cmd>SurroundTag <span\ class="tcy"><CR>
		autocmd FileType html,xhtml xnoremap <silent><buffer><leader>tt <Cmd>SurroundTag <span\ class="tcy"><CR>
		autocmd FileType html,xhtml nnoremap <silent><buffer><leader>tr <Cmd>SurroundTag <ruby> <rp>(</rp><rt></rt><rp>)</rp><CR>
		autocmd FileType html,xhtml xnoremap <silent><buffer><leader>tr <Cmd>SurroundTag <ruby> <rp>(</rp><rt></rt><rp>)</rp><CR>
	augroup END
endfunction
