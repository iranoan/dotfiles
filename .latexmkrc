# vim: set filetype=perl : vim のモードラインを使って Perl スタイルで表示されるようにしておく
$lualatex_silent = 'lualatex -shell-escape -synctex=1 -file-line-error  -interaction=nonstopmode';
$lualatex = 'lualatex -shell-escape -synctex=1 -file-line-error';
$pdflualatex  = $lualatex;
$biber = 'biber %O --bblencoding=utf8 -u -U --output_safechars %B';
$bibtex = 'bibtex %O %B';
$latex = 'uplatex -src-specials -synctex=1 -file-line-error';
$latex_silent  = 'uplatex -src-specials -synctex=1 -file-line-error -interaction=nonstopmode'; # latexmk hoge.tex -silent で使われる
# -file-line-error             GCC のエラーの出力形式を追加
# -halt-on-error               最初のエラーが出た時点で処理を止めるオプション.結果的に出力されるエラーを少なく
# -interaction=nonstopmode     エラーが有っても止まらない
# $bibtex = 'upbibtex';
$dvipdf  = 'dvipdfmx %O -o %D %S';
$makeindex  = 'upmendex %O -o %D %S';
#$dvi_previewer ='start dviout';
$dvips  = 'dvipsk';
# $pdf_previewer = '/usr/bin/zathura -s -x "gvim -p --remote-tab-silent +%{line} %{input}" %S';
$pdf_previewer = '/usr/bin/zathura -x "gvim -p --remote-tab-silent +%{line} %{input}" %S';
# $pdf_previewer = 'zathra-sync.sh -l %{line} %S';
$pdf_mode = 4;
# 0 の場合, $latex コマンドを実行するだけ.PDF は生成しない
# 1 の場合, $pdflatex コマンドによって PDF を生成する
# 2 の場合, $latex コマンドを実行した後, $dvips コマンドで一旦 PS ファイルを生成し, ps2pdf コマンドで PS ファイルを PDF ファイルに変換する
# 3 の場合, $latex コマンドを実行した後, $dvipdf コマンドで PDF ファイルに変換する
# 4 の場合, $lualatex コマンドによって PDF を生成する
# 5 の場合, $xelatex コマンドを実行した後, $xdvipdfmx コマンドで PDF ファイルに変換する
$pdf_update_method = 0;
$do_cd = 1; # -cd オプション相当 コマンド実行前にソースファイルのディレクトリに移動→ファイル出力先はソースファイルが存在するフォルダに
# $pvc_timeout_mins [30] # -pvc オプションを使った時に、終了させる時間 (分)
