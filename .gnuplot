set fontpath '~/Form/pfa'
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
