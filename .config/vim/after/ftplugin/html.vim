vim9script
scriptencoding utf-8

if exists('b:did_after_ftplugin_user')
	finish
endif
b:did_after_ftplugin_user = 1

# 開く/閉じるタグの % 移動を再設定← ~/.config/vim/ftplugin/html.vim では駄目→help ftplugin-overrule
b:match_words = '<\(\w\+\)[^>]*>:</\1>,' .. &matchpairs # 箇条書き関係は対になるタグに移動ではなく、順に項目を移動していくの止め、単純に対で移動にする

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= '| setlocal breakindentopt< errorformat< foldmethod< formatlistpat< iskeyword< makeprg< omnifunc< spelloptions<'
else
	b:undo_ftplugin = 'setlocal breakindentopt< errorformat< foldmethod< formatlistpat< iskeyword< makeprg< omnifunc< spelloptions<'
endif
