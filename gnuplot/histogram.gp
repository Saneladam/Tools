# maxwellian.gp

load "style.gp"

set output "maxwellian.png"
set title "Maxwellian velocity distribution"

# constantes (puedes cambiarlas fácilmente)
m = 1.0
kB = 1.0
T = 1.0

vth = sqrt(2*kB*T/m)

f(v) = 4*pi*(m/(2*pi*kB*T))**(3.0/2.0) * v**2 * exp(-m*v**2/(2*kB*T))

set xlabel "v"
set ylabel "f(v)"

plot [0:5*vth] f(x) ls 1 title "Maxwellian"
