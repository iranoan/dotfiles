#!/bin/sh
# conky 様に cal コマンドの出力結果を整形して ncal -3 っぽい出力に整形する
# 当日、日曜、土曜日に ${color2}, ${color1}, ${color0} を付ける

transpose(){ # 行・列を入れ替える (出力はタブ区切り)
	grep -vE "^ +$" | # スペースのみの行は除外
	sed -E 's/   / @ /g' | # 空白要素をダミーに置き換え
	nawk '{ # 実際の入れ替えルーチン
			for (i=1; i<=NF; i++) {
				a[NR,i] = $i
			}
		}
		NF>p {
			p = NF
		}
		END {
			for(j=1; j<=p; j++) {
				str=a[1,j];
				for(i=2; i<=NR; i++){
					str=str"\t"a[i,j];
				}
				print str
			}
		}' |
	sed -E 's/@//g' # ダミー削除
}
calendar=$( LC_ALL=ja_JP.utf8 cal -3 ) # 日本語ロケールで前後3ヶ月取得
if cat <<-_EOF_ |
	$calendar
	_EOF_
	# 出力が
	#       12月 2018              1月 2019               2月 2019
	# 日 月 火 水 木 金 土  日 月 火 水 木 金 土  日 月 火 水 木 金 土
	#                    1         1  2  3  4  5                  1  2
	#  2  3  4  5  6  7  8   6  7  8  9 10 11 12   3  4  5  6  7  8  9
	#  9 10 11 12 13 14 15  13 14 15 16 17 18 19  10 11 12 13 14 15 16
	# 16 17 18 19 20 21 22  20 21 22 23 24 25 26  17 18 19 20 21 22 23
	# 23 24 25 26 27 28 29  27 28 29 30 31        24 25 26 27 28
	# 30 31
	# という「何月何年」で始まる形式と
	#                             2019
	#          1月                    2月                    3月
	# 日 月 火 水 木 金 土  日 月 火 水 木 金 土  日 月 火 水 木 金 土
	#        1  2  3  4  5                  1  2                  1  2
	#  6  7  8  9 10 11 12   3  4  5  6  7  8  9   3  4  5  6  7  8  9
	# 13 14 15 16 17 18 19  10 11 12 13 14 15 16  10 11 12 13 14 15 16
	# 20 21 22 23 24 25 26  17 18 19 20 21 22 23  17 18 19 20 21 22 23
	# 27 28 29 30 31        24 25 26 27 28        24 25 26 27 28 29 30
	#                                             31
	# と先頭行に年が表示され、次の行に月だけ表示の形式が有る
	grep -Eq "^\\s*[0-9]{4}$" ; then # 西暦だけの行が有るか? 有れば calendar データは 2 行目以降を使う
	calendar=$( cat <<-_EOF_ |
	$calendar
	_EOF_
	tail --line=+2 )
fi

# 1行目の 何月 何年取得
month=$( cat <<- _EOF_ |
	$calendar
	_EOF_
	head --line=1
)

# 曜日のみ+一週間分のみ
week=$( cat <<- _EOF_ |
	$calendar
	_EOF_
	head --line=2 |
	tail --line=1 |
	cut -b1-27
)

# 実際のカレンダー・日付部分
calendar=$( cat <<- _EOF_ |
	$calendar
	_EOF_
	tail --line=+3
)

# 先月カレンダー
last_month=$( cat <<- _EOF_ |
	$calendar
	_EOF_
	cut -c1-21
)

# 今月カレンダー
this_month=$( cat <<- _EOF_ |
	$calendar
	_EOF_
	cut -c22-43 |
	sed -E "s/(\<$( date +%d | sed -E 's/^0+//g')\>)/\$\{color2}\1\$\{color}/"
)

# 来月カレンダー
next_month=$( cat <<- _EOF_ |
	$calendar
	_EOF_
	cut -c44-65
)

cat << _EOF_ |
$month
_EOF_
	cut -b2-20,30-40,50-64 |
	sed -E -e 's/([0-9]+)      *([0-9]+月)/\1     \2/g'
cat <<- _EOF_ |
	$week
	$last_month
	$this_month
	$next_month
	_EOF_
	transpose |
	sed -E -e 's/([日月火水木金土])\t\t/\1    /g' \
		-e 's/([日月火水木金土])\t/\1 /g' \
		-e 's/\t\t/\t/g' \
		-e 's/\t$//g' \
		-e "s/\t(\$\{color2})?([0-9][0-9])/ \1\2/g" \
		-e "s/\t(\$\{color2})?([0-9])/  \1\2/g" \
		-e "1s/^/\${color1}/" \
		-e '1s/color}/color1}/' \
		-e "1s/$/\${color}/" \
		-e "7s/^/\${color0}/" \
		-e '7s/color}/color0}/' \
		-e "7s/$/\${color}/"
