vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user')
	finish
endif
b:did_ftplugin_user = 1

# Normal モード
nnoremap <buffer><silent>[     <Cmd>call fff#Bridge('ToggleListWrap')<CR>
nnoremap <buffer><silent>]     <Cmd>call fff#Bridge('TogglePreviewWrap')<CR>
# Insert/Normal モード
nnoremap <buffer><silent><C-y> <Cmd>call fff#Bridge('PreviewPageUp')<CR>
inoremap <buffer><silent><C-y> <Cmd>call fff#Bridge('PreviewPageUp')<CR>
nnoremap <buffer><silent><C-e> <Cmd>call fff#Bridge('PreviewPageDown')<CR>
inoremap <buffer><silent><C-e> <Cmd>call fff#Bridge('PreviewPageDown')<CR>
