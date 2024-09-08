"man 用の設定
scriptencoding utf-8
if exists('b:did_ftplugin_user')
	finish
endif
let b:did_ftplugin_user = 1

"--------------------------------
"ファイルタイプ別のグローバル設定
"--------------------------------
" 特殊な読み込みをしているので、~/.config/vim/pack/my-plug/opt/man/plugin/man.vim で指定しないと無効
"--------------------------------
"ファイルタイプ別ローカル設定
"--------------------------------
setlocal nolist
setlocal nospell
setlocal foldmethod=indent foldenable foldlevelstart=99 foldcolumn=3
" setlocal iskeyword=@,40,41,48-57,_,192-255,.,-   " セクション指定のために () を追加 (man(3) の様に () を含みたい時は、<C-]> を使えば良い (iskeyword に含めてしまうと関数 strstr(char) 問板記述のときに扱いにくくなる))
setlocal keywordprg=:Man
