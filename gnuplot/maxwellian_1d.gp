load "style.gp"

set terminal pngcairo enhanced size 900,600
set output "maxwellian_1d.png"

set title "Normalized Maxwellian (1D)"
set xlabel "u"
set ylabel "f(u)"

f(x,T) = (1.0/sqrt(pi*T))*exp(-x**2/T)

set grid

plot [-4:4] \
    f(x,0.25) ls 1 lw 2 title "T = 0.25", \
    f(x,1.0)  ls 2 lw 2 title "T = 1", \
    f(x,2.0)  ls 3 lw 2 title "T = 2", \
    f(x,4.0)  ls 4 lw 2 title "T = 4"
