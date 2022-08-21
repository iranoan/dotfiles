scriptencoding utf-8
" 本来は JSON にコメントはないが、.vimspectore.json 用
syntax region jsonComment start="/\*" end="\*/"
highlight link jsonCommentError Comment
highlight link jsonComment Comment
