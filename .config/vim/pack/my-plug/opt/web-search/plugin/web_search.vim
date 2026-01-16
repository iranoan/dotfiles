vim9script

if exists('g:web_search_plugin')
	finish
endif
g:web_search_plugin = 1

command -range SearchByGoogle call web_search#Google(<range>)
command -range SearchByAmazon call web_search#Amazon(<range>)
command -range SearchByWikiPedia call web_search#WikiPedia(<range>)
