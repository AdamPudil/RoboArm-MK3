use </home/adam/3D_printing/scadlibs/BOSL-master/beziers.scad>;

M_PI = 3.14;

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
  total_length = total_rotations * sqrt(center_d * center_d + tooth_pitch * tooth_pitch);
  step_size = total_length / 100;  // Number of steps along the spiral

  // Functions for calculating x and y coordinates
  function calc_x(i) = (initial_radius + i * step_size) * cos(2 * M_PI * i / 100);
  function calc_y(i) = (initial_radius + i * step_size) * sin(2 * M_PI * i / 100);

  // Generate bezier path
  path = [
    for (i = [0:1:100]) [
      calc_x(i),
      calc_y(i),
      0
    ]
  ];

  extrude_2d_shapes_along_bezier(path) {
    tooth();
  }
}

  

disc();
