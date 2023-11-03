use </home/adam/3D_printing/scadlibs/BOSL-master/beziers.scad>;

module disc(tooth_h = 5, tooth_up_w = 2, tooth_down_w = 5, tooth_pitch = 2, center_d = 5) {
  module tooth(h = tooth_h, up_w = tooth_up_w, down_w = tooth_down_w, tooth_pitch = tooth_pitch) {
    polygon(
      points = [
        [up_w/2, h],
        [-up_w/2, h],
        [-down_w/2, 0],
        [down_w/2, 0]
      ],
      paths = [
        [0, 1, 2, 3]
      ]
    );
  }

  // Constants
  initial_radius = center_d / 2;
  total_rotations = 3;  // Adjust as needed

  // Calculate parameters
  //total_length = total_rotations * sqrt(center_d * center_d + tooth_pitch * tooth_pitch);
  step_size = (tooth_down_w + tooth_pitch);  // Number of steps along the spiral

  // Functions for calculating x and y coordinates
  //function calc_x(i) = (i % 4 == 0) ? center_d / 2 + i * step_size : (i % 4 == 2) ? - center_d / 2 - i * step_size : 0;
  //function calc_y(i) = (i % 4 == 1) ? center_d / 2 + i * step_size : (i % 4 == 3) ? - center_d / 2 - i * step_size : 0;

  // Generate bezier path
  path = [
    for (i = [1:1:100]) 
      if     (i % 4 == 2) [  i * step_size , 0, 0] 
      else if(i % 4 == 0) [-(i * step_size), 0, 0]
      else if(i % 4 == 3) [0, -(i * step_size), 0]
      else if(i % 4 == 1) [0,   i * step_size , 0]
  ];
  
  echo(path);
      
  extrude_2d_shapes_along_bezier(path) {
    circle(d = 4);
  }
}

  

disc();
