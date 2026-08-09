vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user')
	finish
endif
b:did_ftplugin_user = 1

if !get(g:fuzzy_file_finder, 'ftplugin', false)
	g:fuzzy_file_finder.ftplugin = true
	augroup FuzzyFileFinder
		autocmd!
		autocmd VimResized * fff#Bridge('VimResized')
		autocmd CmdwinEnter * fff#Bridge('CmdwinEnter')
		autocmd CmdwinLeave * fff#Bridge('CmdwinLeave')
	augroup END
endif

setlocal nonumber signcolumn=no foldcolumn=0
autocmd FuzzyFileFinder TextChangedI,TextChangedP,TextChanged <buffer> fff#Bridge('Render')

if !get(g:fuzzy_file_finder, 'mapping', true)
	finish
endif

# Normal モード
nnoremap <buffer><silent><Esc>      <Cmd>call fff#Bridge('Cleanup')<CR>
nnoremap <buffer><silent>gg         <Cmd>call fff#Bridge('MoveTop')<CR>
nnoremap <buffer><silent>G          <Cmd>call fff#Bridge('MoveLast')<CR>
nnoremap <buffer><silent>O          I
nnoremap <buffer><silent>o          A
# Insert / Normal モード双方からの操作
nnoremap <buffer><silent><CR>       <Cmd>call fff#Bridge('Confirm')<CR>
inoremap <buffer><silent><CR>       <Cmd>call fff#Bridge('Confirm')<CR>
nnoremap <buffer><silent><C-j>      <Cmd>call fff#Bridge('MoveDown')<CR>
inoremap <buffer><silent><C-j>      <Cmd>call fff#Bridge('MoveDown')<CR>
nnoremap <buffer><silent><C-n>      <Cmd>call fff#Bridge('MoveDown')<CR>
inoremap <buffer><silent><C-n>      <Cmd>call fff#Bridge('MoveDown')<CR>
nnoremap <buffer><silent><Down>     <Cmd>call fff#Bridge('MoveDown')<CR>
inoremap <buffer><silent><Down>     <Cmd>call fff#Bridge('MoveDown')<CR>
nnoremap <buffer><silent>j          <Cmd>call fff#Bridge('MoveDown')<CR>
nnoremap <buffer><silent><C-k>      <Cmd>call fff#Bridge('MoveUp')<CR>
inoremap <buffer><silent><C-k>      <Cmd>call fff#Bridge('MoveUp')<CR>
nnoremap <buffer><silent><C-p>      <Cmd>call fff#Bridge('MoveUp')<CR>
inoremap <buffer><silent><C-p>      <Cmd>call fff#Bridge('MoveUp')<CR>
nnoremap <buffer><silent><Up>       <Cmd>call fff#Bridge('MoveUp')<CR>
inoremap <buffer><silent><Up>       <Cmd>call fff#Bridge('MoveUp')<CR>
nnoremap <buffer><silent>k          <Cmd>call fff#Bridge('MoveUp')<CR>
nnoremap <buffer><silent><Tab>      <Cmd>call fff#Bridge('ToggleMark')<CR>
inoremap <buffer><silent><Tab>      <Cmd>call fff#Bridge('ToggleMark')<CR>
nnoremap <buffer><silent><PageDown> <Cmd>call fff#Bridge('MovePageDown')<CR>
inoremap <buffer><silent><PageDown> <Cmd>call fff#Bridge('MovePageDown')<CR>
nnoremap <buffer><silent><C-f>      <Cmd>call fff#Bridge('MovePageDown')<CR>
inoremap <buffer><silent><C-f>      <Cmd>call fff#Bridge('MovePageDown')<CR>
nnoremap <buffer><silent><PageUp>   <Cmd>call fff#Bridge('MovePageUp')<CR>
inoremap <buffer><silent><PageUp>   <Cmd>call fff#Bridge('MovePageUp')<CR>
nnoremap <buffer><silent><C-b>      <Cmd>call fff#Bridge('MovePageUp')<CR>
inoremap <buffer><silent><C-b>      <Cmd>call fff#Bridge('MovePageUp')<CR>
nnoremap <buffer><silent><C-]>      <Cmd>call fff#Bridge('TogglePreview')<CR>
inoremap <buffer><silent><C-]>      <Cmd>call fff#Bridge('TogglePreview')<CR>
