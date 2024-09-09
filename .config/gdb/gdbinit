# GDB のグローバル設定
set auto-load safe-path ~
# ローカルな .gdbinit を読み込む
set auto-load local-gdbinit
# set environment LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib/debug
##########################################################################
# デバッグ対象が子プロセスを生成した時に、どちらのプロセスを
# デバッグ対象にするか選択する
##########################################################################
# set follow-fork-mode parent
#set follow-fork-mode child

##########################################################################
# デバッグ対象のスレッドのうち、デバッグ対象外のスケジューリングを制限する
##########################################################################
# 全てのスレッドが実行され、他のスレッドがデバッガに割り込める(breakポイントに達した、シグナルが送信されたなど)
#set scheduler-locking off
# カレントスレッドだけが実行される
# set scheduler-locking on
# シングルステップ時のみスケジューラがロックされる。
#set scheduler-locking step


##########################################################################
# C/C++ 共通
##########################################################################
# 構造体表示を1メンバ１行で見やすく表示する。
set print pretty on
# 配列を１要素１行で表示する/しない
set print array  off
# 共用体を表示する。
set print union  on
# 配列を表示する時の上限を設定する。0は無制限
set print elements 0
# 最初にNULLが検出された時点で、文字配列の表示を停止させる
set print null-stop
# 8ビット文字を表示する。
set print sevenbit-strings off
# シンボル表示をする時、ソースファイル名と行番号も表示する
# ただし、ローカル変数は除く
set print symbol-filename on
# 構造体等の定義と参照が別ファイルにあるとき、検索をする
set opaque-type-resolution on

##########################################################################
# C++ 専用
##########################################################################
# C++ オブジェクトの仮想クラスで実際のクラスを表示する
set print object on
# C++ オブジェクトの静的メンバを表示する
set print static-members on
# オーバーロードされた関数をGDBから呼び出す際に、シグネチャと引数の型がマッチするものを検索する
set overload-resolution on
# C++の仮想関数テーブルを綺麗に表示する。
set print vtbl   on
# C++のマングリングされた名前をソース通りに表示する。
set print demangle on
set print asm-demangle on
set demangle-style auto

##########################################################################
# その他
##########################################################################
#historyをsaveする。
# set history save on
# set history size 10000
# set history filename ~/.gdb_history
# コマンドの非同期実行時に完了通知を有効にする
set exec-done-display on
# オブジェクトファイル中の読み込み専用セクションが本当に読み込み専用であることをGDBに支持する。これにより、ターゲットプログラムからでなくオブジェクトファイルのセクションから値を取得することができる。
# デフォルトはoffだが組込み系ではこの設定で効率が上がることがあるそうだ。
set trust-readonly-sections on
#数値の入出力のデフォルト基数を10進数にする
set input-radix  10
set output-radix 10
#時間のかかるコマンドの実行中に情報を表示する。この表示によりGDBが異常な#状態になっていないか確認できる。
set verbose on
# GDBコマンド実行時に確認表示をしない。(breakポイントの削除時等)
set confirm off
