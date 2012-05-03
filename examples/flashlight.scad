use <../MCAD/regular_shapes.scad>;
use <../MCAD/shapes.scad>;
include <../3D-PCB/3D-PCB.scad>;

spacing = get_component_distance();
board_length = 110; 
board_width = spacing * 3.7;
board_thickness = 2;
num_latches = 3; // number of catches where the shade meets the tube

extra_length = 25; // fix parametric
echo(board_length, board_width); // so you know
wall_thickness = 2;
tolerance = 1;


all_together_now(); 
//print_ped();

// for viewing
module all_together_now() {
	union() {
		translate([-spacing,0,board_thickness]) flashlight_top();
		translate([-spacing,0,-board_thickness]) rotate([0,180,180]) flashlight_bottom();
		translate([0,0,0]) flashlight_tube();
		translate([board_length / 2 - 10.4,0,0]) flashlight_cap();
	}
}

// with proper orientations
module print_ped() {
	//translate([-80,0,0]) rotate([0,-90,0]) flashlight_tube();
	//rotate([0,90,0]) flashlight_cap();
	//flashlight_top();
	//flashlight_bottom();
}

module flashlight_bottom () {
	difference() {
	    union() {
		    base_board(board_length,board_width, board_thickness);
		    translate([-spacing, board_width/6, 0]) battery_holder_AAA();
		    translate([-spacing, -board_width/6, 0]) battery_holder_AAA();
		    translate([board_length/2 - spacing * 5/8,0, 0]) rotate([0,0,90]) component_2_LEDs();
	    }
		poke_holes(); // add holes for threading
	}
}

module flashlight_top () {
	difference() {
	    union() {
			base_board(board_length,board_width, board_thickness);
	       	translate([board_length/2 - spacing * 5/8, 0, 0]) rotate([0,0,90]) component_2_LEDs();
	       	translate([board_length / 16, 0, 0]) SPST_slide_switch_base();
			translate([-board_length/2 + spacing, 0, 0]) peg();
	    }
		poke_holes(); // add holes for threading
	}
}

module flashlight_tube() {
	$fs = 0.1;
	difference() {
		union() {
			translate([-extra_length/2,0,0]) rotate([0,90,0]) rotate([0,0,6]) 
				cylinder(r=board_width/2 + wall_thickness, h=board_length + wall_thickness , center=true);
			translate([extra_length/2,0,0]) difference() {
				translate([-board_length/2 - extra_length, 0, 0]) sphere(r=board_width/2 + wall_thickness, center=true);
				translate([-board_length/2-extra_length - board_width*1.33, 0, 0]) cube(2*[board_width, board_width, board_width], center=true);
			}

			translate([board_length/2 - spacing,0,0]) rotate([0,90,0]) 
			difference() { // latch for catching
				cylinder(r=board_width/2 - tolerance/2, h=spacing, center=true);
				cylinder(r=board_width/2 - wall_thickness, h=spacing * 2, center=true);
			}
		}
		translate([wall_thickness + extra_length,0,0]) rotate([0,90,0]) 
				cylinder(r=board_width/2 - wall_thickness, h=board_length, center=true);
		translate([spacing*1/4 - tolerance*2,0,0]) // slot for board
			cube([board_length + spacing*2 + tolerance , board_width + tolerance, board_thickness * 2 + tolerance], center=true); 
		translate([-spacing,0,0]) pill(board_width/2 - spacing/16, board_length + spacing * 2); // make space for components
		translate([-extra_length+spacing,0,board_width+spacing/2]) rotate([90,0,0]) 
			cylinder(r=board_width, h=board_width * 4, center=true);
		
		// add notch for latching with the lid
		translate([board_length/2 - extra_length/2 + spacing/4,0,0]) rotate([0,90,0]) torus2(board_width/2, tolerance);

		// for debug printing, chop off the rest..
   		//translate([-board_length/2 + 20, 0, 0]) cube(3*[board_width, board_width, board_width], center=true);
	}
}

module flashlight_cap() {
	$fs = 0.1;
	cap_width = spacing;
	cap_thickness = spacing / 4;	
	shade_thickness = 1.2;
	shade_circles = 12;
	shade_circle_spacing = 12;
	shade_circle_radius = 12;
	echo(asdf);
	difference() {
		union() {
			rotate([0, 90, 0]) cylinder(r2 = board_width / 2 + wall_thickness + cap_thickness, h = cap_width, center=true);
			translate([cap_width, 0, 0]) rotate([0,90,0]) 
				cylinder(r=board_width/2 + wall_thickness + cap_thickness, h=cap_width, center=true);
		}
		rotate([0, 90, 0]) cylinder(r2 = board_width / 2,  r1 = board_width/2 - cap_thickness, h = cap_width * 4, center=true);
	}

	// ad shade part
	translate([cap_width*1.5 - shade_thickness/2, 0, 0]) rotate([0,90,0]) 
	difference() {
		cylinder(r=board_width / 2 + wall_thickness + cap_thickness/2, h= shade_thickness, center=true);
		cylinder(r=shade_circle_radius, h= shade_thickness*2, center=true);
	}

	// lip to hook on
	translate([-tolerance/2 + cap_width / 4,0,0]) rotate([0,90,0]) 
	difference() {
		cylinder(r2=board_width/2 + wall_thickness+ cap_thickness, r1=board_width/2 + wall_thickness, h=spacing/2 + tolerance, center=true);
		cylinder(r=board_width/2 + tolerance/2, h=spacing * 2, center=true);
	}
	// add the latches themselves
	translate([-cap_width/2 + spacing*19/32,0,0])
	intersection() {
		rotate([0,90,0]) torus2(board_width/2, tolerance * 1.1);
		cube([board_length + spacing*2 + tolerance , board_width + tolerance, board_thickness * 2], center=true); 
	}

	// add extra tube in the center to funnel light, but mostly to hold the circuit board in place..
	translate([(cap_width*1.5 - tolerance*2)/2 , 0, 0]) rotate([0,90,0]) 
	difference() {
		cylinder(r=shade_circle_radius + wall_thickness/2, h= cap_width*1.5 + tolerance*2, center=true);
		cylinder(r=shade_circle_radius, h= cap_width*4, center=true);
	}
}

module poke_holes() {
	hole_radius = 1.4;
	for(sign = [-1,1]) {
		translate([sign*(board_length/2 - hole_radius*2),board_width/2 - hole_radius*2,0]) cylinder(r=hole_radius, h=20, center=true);
		translate([sign*(board_length/2 - hole_radius*2),-board_width/2 + hole_radius*2,0]) cylinder(r=hole_radius, h=20, center=true);
		translate([sign*(board_length/2 - spacing),0,0]) cylinder(r=hole_radius, h=20, center=true);
	}
}

