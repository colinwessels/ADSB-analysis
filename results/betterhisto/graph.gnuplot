set term pngcairo
set title "Altitude Distribution ".ARG2
set style data filledcurves
set xdata time
set timefmt "%H:%M"
set xlabel "Time of Day (GMT)"
set ylabel "Count of planes"
set xtics format "%H:%M"
set xtics rotate
set yrange [0:250]
plot for [i=6:2:-1] ARG1 using 1:(sum [col=2:i] column(col)) with filledcurves x1 title sprintf("%d",10000*(i-1))
