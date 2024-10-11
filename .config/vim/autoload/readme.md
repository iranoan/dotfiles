# 置いてあるファイル

* set\_\*.vim は $MYVIMDIR/pack/\*/opt のプラグインごとの設定スクリプト
* 他は $MYVIMDIR/vimrc , $MYVIMDIR/gvimrc $MYVIMDIR/pack/\*/opt
  * から呼ばれる関数
  * キーマップによって呼ぼれる関数
* $MYVIMDIR/autoload/undo\_ftplugin.vim  
  b:undo\_ftplugin で指定するファイル・タイプ別設定のリセット用
