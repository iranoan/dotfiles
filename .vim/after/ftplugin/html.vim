"HTML 用の設定
scriptencoding utf-8
if exists('b:did_after_ftplugin_user')
	finish
endif
let b:did_after_ftplugin_user = 1
let b:undo_ftplugin = 'unlet b:did_after_ftplugin_user'

"開く/閉じるタグの % 移動を再設定← ~/.vim/ftplugin/html.vim では駄目→help ftplugin-overrule
let b:match_words = '<\(\w\+\)[^>]*>:</\1>,' . &matchpairs " 箇条書き関係は対になるタグに移動ではなく、順に項目を移動していくの止め、単純に対で移動にする
