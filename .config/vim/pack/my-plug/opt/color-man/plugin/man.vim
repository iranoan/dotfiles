vim9script
scriptencoding utf-8
# Man コマンド使用可能に

command! -nargs=* -complete=customlist,man#Complete Man call man#ColorMan(<q-mods>, <f-args>)
command! -nargs=* -complete=customlist,man#Complete ColorMan call man#ColorMan(<q-mods>, <f-args>)
