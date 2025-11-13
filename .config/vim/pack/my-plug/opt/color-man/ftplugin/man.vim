vim9script
scriptencoding utf-8

setlocal nonumber norelativenumber
setlocal foldenable
setlocal nolist
setlocal nowrap
setlocal nospell
setlocal bufhidden=hide
setlocal nobuflisted
setlocal conceallevel=2 concealcursor=nvic
setlocal foldmethod=expr foldexpr=man#Fold() foldtext=man#FoldText()
setlocal foldlevelstart=99 foldcolumn=1

if get(g:, 'no_man_maps', 0) != 1
	nnoremap <buffer>q       <Cmd>quit!<CR>
	nnoremap <buffer>o       <Cmd>call man#Jump()<CR>
	nnoremap <buffer>K       <Cmd>call man#Jump()<CR>
	nnoremap <buffer><C-]>   <Cmd>call man#Jump()<CR>
	nnoremap <buffer><Tab>   <Cmd>call man#Tag(0)<CR>
	nnoremap <buffer><S-Tab> <Cmd>call man#Tag(1)<CR>
	nnoremap <buffer>#       <Cmd>call man#SearchWord(1)<CR>
	nnoremap <buffer>*       <Cmd>call man#SearchWord(0)<CR>
endif

# Undo {{{1
if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= ' | mapclear <buffer> | setlocal bufhidden< buflisted< buftype< concealcursor< conceallevel< filetype< foldcolumn< foldenable< foldexpr< foldmethod< foldtext< list< modifiable< number< relativenumber< spell< swapfile< wrap<'

else
	b:undo_ftplugin = 'mapclear <buffer> | setlocal bufhidden< buflisted< buftype< concealcursor< conceallevel< filetype< foldcolumn< foldenable< foldexpr< foldmethod< foldtext< list< modifiable< number< relativenumber< spell< swapfile< wrap<'
endif

