set fontpath "/home/hiroyuki/Form/pfa"
GNUPLOT_PFBTOPFA="pfb2pfa %s"
#光速度
c=299792458	# FIXED
#Avogadro's number
A=6.0221415e+23	# FIXED
#fitting の為の関数
#Gussian
gaussian(x)=exp((x-mu)**2.0/(-2.0*sigma**2.0))/(sigma*sqrt(2.0*pi))
#n 次の関数
f1(x)=a*x+b
f2(x)=a0*x**2*a2*x+a3
#べき乗関数
g(x)=a*x**b
# https://sk.kuee.kyoto-u.ac.jp/person/yonezawa/contents/program/gnuplot/string_function.html
# 最大値
max(x,y)= ( (x) > (y) ) ? (x) : (y)
# strのindexより後の文字列の中でtargetが最後に出てくる場所を返す
strstrlt_sub(str,index,target)=(strstrt(substr(str, index, strlen(str)),target)==0 ? \
	max(index-strlen(target),0) : \
	strstrlt_sub(str, index-1+strstrt(substr(str, index, strlen(str)),target)+strlen(target),target))
# strの中でtargetが最後に出てくる場所を返す
strstrlt(str,target)=strstrlt_sub(str,1,target)
# pathからディレクトリ名に変換
dirname(path)=strstrt(path, "/")!= 0 ? substr(path, 1, strstrlt(path,"/")) : ""
# pathからディレクトリ名に変換
basename(path)=substr(path,strstrlt(path,"/")+1,strlen(path))
# pathからディレクトリと拡張子を消したものを返す
rmext(path)=strstrt(path, ".")==0 ? basename(path) : \
	basename(substr(path,1,strstrlt(path, ".")-1))
# path から拡張子に変換
extname(path)=substr(path,strstrlt(path,".")+1,strlen(path))
# 先頭が $HOME なら ~ に置き換える
homepath(path)=(strstrt(path, "`echo $HOME`/")==1 ? \
	sprintf("~/%s", path[strlen("`echo $HOME`/") + 1:strlen(path)]) : \
	path)
