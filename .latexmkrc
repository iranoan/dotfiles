# vim: set filetype=perl : vim のモードラインを使って Perl スタイルで表示されるようにしておく
$latex         = 'uplatex -src-specials -synctex=1 -file-line-error';
$latex_silent  = 'uplatex -src-specials -synctex=1 -file-line-error -interaction=nonstopmode'; # latexmk hoge.tex -silent で使われる
# -file-line-error             GCC のエラーの出力形式を追加
# -halt-on-error               最初のエラーが出た時点で処理を止めるオプション.結果的に出力されるエラーを少なく
# -interaction=nonstopmode     エラーが有っても止まらない
$bibtex = 'upbibtex';
$dvipdf  = 'dvipdfmx %O -o %D %S';
$makeindex  = 'mendex -lrcg -d hiro';
#$dvi_previewer ='start dviout';
$dvips  = 'dvipsk';
# $pdf_previewer = '/usr/bin/zathura -s -x "gvim -p --remote-tab-silent +%{line} %{input}" %S';
$pdf_previewer = '/usr/bin/zathura -x "gvim -p --remote-tab-silent +%{line} %{input}" %S';
# $pdf_previewer = 'zathra-sync.sh -l %{line} %S';
$pdf_mode = 3;
$pdf_update_method = 0;
$do_cd = 1; # -cd オプション相当 コマンド実行前にソースファイルのディレクトリに移動→ファイル出力先はソースファイルが存在するフォルダに
# $pvc_timeout_mins [30] # -pvc オプションを使った時に、終了させる時間 (分)
