scriptencoding utf-8
" シェル関数を用いたフィルタ

if exists('g:shell_filter')
	finish
endif
let g:shell_filter = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

" Quoted-Printのデコード {{{1
nnoremap <silent><silent><Leader>hq :let b:pos=getpos(".")<CR>:%s/\v\=\?utf-8\?Q\?(.+)\?\=/\1/g<CR>:%!perl -M'MIME::QuotedPrint' -e 'while (<STDIN>) { print decode_qp($_); }'<CR>:call setpos('.',b:pos)<CR>:set fileencoding=<CR>
xnoremap <silent><silent><Leader>hq :!perl -M'MIME::QuotedPrint' -e 'while (<STDIN>) { print decode_qp($_); }'<CR>:set fileencoding=<CR>
" base64 のデコード←範囲選択しないと上手くいかない {{{1
" nnoremap <silent><silent><Leader>hb :let b:pos=getpos(".") <CR>:%!base64 -di -w 0 -<CR>
xnoremap <silent><silent><Leader>hb :!base64 -di -w 0 -<CR>
" 全角と半角文字の間に空白挿入 {{{1
nnoremap <silent><Leader>hh :call shell_filter#InsertSpace( 0 )<CR>
xnoremap <silent><Leader>hh :call shell_filter#InsertSpace( 1 )<CR>
" 半角カタカナを全角に {{{1
nnoremap <silent><Leader>hz :call shell_filter#han2zen( 0 )<CR>
xnoremap <silent><Leader>hz :call shell_filter#han2zen( 1 )<CR>
" ひらがなをカタカナに {{{1
nnoremap <silent><Leader>hk :call shell_filter#hira2kata( 0 )<CR>
xnoremap <silent><Leader>hk :call shell_filter#hira2kata( 1 )<CR>"

" Reset User condition
let &cpoptions = s:save_cpo
unlet s:save_cpo
