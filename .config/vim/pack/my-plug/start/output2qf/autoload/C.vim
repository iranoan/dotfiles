vim9script
export var msg: dict<string> = {
	'Error detected while processing %s:': '^Error detected while processing \(.\{-}\):$',
	'Error detected while compiling %s:': '^Error detected while compiling \(.\{-}\):$',
	'line %4ld:': '^line\s\{-}\(\d\{-}\):$',
	'\tLast set from ': '^\tLast set from \(.\{-}\) $',
	'%s line %ld': '^Line \(\d\{-}\)$',
	'E123: Undefined function: %s': '^E123: Undefined function: ',
}
