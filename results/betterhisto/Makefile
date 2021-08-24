DATE=20200101

${DATE}.gif: ${DATE}.png
	convert ${DATE}.png ${DATE}.gif

${DATE}.png: ${DATE}.dat graph.gnuplot
	gnuplot -c graph.gnuplot ${DATE}.dat ${DATE} > $@

${DATE}.dat: ../../data/${DATE}/198.202.124.3-HPWREN?MW-ADSB?3?1?0
	perl ../../scripts/better_histo.pl ${DATE} ../../data .

animate:
	gifsicle --delay=20 --loopcount=forever ????????.gif > anim.gif
