set term pngcairo
set title "Altitude Distribution ".ARG2
set style data histeps
set xrange [0:50000]
set yrange [0:250]
set xlabel "Altitude"
set ylabel "Count of planes"
plot ARG1 using 1:2
