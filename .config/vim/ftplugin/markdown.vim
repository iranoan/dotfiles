vim9script
scriptencoding utf-8
# Markdown の設定
# 幾つかはデフォルトで上書きされるので $MYVIMDIR/after/ftplugin/markdown.vim

# ファイルタイプ別のグローバル設定 {{{1
if !exists('g:did_ftplugin_html')
	g:did_ftplugin_markdown = 1
	g:markdown_folding = 1  # Markdown で折りたたみ
	g:markdown_fenced_languages = ['sh', 'vim', 'bash=sh'] # コード・ブロック内で syntax を適用
	# augroup Markdown
	# 	autocmd!
	# augroup END
endif

# 見かけ上のインデント量を formatlistpat にヒットした文字数にする
setlocal breakindentopt=shift:0,min:10,list:-1
# ファイルタイプ別マップ {{{1
# ↓pair_bracket を使う
# 強調 {{{
# inoremap <buffer><expr>*       '**<Left>'
# inoremap <buffer><expr>_       '__<Left>'
# # }}}
# # 添字
# inoremap <buffer><expr>~       '~~<Left>'
# inoremap <buffer><expr>^       '^^<Left>'
# # }}}
# 打ち消し線↓下付き添字と重なる反応が遅くなる
# inoremap <buffer><expr>~~      '~~~~<Left><Left>'

# $MYVIMDIR/pack/ のファイルタイプ別ローカル設定 {{{1
# map-markdown {{{
# 箇条書きと強調の区別→* の後 <Space> ではカーソル右が * ならば箇条書きとして削除
inoremap <buffer><expr><Space> map_markdown#Space()
# 強調の取り消しなどのため前後の文字が同じ記号/箇条書きのインデントなら纏めて消す
inoremap <buffer><expr><BS>    map_markdown#BackSpace()
# 箇条書きの入れ子のため上の行によって空白文字の入力個数を変える
inoremap <buffer><expr><Tab>   map_markdown#Tab()
# マークダウン記法は行末で「半角スペース」を「2個」連続入力すると、以降の文章を改行する→それを踏まえて、箇条書きでは行頭に同じ記号を追加する
inoremap <buffer><expr><CR>    map_markdown#Enter()

# プレヴュー markdown-preview.nvim {{{
nnoremap <silent><buffer><Leader>v <Cmd>call mkdp#util#open_preview_page()<CR>
