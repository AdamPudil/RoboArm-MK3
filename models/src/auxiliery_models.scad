$fn = 40;

// usefull modules

//cloning mirror
module mirror2(v) {
    children();
    mirror(v) children();
}


// hole for vertical printing (no suppurt)
module smart_hole(d = 10, h = 10, center = true, bridging = true) {
    difference() {
        union() {
            rotate([0,90,0])
                cylinder(d = d, h = h, center = center);
            translate([0,0,sqrt(2*d*d)/4])
                rotate([45,0,0])
                cube([h,d/2,d/2], center = center);
        }
        if(bridging)
            translate([0,0,d])
                cube([h+1,d,d], center = center);
    }
}

// for angled screw head 
// sh_d = screw head diameter
module smart_screw_hole(d = 3.2, h = 20, sh_d = 7, sh_h = 4, center = true, bridging = true) {
    smart_hole(d=d, h=h, center = center, bridging = bridging);
    translate([-h/2,0,])
        rotate([0,90,0])
        rotate_extrude(angle = 360)
        polygon([[d/2, sh_h],[ sh_d/2,0], [d/2,0], [d/2 - 2, 0], [d/2 - 2, sh_h]]);
}

function pulley_d_calc(teeth) = (2*((teeth*2)/(3.14159265*2)-0.254));

module pulley(teeth = 40, h = 12, sides = 0) {
    additional_tooth_width = 0.2; //mm
    additional_tooth_depth = 0.2; //mm

    
    pulley_OD = pulley_d_calc(teeth);
    tooth_depth = 0.764;
    tooth_width = 1.494;
    
	tooth_distance_from_centre = sqrt( pow(pulley_OD/2,2) - pow((tooth_width+additional_tooth_width)/2,2));
	tooth_width_scale = (tooth_width + additional_tooth_width ) / tooth_width;
	tooth_depth_scale = ((tooth_depth + additional_tooth_depth ) / tooth_depth) ;

    module GT2_2mm() {
        linear_extrude(height=h+2) polygon([[0.747183,-0.5],[0.747183,0],[0.647876,0.037218],
        [0.598311,0.130528],[0.578556,0.238423],[0.547158,0.343077],[0.504649,0.443762],[0.451556,0.53975],
        [0.358229,0.636924],[0.2484,0.707276],[0.127259,0.750044],[0,0.76447],[-0.127259,0.750044],
        [-0.2484,0.707276],[-0.358229,0.636924],[-0.451556,0.53975],[-0.504797,0.443762],[-0.547291,0.343077],
        [-0.578605,0.238423],[-0.598311,0.130528],[-0.648009,0.037218],[-0.747183,0],[-0.747183,-0.5]]);
    }   

	difference() {	
		rotate ([0,0,360/(teeth*4)]) 
		cylinder(r=pulley_OD/2,h=h, $fn=teeth*4);
	
		//teeth - cut out of shaft
		
		for(i=[1:teeth]) 
        rotate([0,0,i*(360/teeth)]) 
        translate([0,-tooth_distance_from_centre,-1]) 
        scale ([ tooth_width_scale , tooth_depth_scale , 1 ]) 
        {
         GT2_2mm();
        }
	}	
    if ( sides > 0 ) {
        translate ([0,0, h - sides]) 
        rotate_extrude($fn=teeth*4)  
        polygon([[0,0],[pulley_OD/2,0],[pulley_OD/2 + sides , sides],[0 , sides],[0,0]]);
    }
		
    if ( sides > 0 ) {
        translate ([0,0,0 ]) 
        rotate_extrude($fn=teeth*4)  
        polygon([[0,0],[pulley_OD/2 + sides,0],[pulley_OD/2 , sides],[0 , sides],[0,0]]);
    } 
}

module belt_connector_round(teeth = 40, h = 8, belt_thick = 1, wall_thick = 5, wall_ang = 90, outer_d = 40) {
    pulley(teeth = 40, h = 8);
    
    wall_inner_r = pulley_d_calc(teeth) / 2 + belt_thick;
    
    if(outer_d / 2 - wall_inner_r > wall_thick) 
    {  
        echo("here");
        wall_center_r = (pulley_d_calc(teeth) + outer_d / 2 - wall_inner_r) / 2 + belt_thick;
        
        rotate_extrude(angle = wall_ang)
        translate([wall_center_r,h / 2,0])
        square([outer_d / 2 - wall_inner_r, h], center = true);
    } else {  
        wall_center_r = (pulley_d_calc(teeth) + wall_thick) / 2 + belt_thick;
        
        rotate_extrude(angle = wall_ang)
        translate([wall_center_r,h / 2,0])
        square([wall_thick, h], center = true);
    }
}

module motor_s_cutout(screw_l = 3) {
	//todo get dimension
	motor_w = 12;
	motor_d = 10;
	gear_h = 8; // get real
	motor_h = 15.2 + gear_h + 5;

	shaft_d = 4;
	shaft_l = screw_l;
	
	//ssrews
	screws_cnt = 2;
	screw_offset = 9 / 2;  
	screw_d = 1.6;
	screw_top_d = 2.4;
	screw_top_off = (screw_d - screw_top_d) / 2;

	translate([0, 0, - motor_h / 2])
		cube([motor_w, motor_d, motor_h], center = true);
	translate([0, 0, + shaft_l / 2])
		cylinder(d = shaft_d, h = shaft_l, center = true);
	mirror2([1,0,0])
		translate([screw_offset, 0, + screw_l / 2]) {
			cylinder(d = screw_d, h = screw_l, center = true);

			rotate_extrude()
				polygon([[screw_d / 2	 , screw_l / 2],
						 [screw_top_d / 2, screw_l / 2],
						 [screw_d / 2	 , screw_l / 2 + screw_top_off]]);
			}
}

motor_s_cutout();

module motor_m_cutout() {

}

module motor_l_cutout() {

}

/*
difference() {
    union() {
        pulley(teeth = 20, h = 10, sides = 2);
        translate([0,0,-3])
            cylinder(h = 6, d = pulley_d_calc(20) + 4, center = true, $fn = 20 * 4);
        translate([0,0,10.5])
            cylinder(h = 1, d = pulley_d_calc(20) + 4, center = true, $fn = 20 * 4);
    }
    
    cylinder(d = 4.5, h = 30, center = true);
    translate([0, 4.2, -3])
        cube([6, 3, 7], center = true);
    translate([0, 10, -3])
        rotate([90,00,0])
            cylinder(h = 20, d = 3.2, center = true);
}
*/

/*translate([0, 0, 0])
    cube([40,40,5], center = true);
rotate([0,0,135])
    belt_connector_round();
*/
/*
difference() {
    union() {
        translate([-200/2, 0, -2.5])
            cube([200,30,5], center = true);
        translate([0,0,-2.5])
            cylinder(h = 5, d = 30, center = true);
        translate([-200,0,-2.5])
            cylinder(h = 5, d = 30, center = true);
        rotate([0,0,135])
            belt_connector_round();
    }
   
    cylinder(h = 20, d = 8, center = true);
    translate([-50, 0, -2.5])
        cylinder(h = 20, d = 8, center = true);
    translate([-100, 0, -2.5])
        cylinder(h = 20, d = 8, center = true);
    translate([-150, 0, -2.5])
        cylinder(h = 20, d = 8, center = true);
    translate([-200, 0, -2.5])
        cylinder(h = 20, d = 8, center = true);
}*/
/*
//smart_hole();
difference() {
    cube([30,60,60], center = true);
    smart_screw_hole(d = 30, h = 30, sh_d = 40, sh_h = 5);
    
}*/