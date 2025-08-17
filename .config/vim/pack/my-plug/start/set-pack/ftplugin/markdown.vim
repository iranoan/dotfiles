vim9script
# $MYVIMDIR/pack/ で管理している Markdown 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_setpack')
	finish
endif
b:did_ftplugin_setpack = 1

#ファイルタイプ別のグローバル設定 {{{1
if !exists("g:qf_plugin_setpack")
	g:qf_plugin_setpack = 1
	augroup MKDP_REFRESH_INIT1
		# ↓のエラー対策
		# Error detected while processing BufHidden Autocommands for "<buffer=2>"..function mkdp#rpc#preview_close[11]..mkdp#autocmd#clear_buf:
		# line    1:
		# E216: No such group or event: MKDP_REFRESH_INIT1
		autocmd!
		autocmd FileType markdown echo
	augroup END
endif

# ファイルタイプ別ローカル設定 {{{1
# map-markdown {{{
# 箇条書きと強調の区別→* の後 <Space> ではカーソル右が * ならば箇条書きとして削除
inoremap <buffer><expr><Space> map_markdown#Space()
# 強調の取り消しなどのため前後の文字が同じ記号/箇条書きのインデントなら纏めて消す
inoremap <buffer><expr><BS>    map_markdown#BackSpace()
# 箇条書きの入れ子のため上の行によって空白文字の入力個数を変える
inoremap <buffer><expr><Tab>   map_markdown#Tab()
# マークダウン記法は行末で「半角スペース」を「2個」連続入力すると、以降の文章を改行する→それを踏まえて、箇条書きでは行頭に同じ記号を追加する
inoremap <buffer><expr><CR>    map_markdown#Enter()
# }}}

# プレヴュー markdown-preview.nvim {{{
nnoremap <silent><buffer><Leader>v <Cmd>call mkdp#util#open_preview_page()<CR>
# }}}
