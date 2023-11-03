use <auxiliery_models.scad> 

nut_M4_w = 7;
nut_M4_h = 3;
nut_M4_d = 8;

module body() {
	

}

module finger() {
	finger_h = 50;
	finger_d = 20;
	finger_w = 30;
	
	base_h = 16;
	base_d = 15;

	top_h = 20;
	top_d = 10;
	top_w = 20;
	
	grip_cut_side = 3;

	//modules
	module base_cutout() {
		translate([finger_d / 2, 0, -base_h / 2])
			rotate([90,-90,0])
			linear_extrude(50, center = true)
			polygon([[0,-1], [0, finger_d - base_d], 
					[base_h, finger_d - base_d], 
					[base_h + finger_h - top_h, 0],
					[base_h + finger_h - top_h, -1]]);

	}

	module top_cutouts() {
		// side cuts
		mirror2([0,1,0])
			translate([0, finger_w/2, finger_h + base_h / 2])
			rotate([90,-90,90])
			linear_extrude(50, center = true)
			polygon([[0,-1],
					[0, (finger_w - top_w) / 2], 
					[0 - finger_h, 0], 
					[0 - finger_h, -1]]
					);
		// back cut
		translate([-finger_d/2, 0, finger_h + base_h / 2])
			rotate([90,-90,-180])
			linear_extrude(50, center = true)
			polygon([[0,-1],
					[0, finger_d - top_d], 
					[0 - finger_h, 0], 
					[0 - finger_h, -1]]
					);
	}
	
	module grip_cutouts() {
		translate([finger_d /2, 0, finger_h + base_h / 2 - (top_w / 2)]) {
			rotate([0,45,0])
				cube([grip_cut_side, finger_w, grip_cut_side], center = true);
			rotate([0,0,45])
				cube([grip_cut_side, grip_cut_side, top_h], center = true);
		}
	}

	// model itself
	difference() {
		//baiic cube
		translate([0, 0, finger_h /2])
			cube([finger_d, finger_w, finger_h + base_h], center = true);
		base_cutout();
		top_cutouts();
		grip_cutouts();
	}
}

finger();