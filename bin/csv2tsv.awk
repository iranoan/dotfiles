#!/bin/awk -f
# CSV を TSV に変換
# セル内改行には未対応

BEGIN{ OFS = "\t" }
{
	l = $0
	i = 1
	while ( 1 ){
		match(l, /("(""|[^"])*"|[^,]*),/)
		if( RLENGTH < 1 )break
		x = substr(l, 1, RLENGTH - 1)
		l = substr(l, RLENGTH + 1)
		match(x, /^".*"$/)
		if( RLENGTH >= 1 )x = substr(x, 2, RLENGTH - 1)
		gsub(/""/, "\"", x)
		$i = x
		i++
	}
	print $0
}
