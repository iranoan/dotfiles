#!/bin/awk -f
# Vim help の部分プレビュー用
# grep -C と似た出力をさせる
# 行番号の表示はなく、ヒット部分を反転表示
# Vim help の幾つかの要素に色が付くようにカラーコードを追加する←サンプルコード部分は未実装
# Usage:
#       preview-vim-help.awk cline=line_number sword=search_sord file

function syntax_vim(a_line){ # Vim Help の色付け
	s_line = ""
	while( match(a_line, /(\|([^|]{2,})\||`([^`]{2,})`|(<[A-Za-z0-9-]{2,}>)|\y(CTRL-.)\y|\*([^*]+)\*|'\w{2,}'|\{\w{2,}\}|\[\w{2,}\])/) != 0 ){
		s_line = s_line substr(a_line, 1, RSTART - 1)
		match_word = substr(a_line, RSTART, RLENGTH)
		match_top = substr(match_word, 1, 1)
		a_line = substr(a_line, RSTART + RLENGTH)
		     if( match_top == "*" )s_line = s_line "\x1B[32m" substr(match_word, 2, RLENGTH - 2) "\x1B[39m"
		else if( match_top == "`" )s_line = s_line "\x1B[33m" substr(match_word, 2, RLENGTH - 2) "\x1B[39m"
		else if( match_top == "|" )s_line = s_line "\x1B[34m" substr(match_word, 2, RLENGTH - 2) "\x1B[39m"
		else if( match_top == "'" )s_line = s_line "\x1B[36m" match_word "\x1B[39m"
		else if( match_top == "<" )s_line = s_line "\x1B[31m" match_word "\x1B[39m"
		else if( match_top == "C" )s_line = s_line "\x1B[31m" match_word "\x1B[39m"
		else if( match_top == "[" )s_line = s_line "\x1B[31m" match_word "\x1B[39m"
		else if( match_top == "{" )s_line = s_line "\x1B[31m" match_word "\x1B[39m"
		# 30:黒、37:白 は背景色によっては見えなくなる
		# 35:マゼンダ 未使用
	}
	s_line = s_line a_line
	if( match(s_line, "~$") || match(s_line, "^[-=]+$") )s_line = "\x1B[31m" substr(s_line, 0, length(s_line) - 1) "\x1B[0m"
# |:keepmarks| command is used.  Example: >
# 	:keepmarks '<,'>!sort
# <			When the number of lines after filtering is less than
	return s_line
}

# BEGIN{
# 	FS = "."
# 	OFS = "."
# 	# print FILENAME ←効かない
# 	# # print sword 検索ワード
# 	# # print cline 出力する前後の行数
# }
{
	if( NR == 1 ){
		print FILENAME
		gsub(/\$/, "\\$", sword)
		gsub(/\*/, "\\*", sword)
		gsub(/\+/, "\\+", sword)
		gsub(/\|/, "\\|", sword)
		gsub(/\{/, "\\{", sword)
		gsub(/\}/, "\\}", sword)
		gsub(/\(/, "\\(", sword)
		gsub(/\)/, "\\)", sword)
		sline = 0
	}
	if( match($0, sword) ){
		sline = NR - cline
		if( sline < 0 )sline = 1
		gline = sline + cline * 2 + 1
		tagline = NR
	}
	line[NR] = $0 # 一旦全行格納
}
END{
	# ファイル最後の modeline による tabstop の値を取得
	tabstop = 8
	if(match($0, /^[ \t]*(vi|vim|ex):[ \t]*([a-z]+(=[a-z0-9]+)?[ :])*(ts|tabstop)=[0-9]+/) != 0){
		tabstop = substr($0, RSTART, RLENGTH)
		match(tabstop, /[0-9]+$/)
		tabstop = int( substr(tabstop, RSTART) )
		tab2space = sprintf("%" tabstop "s", " ")
	}
	# タグの場所より下の行数が少ない場合は、上の行を多く表示
	if( gline > NR ){
		sline = NR - cline * 2 - 1
		if( sline < 0 )sline = 1
		gline = NR
	}
	for( i = sline; i <= gline; i++){
		s_line = ""
		a_line = line[i]
		while( match(a_line, /\t+/) != 0 ){ # tabstop を考慮して空白に変換
			diff = substr(a_line, 1, RSTART - 1)
			gsub(/[ -ÿ]+/, "", diff)
			diff = RSTART + length(diff) - 1 # \xFF 以上は全て倍角扱い
			diff = diff - int(diff / tabstop) * tabstop
			if( diff != 0){
				match_tab = substr(a_line, RSTART, RLENGTH - 1)
				gsub(/\t/, tab2space, match_tab)
				s_line = s_line substr(a_line, 1, RSTART - 1) sprintf("%" tabstop - diff "s", " ") match_tab
			}
			else{
				match_tab = substr(a_line, RSTART, RLENGTH)
				gsub(/\t/, tab2space, match_tab)
				s_line = s_line substr(a_line, 1, RSTART - 1) match_tab
			}
			a_line = substr(a_line, RSTART + RLENGTH)
		}
		s_line = syntax_vim(s_line a_line)
		if( i == tagline)print "\x1B[7m" sprintf("%-80s", s_line) "\x1B[27m"
		else print s_line
	}
}
