use </home/adam/3D_printing/scadlibs/BOSL-master/involute_gears.scad>;
use <auxiliery_models.scad>

// Global Variables
$fn = 100;  // Number of facets for rendering (adjust as needed)

// pinion
gear_h = 8;
gear_tooth_pitch = 4;
gear_teeth_cnt = 8;
gear_pres_angle = 25;
gear_hole_d = 3;
gear_hole_cut = 0.5;

// rack
rack_h = gear_h;
rack_w = 5;
rack_teeth_cnt = 8;
rack_added_ofset = 2.2;
rack_x_offset = gear_tooth_pitch / 2;
rack_y_offset = pitch_radius(gear_tooth_pitch, gear_teeth_cnt); 
	//+ rack_added_ofset;

// finger
f_finger_h = 50;
f_finger_d = 20;
f_finger_w = 24;

f_base_h = 16;
f_base_d = 15;

f_top_h = 20;
f_top_d = 10;
f_top_w = 20;

f_rack_cut_w = rack_w + 2;
f_rack_cut_h = gear_h + 2;
f_rack_cut_off = root_radius(gear_tooth_pitch, gear_teeth_cnt) 
                + rack_added_ofset + 1;
f_grip_cut_side = 3;
f_x_offset = (gear_tooth_pitch * rack_teeth_cnt);

// body
b_body_w = f_finger_w + 2 * 8;
b_body_l = 100; // todo calculate
b_body_h = f_base_h;

b_f_offset = 0.4;

b_hole_w = f_finger_w + b_f_offset;
b_hole_l = f_finger_d + (2 * gear_tooth_pitch * rack_teeth_cnt) + b_f_offset;

// rail
rail_h1 = 12;
rail_h2 = 6;
rail_w  = 3;

//backplate
b_plate_h = 4;
b_plate_w = b_body_w;
b_plate_l = b_body_l;
b_plate_offset = 10;

// motor dimensions // tido: get real dimensions
motor_w = 16;
motor_l = 30;


module pinion_gear() {
  translate([0,0,gear_h / 2])
    difference() {
      gear(mm_per_tooth=gear_tooth_pitch,
           number_of_teeth=gear_teeth_cnt, 
           thickness=gear_h, 
           pressure_angle=gear_pres_angle, 
           hole_diameter=0, backlash = 0.1);
      difference() {
        cylinder(h = gear_h, d = gear_hole_d, center = true);
        translate([(gear_hole_d - gear_hole_cut) / 2,0,0])
          cube([gear_hole_cut,gear_hole_d,gear_h], center = true);
      }
    }
}


module finger() {
  
  module f_rack() {
    // Rack module
    rack(mm_per_tooth=gear_tooth_pitch, number_of_teeth=rack_teeth_cnt, thickness=rack_h, height=rack_w,pressure_angle=gear_pres_angle, backlash = 0.1);
  }

  module f_body() {
    module base_cutout() {
      translate([f_finger_d / 2, 0, -f_base_h / 2])
        rotate([90,-90,0])
        linear_extrude(50, center = true)
        polygon([[0,-1], [0, f_finger_d - f_base_d], 
            [f_base_h, f_finger_d - f_base_d], 
            [f_base_h + f_finger_h - f_top_h, 0],
            [f_base_h + f_finger_h - f_top_h, -1]]);

    }

    module top_cutouts() {
      // side cuts
      mirror2([0,1,0])
        translate([0, f_finger_w/2, f_finger_h + f_base_h / 2])
        rotate([90,-90,90])
        linear_extrude(50, center = true)
        polygon([[0,-1],
                 [0, (f_finger_w - f_top_w) / 2], 
                 [0 - f_top_h, (f_finger_w - f_top_w) / 2],
                 [0 - f_finger_h, 0], 
                 [0 - f_finger_h, -1]]
            );
      // back cut
      translate([-f_finger_d/2, 0, f_finger_h + f_base_h / 2])
        rotate([90,-90,-180])
        linear_extrude(50, center = true)
        polygon([[0,-1],
                 [0, f_finger_d - f_top_d], 
                 [0 - f_top_h, f_finger_d - f_top_d],
                 [0 - f_finger_h, 0], 
                 [0 - f_finger_h, -1]]
            );
    }
  
	
    module grip_cutouts() {
      translate([f_finger_d /2, 0, f_finger_h + f_base_h / 2 - (            f_top_w / 2)]) 
				cube([f_grip_cut_side, f_top_w, f_top_h],            center = true);
		
    }
    
    module rack_cutout() {
      translate([0,-f_rack_cut_off,-(f_base_h - f_rack_cut_h)/2])
        cube([f_finger_d,f_rack_cut_w,f_rack_cut_h], center =true);
      
    }
	
    // model itself
    difference() {
      //baiic cube
      translate([0, 0, f_finger_h /2])
        cube([f_finger_d, f_finger_w, f_finger_h + f_base_h], center = true);
      base_cutout();
      top_cutouts();
      grip_cutouts();
      rack_cutout();
    }
  }

  module f_rail() {
    offset1 = (f_base_h - rail_h1) / 2; 
    offset2 = (f_base_h - rail_h2) / 2;
    
    mirror2([0,1,0]) 
      translate([-f_finger_d / 2, f_finger_w / 2, f_base_h / 2])
      rotate([0,90,0])
      linear_extrude(f_base_d)
        polygon([[offset1, 0],
                 [f_base_h - offset1, 0],
                 [f_base_h - offset2, rail_w],
                 [offset2, rail_w]]);
   
  } 
  

  // Instantiate rack and body
  rotate([0,0,180])
    translate([-rack_x_offset, -rack_y_offset,rack_h / 2 ]) {
    f_rack();
  }

  translate([-f_x_offset, 0, f_base_h / 2]) {
    f_body();
    f_rail();
  }
  
}


module body() { 
  module f_rail() {
    offset1 = (f_base_h - rail_h1) / 2; 
    offset2 = (f_base_h - rail_h2) / 2;
    
    mirror2([1,0,0])
    mirror2([0,1,0]) 
      translate([0, f_finger_w / 2, f_base_h / 2])
      rotate([0,90,0])
      linear_extrude(b_hole_l / 2)
        polygon([[offset1 - b_f_offset / 2, 0],
                 [f_base_h - offset1  + b_f_offset / 2, 0],
                 [f_base_h - offset2, rail_w + b_f_offset / 2],
                 [offset2, rail_w + b_f_offset / 2]]);
   
  } 
  
  difference() {
    cube([b_body_l, b_body_w, b_body_h],center = true);
    cube([b_hole_l, b_hole_w, b_body_h],center = true);
    f_rail();
  }
}

module backplate() {
  translate([0,0, - (b_plate_h / 2) - b_plate_offset])
    difference() {
		cube([b_plate_l, b_plate_w, b_plate_h], center = true);
		translate([0, 0, b_plate_h / 2 - 3])
			motor_s_cutout(screw_l = 3);
	}
}

finger_pos = 0; // in teeth

color("RED")
translate([0,0,b_body_h / 2])
  body();

backplate();

rotate([0,0,0])
  translate([finger_pos * gear_tooth_pitch,0,0])
  finger();

rotate([0,0,180])
  translate([finger_pos * gear_tooth_pitch,0,0])
  finger();

pinion_gear();
