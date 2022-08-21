scriptencoding utf-8
" syntax の追加
if exists('b:current_syntax_user')
	finish
endif
let b:current_syntax_user = 1
let b:undo_ftplugin = 'unlet b:current_syntax_user'

" 折りたたみ fold→https://stackoverflow.com/questions/7148270/how-to-fold-unfold-html-tags-with-vim 参照
syntax region htmlFold start="<\z(\<\(li\|dt\|dd\|area\|base\|br\|col\|command\|embed\|hr\|img\|input\|keygen\|link\|meta\|para\|source\|track\|wbr\>\)\@![a-z-]\+\>\)\%(\_s*\_[^/]\?>\|\_s\_[^>]*\_[^>/]>\)" end="</\z1\_s*>" fold transparent keepend extend containedin=htmlHead,htmlH\d
" 閉じタグ無くても OK のもの←箇条書きは省略できるだけだけだが、良い方法が解らない
