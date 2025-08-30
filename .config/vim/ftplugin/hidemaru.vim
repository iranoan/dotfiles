scriptencoding utf-8

if exists('b:did_ftplugin_user')
	finish
endif
b:did_ftplugin_user = 1

setlocal commentstring=//%s
setlocal comments=://
setlocal iskeyword=a-z,A-Z,48-57,_
setlocal cindent
setlocal cinwords=if,else,while
setlocal cinscopedecls=
