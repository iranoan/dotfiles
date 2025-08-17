vim9script
# $MYVIMDIR/pack/ で管理している Vim 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_setpack_after')
	finish
endif
b:did_ftplugin_setpack_after = 1

# ファイルタイプ別ローカル設定 {{{1
nnoremap <buffer><silent>gf :TabEdit <C-R><C-P><CR>
