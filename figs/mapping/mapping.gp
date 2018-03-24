#set terminal postscript eps color
#set out "mapping.eps"
set term pdfcairo font "Arial,20"
#set terminal pdfcairo enhanced color Arial,20
set out "mapping.pdf"

set xlabel "Reference x-coordinate" font ",20"
set ylabel "Reference y-coordinate" font ",20"
set size square
set nokey

plot "point.dat" w p pt 3 ps 1,"boundary.dat" w l lt -1 lw 4,"boundary-south.dat" w l lt 0 lw 4,"boundary-west.dat" w l lt 0 lw 4,"boundary-nw.dat" w l lt 0 lw 4,"boundary-north.dat" w l lt 0 lw 4,"boundary-ne.dat" w l lt 0 lw 4,"boundary-east.dat" w l lt 0 lw 4,"boundary-se.dat" w l lt 0 lw 4,'gll.dat' w p pt 7 ps 1

#plot "point.dat" w p pt 3 ps 2,"boundary.dat" w l lt -1 lw 8,"boundary-south.dat" w l lt 0 lw 3,"boundary-west.dat" w l lt 0 lw 3,"boundary-nw.dat" w l lt 0 lw 3,"boundary-north.dat" w l lt 0 lw 3,"boundary-ne.dat" w l lt 0 lw 3,"boundary-east.dat" w l lt 0 lw 3,"boundary-se.dat" w l lt 0 lw 3,'gll.dat' w p pt 7 ps 3
#test