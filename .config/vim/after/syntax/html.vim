scriptencoding utf-8
" li, dt, dd タグも折りたたみ対象から除く

if &filetype ==# 'markdown' " デフォルトで markdown でも読み込まれるのを阻止
	finish
endif

syntax clear htmlFold
syntax region htmlFold start="<\z(\<\%(li\|dt\|dd\|area\|base\|br\|col\|command\|embed\|hr\|img\|input\|keygen\|link\|meta\|param\|source\|track\|wbr\>\)\@![a-z-]\+\>\)\%(\_s*\_[^/]\?>\|\_s\_[^>]*\_[^>/]>\)" end="</\z1\_s*>" fold transparent keepend extend containedin=htmlHead,htmlH\d
