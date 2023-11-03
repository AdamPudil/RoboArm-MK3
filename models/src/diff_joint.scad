include </home/adam/3D_printing/scadlibs/BOSL2/std.scad>;
include </home/adam/3D_printing/scadlibs/BOSL2/gears.scad>;
use <auxiliery_models.scad>

//---------------------------------
//		differential drive
//---------------------------------

// general gear settings
d_g_mm_per_tooth = 6;
d_g_twist = 22.5;
d_g_slices = 10;
d_g_thickness = 10;

// side gears
s_g_teeth_cnt = 32;
s_g_hole_d = 8;

// side gear belt 
s_g_b_sides = 2;
s_g_b_w = 6 + 2 * s_g_b_sides;
s_g_b_teeth_cnt = 20;

// center gear
c_g_teeth_cnt = 32;
c_g_hole_d = 8;

// center holder
c_h_w = 15;
c_h_d = 25;
c_h_top_d = c_h_w;
c_h_l = pitch_radius(d_g_mm_per_tooth, s_g_teeth_cnt) - (d_g_thickness / 2); 

// gear offsets
s_g_offset = pitch_radius(d_g_mm_per_tooth, c_g_teeth_cnt);
c_g_offset = pitch_radius(d_g_mm_per_tooth, s_g_teeth_cnt);
s_g_b_offset =  (-c_h_w / 2) - s_g_b_w ;

// filling space from belt to gear
s_g_b_dist_l = 10;
s_g_b_dist_d = pulley_d_calc(s_g_b_teeth_cnt) 
			 + 2 * s_g_b_sides;
s_g_b_dist_offset = s_g_b_offset 
				  - (s_g_b_dist_l / 2);

// differencial holding plates
d_plate_w = 60;
d_plate_thick = 5;
d_plate_offset = 40;
d_plate_l = 80;

// arm center piece
center_w = d_plate_w;
center_h = d_plate_w;
center_l = 300;
center_end_w = (d_plate_offset * 2) - d_plate_thick;
center_end_thick = (center_end_w - center_w) / 2;
center_end_l = d_plate_l + (center_end_w - center_w) / 2;
diff_cutout_d = 2 * 50;

 


module side_gear() {
	translate([0, s_g_offset, 0])
		bevel_gear(circ_pitch 	= d_g_mm_per_tooth,
				teeth 			= s_g_teeth_cnt, 
				shaft_diam 	 	= 0, 
				face_width		= d_g_thickness,
				mate_teeth		= c_g_teeth_cnt,
				slices = d_g_slices, orient = FWD, spiral_angle = d_g_twist);
		
	difference() {
		union() {
			translate([0, -s_g_b_offset, 0])
				rotate([90, 0, 0])
					pulley(teeth = s_g_b_teeth_cnt, 
							h = s_g_b_w, 
							sides = s_g_b_sides);
			translate([0, -s_g_b_dist_offset, 0])
				rotate([-90, 0, 0])
					cylinder(h = s_g_b_dist_l, 
							 d = s_g_b_dist_d, 
							 center = true, $fn = 64);
			
		}

		translate([0, s_g_b_offset / 2, 0])
			rotate([-90, 0, 0])
			cylinder(d = s_g_hole_d, h = s_g_offset,
					center = true);
	}
}

module center_gear() {
	translate([c_g_offset,0,0]) 
		rotate([360 / (c_g_teeth_cnt * 2), 0, 0])
		bevel_gear(circ_pitch 	= d_g_mm_per_tooth,
					teeth 		= c_g_teeth_cnt, 
					shaft_diam = 0, 
					face_width = d_g_thickness,
					mate_teeth = s_g_teeth_cnt,
					slices = d_g_slices, orient = LEFT, 
					spiral_angle = d_g_twist, left_handed = true);
}

module center_holder() {
	rotate([90,0,0])
		cylinder(h = c_h_w, d = c_h_d, 
				 center = true, $fn = 50);
	translate([c_h_l / 2, 0, 0])
		cube([c_h_l, c_h_w, c_h_top_d], center = true);
}

module side_plate() {
	translate([0,d_plate_offset,0])
		rotate([90,0,0])
		cylinder(d = d_plate_w, 
				 h = d_plate_thick, center = true);
	
	difference() {
		translate([-d_plate_l / 2, d_plate_offset, 0])
			cube([d_plate_l, d_plate_thick, d_plate_w], 
				 center = true);
		rotate([-90,0,0])
		rotate_extrude(angle = 360, $fn = 128)
			polygon([[d_plate_l, 		
					  d_plate_offset - d_plate_thick / 2],
					 [d_plate_l - d_plate_thick,
					  d_plate_offset + d_plate_thick / 2],
					 [d_plate_l + d_plate_w,
					  d_plate_offset + d_plate_thick / 2],
					 [d_plate_l + d_plate_w,
					  d_plate_offset - d_plate_thick / 2]]);
	}
}

module center_piece() {
  // positive modules
  module body() {
    translate([-center_l / 2,0,0])
				cube([center_l, center_w, center_h],
					  center = true);
  }
  
  module end_extrusion() {
    difference() {
      translate([-center_end_l / 2,0,0])
				cube([center_end_l, center_end_w, center_h],
					  center = true);
      mirror2([0, 1, 0])
      rotate([90,0,0])
        rotate_extrude(angle = 360, $fn = 128)
        polygon([[center_end_l, 		
                  center_end_w / 2 - center_end_thick],
                 [center_end_l - center_end_thick,
                  center_end_w / 2],
                 [center_end_l + d_plate_w,
                  center_end_w / 2],
                 [center_end_l + d_plate_w,
                  center_end_w / 2 - center_end_thick]]);
    }
  }
  
 // negative modules 
  
	difference() {
		union() {
			body();
			end_extrusion();
		}
		rotate([90,0,0])
			cylinder(h = center_end_w, d = diff_cutout_d
					,center = true, $fn = 64);
		
	}
}

color("RED")
side_gear();
rotate([0,0,180])
	color("ORANGE")
	side_gear();

color("GREEN")
center_holder();
center_gear();

color("GREEN")
center_piece();
mirror2([0,1,0])
	side_plate();