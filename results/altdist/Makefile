DATE=20200205

${DATE}.gif: ${DATE}.png
	convert ${DATE}.png ${DATE}.gif

${DATE}.png: ${DATE}.dat altdistro.gnuplot
	gnuplot -c altdistro.gnuplot ${DATE}.dat ${DATE} > $@

${DATE}.dat: ../${DATE}-alts.dat
	perl ../../scripts/getdistribution.pl < ../${DATE}-alts.dat > $@

../${DATE}-alts.dat:
	perl ../../scripts/getalts.pl ${DATE} ${DATE} ../../data ../

animate:
	gifsicle --delay=20 --loopcount=forever ????????.gif > anim.gif
