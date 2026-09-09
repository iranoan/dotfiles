scriptencoding utf-8

function!  set_general_function#init() abort
	" バイナリ判定+辞書データの子要素も含めてマージ $MYVIMDIR/pack/my-plug/opt/general-function/ {{{
	packadd general-function
	" }}}"
	call timer_start(1, {->execute('delfunction set_general_function#init')})
endfunction
