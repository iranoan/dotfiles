#!/bin/gawk -f
# TSV を | で列の揃った形式で出力
# セル内改行には未対応
# 空のセルは左と結合して扱う

function get_wide( x ){ # 全角扱いの文字数を得る
		gsub(/[ -~]/, "", x)
		return length( x )
}

function output(){
	for( i = 1; i < line; i++){# 結合扱いのセルは覗いて列ごと最大セル幅の取得
		for( j = 1; j <= column; j++ ){
			if( j != column && char_num[i, j + 1] == 0 )continue
			w = ascii[i, j] + wides[i, j] * 2
			if( max_c[j] < w )max_c[j] = w
		}
	}
	for( i = 1; i < line; i++){# 結合扱いのセルの処理 (幅の再計算)
		for( j = 1; j <= column; j++ ){
			if( j != column && char_num[i, j + 1] != 0 )continue
			width = max_c[j]
			for( k = j + 1; k <= column; k++ ){
				if( char_num[i, k] != 0 )break
				width += max_c[k] + 1
			}
			w = ascii[i, j] + wides[i, j] * 2
			if( width < w )max_c[j] += w - width
			j = k - 1
		}
	}
	for( i = 1; i < line; i++){# 結合扱いのセルの処理 (セルの内容)←上で列幅が変わり得るので全て終わってからやっている
		for( j = 1; j <= column; j++ ){
			if( j != column && char_num[i, j + 1] != 0 )continue
			width = max_c[j]
			for( k = j + 1; k <= column; k++ ){
				if( char_num[i, k] != 0 )break
				width += max_c[k] + 1
			}
			line_str[i, j] = sprintf( "%-"( width - wides[i, j] )"s", line_str[i, j] )
			j = k - 1
		}
	}
	for( i = 1; i < line; i++){
		x = line_str[i, 1]
		match(x, /^[+-]?[0-9.,]+([Ee][-+][0-9]+)?$/ )
		if( RLENGTH != -1 )str = sprintf( "%"( max_c[1] - wides[i, 1] )"s", x )
		else str = sprintf( "%-"( max_c[1] - wides[i, 1] )"s", x )
		for( j = 2; j <= column; j++ ){
			x = line_str[i, j]
			if( x == "")continue
			match(x, /^[+-]?[0-9.,]+([Ee][-+][0-9]+)?$/ )
			if( RLENGTH != -1 )str = str"|"sprintf( "%"( max_c[j] - wides[i, j] )"s", x )
			else str = str"|"sprintf( "%-"( max_c[j] - wides[i, j] )"s", x )
		}
		print str
	}
}

BEGIN{
	FS = "\t"
	line = 1
	column = 1
}
{
	if( $0 ~ /^[ \t]*$/ ){
		output()
		line = 1
		column = 1
		print ""
	}
	else{
		for( i = 1; i <= NF; i++ ){
			line_str[line, i] = $i
			char_num[line, i] = length( $i )
			wides[line, i] = get_wide( $i )
			ascii[line, i] = char_num[line, i] - wides[line, i]
		}
		line++
		if( column < NF )column = NF
	}
}

END{
	output()
}
