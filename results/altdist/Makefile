DATE=20200205

${DATE}.png: ${DATE}.dat
	gnuplot -c altdistro.gnuplot ${DATE}.dat > $@

${DATE}.dat: ../${DATE}-alts.dat
	perl ../../scripts/getdistribution.pl < ../${DATE}-alts.dat > $@

../${DATE}-alts.dat:
	perl ../../scripts/getalts.pl ${DATE} ${DATE}
