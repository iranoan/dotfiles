vim9script
scriptencoding utf-8

if exists('b:did_ftplugin_user_after')
	finish
endif
 b:did_ftplugin_user_after = 1

setlocal formatoptions-=c textwidth=0 iskeyword-=# iskeyword+=? # デフォルト設定から好みに変更
# ? は is?, isnot? の syntax highlight を効かせるため
# ( 一度入れたが (ヘルプを引くときに :map, map() の違いで引きやすくする) map(ls, expr) で「map(ls」までが対象になる
# : 一度入れたが、vim9script の var variable_name: type の記述で単語検索しにくい

if exists('b:undo_ftplugin')
	b:undo_ftplugin ..= ' | call undo_ftplugin#Vim()'
else
	b:undo_ftplugin = 'call undo_ftplugin#Vim()'
endif
