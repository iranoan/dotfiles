vim9script

var awk: string = expand('<script>:p:h:h') .. '/bin/preview-vim-help.awk'
command! HelpTags call fzf#run({
			\ source:  fzf_help#HelpTags(),
			\ sink:    function('fzf_help#HelpTagsSink'),
			\ options: ['--ansi',
			\ 	'--tiebreak=begin',
			\ 	'--no-multi',
			\ 	'--separator', "\t",
			\ 	'--nth', '..4',
			\ 	'--with-nth', '..5',
			\ 	'--prompt', 'help> ',
			\ 	'--tabstop', '4',
			\ 	'--no-scrollbar',
			\ 	'--preview', awk
			\ 		.. ' cline=' .. (float2nr(get(g:, 'fzf_layout', {window: {width: 0.9, height: 0.6}})->get('window', {width: 0.9, height: 0.6}).height * &lines / 2) - 1)
			\ 		.. ' sword={6} {5}'
			\ 	],
			\ window: get(g:, 'fzf_layout', {window: {width: 0.9, height: 0.6}})->get('window', {width: 0.9, height: 0.6})
			\ }
			\ )
