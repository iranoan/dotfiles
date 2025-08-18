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

# Undo {{{1
if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= ' | call undo_ftplugin#Reset("markdown")'
else
	b:undo_ftplugin = 'call undo_ftplugin#Reset("markdown")'
endif
