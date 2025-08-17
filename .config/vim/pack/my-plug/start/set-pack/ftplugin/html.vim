vim9script
# $MYVIMDIR/pack/ で管理している HTML/XHTML 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_setpack')
	finish
endif
b:did_ftplugin_setpack = 1

#ファイルタイプ別のグローバル設定 {{{1
# if !exists("g:qf_plugin_setpack")
# 	g:qf_plugin_setpack = 1
# endif

# ファイルタイプ別ローカル設定 {{{1
nnoremap <silent><buffer><leader>tt <Cmd>SurroundTag <span\ class="tcy"><CR>
xnoremap <silent><buffer><leader>tt <Cmd>SurroundTag <span\ class="tcy"><CR>
nnoremap <silent><buffer><leader>tr <Cmd>SurroundTag <ruby> <rp>(</rp><rt></rt><rp>)</rp><CR>
xnoremap <silent><buffer><leader>tr <Cmd>SurroundTag <ruby> <rp>(</rp><rt></rt><rp>)</rp><CR>
