scriptencoding utf-8

function! set_getmail_vim#main() abort
	if ( match(expand('%:p'), '^' .. $HOME .. '/.getmail/') == 0 && match(expand('%:p'), '^' .. $HOME .. '/.getmail/oldmail-') == -1 )
				\ || ( match(expand('%:p'), '^' .. $HOME .. '/.config/getmail/') == 0 && match(expand('%:p'), '^' .. $HOME .. '/.config/getmail/oldmail-') == -1 )
		if !is_plugin_installed#Main('getmail.vim')
			packadd getmail.vim
		endif
		set filetype=conf syntax=getmailrc
	endif
endfunction
