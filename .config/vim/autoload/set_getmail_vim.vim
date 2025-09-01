scriptencoding utf-8

function! set_getmail_vim#main() abort
	if ( match(expand('%:p'), '^' .. $HOME .. '/.getmail/') == 0 && match(expand('%:p'), '^' .. $HOME .. '/.getmail/oldmail-') == -1 )
				\ || ( match(expand('%:p'), '^' .. $HOME .. '/.config/getmail/') == 0 && match(expand('%:p'), '^' .. $HOME .. '/.config/getmail/oldmail-') == -1 )
		if !pack_manage#IsInstalled('getmail.vim')
			packadd getmail.vim
		endif
		set filetype=conf syntax=getmailrc
	endif
	call timer_start(1, {->execute('delfunction set_getmail_vim#main')})
endfunction
