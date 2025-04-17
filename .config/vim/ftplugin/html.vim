"HTML 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

" ファイルタイプ別のグローバル設定 {{{1
if !exists('g:did_ftplugin_html')
	let g:did_ftplugin_html = 1
	augroup MyHTML
		autocmd!
		autocmd BufWinEnter *.html,*.htm syntax clear htmlFold
					\ | syntax region htmlFold start="<\z(\<\%(li\|dt\|dd\|area\|base\|br\|col\|command\|embed\|hr\|img\|input\|keygen\|link\|meta\|param\|source\|track\|wbr\>\)\@![a-z-]\+\>\)\%(\_s*\_[^/]\?>\|\_s\_[^>]*\_[^>/]>\)" end="</\z1\_s*>" fold transparent keepend extend containedin=htmlHead,htmlH\d
					" $MYVIMDIR/after/syntax/html.vim にも書いてみたが効果がなかった
	augroup END
endif

" ファイルタイプ別ローカル設定 {{{1
source $MYVIMDIR/macros/html-xhtml-common.vim
"html <S,C-Enter> の組み合わせは GUI のみ有効
if &filetype !=# 'markdown'
	inoremap <buffer>**              &times;
	inoremap <expr><buffer><S-Enter>   pumvisible#Insert('<li></li><Left><Left><Left><Left><Left><C-G>u')
	inoremap <expr><buffer><S-C-Enter> pumvisible#Insert_after('<br>') .. '<C-G>u'
endif
inoremap <buffer><=                &le;
inoremap <buffer>>=                &ge;
imap     <expr><buffer><C-Space>   pumvisible() ? asyncomplete#close_popup() : '&nbsp;'
inoremap <buffer>&<space>          &nbsp;
inoremap <buffer>--                ‐
inoremap <buffer>---               ―
inoremap <buffer>\\                &yen;
inoremap <buffer>+-                &plusmn;
inoremap <buffer>==                &equiv;
