use </home/adam/3D_printing/scadlibs/BOSL-master/threading.scad>;

trapezoidal_threaded_rod(d=10, l=40, pitch=4, thread_depth = 1, thread_angle=50, starts=2, $fn=32);

translate([0,20,0])
trapezoidal_threaded_nut(od=16, id=10, h=8, pitch=4, thread_depth = 1, thread_angle=50, slop=0.2, starts=2, $fn=32);