use <MCAD/regular_shapes.scad>;
use <MCAD/shapes.scad>;

// (c) 2012 christophercaswell@gmail.com
// 2012-04-30
// licensed under the Creative Commons - GNU LGPL license.
// http://www.gnu.org/licenses/lgpl-2.1.html
//
// links:
//   http://www.thingiverse.com/thing:18800
//   https://github.com/CarryTheWhat/3D-PCB
// 
// This is the library for hand-wound solder-free 3D-PCBs, version 0.2
// With this library, and a 3D printer (so far tested on pp3dp Up! and makerbot's Replicator)
// it is meant to be printed at the render orientation, with no raft and no support
// It includes the following components:
/*   note: this does not include helper functions or intermediary components

 -- power components --
battery_holder_AAA(count = 1) // by default, makes a holder for 1 battery
battery_holder_AA(count = 1) // but takes a parameter 'count' for several in series
battery_holder_button_cell(count = 1)

 -- component holders -- 
component_capacitor(diameter = 5.5)
component_LED(diameter = 5)   
component_2_LEDs(diameter = 5)
component_resistor()
component_transistor()

-- and tie it all together -- 
base_board(length, width, thickness)        - similar to a pcb, you can place on a board
peg(peg_height = 5, slot_width = 0.8)       - start and end point for traces
peg_cap()                                   - end cap, print separately
SPST_slide_switch_base()                    - base structure of slide switch
SPST_slide_switch_toggle()                  - sliding structure of switch, print separetly
trace_hop()                                        - for when traces cross, give two separate channels at 90 degree angle

-- functions for placing -- 
get_component_distance() = 13.5

*/

/* ------------ CONSTANTS AS FUNCTIONS ------------- */

function get_component_distance() = 13.5; // current spacing for a component (dist between pegs)

/* ------------ MODULES AND HELPER MODULES, ALPHABETICAL ORDER ------------- */

module base_board(length, width, thickness) {
	translate([0,0,-thickness/2]) cube([length, width, thickness], center=true);
}

// generic code for any size round, cylindrical battery
module battery_holder(length, width) {
	height = 10;
	offset=-1.75; // this moves the bettery springs tighter or looser; the more negative the tighter to hold the batteries
    error_tolerance = 1.05; // fit for batteries
    contact_width = 7; // radius of battery sphere holder
    min_wall_thickness = 3; // mm buffer on each side

	difference() {
		translate([0,0,height/2]) cube([length - offset * 2, width + min_wall_thickness*2, height], center=true);
		scale(error_tolerance*[1.5,1,1]) translate([0,0,height]) generic_battery(length, width);
	}

	difference() {
		union() {
			// one spring on either side of the battery
			translate([-length/2 - offset, 0,height/2]) rotate([0,0,-90]) battery_spring_sphere();
			translate([length/2 + offset, 0,height/2]) rotate([0,0,90])  battery_spring_sphere();
		}

		union() {
			// mark positive and negative
			translate([-length/2 - contact_width,0,height + contact_width]) cube([5,2,2], center=true); // neg
			translate([length/2 + contact_width,0,height + contact_width]) cube([5,2,2], center=true); // pos
			translate([length/2 + contact_width,0,height + contact_width]) cube([2,5,2], center=true);
		}
	}
}

module battery_holder_AAA(count = 1) {
	length = 43.75 * count;
	width = 10;
	battery_holder(length, width);
}

module battery_holder_AA(count = 1) {
	length = 50 * count;
	width = 14;
	battery_holder(length, width);
}

// any number of button cell watch batteries in series
module battery_holder_button_cell(count = 1) {
	length = 5.2 * count;
	width = 11.5;
	battery_holder(length, width);
}

module battery_spring_sphere() {
	$fs = 0.2;
	offset = -12;
	wind_gap = 0.8;
    contact_width = 7; // radius of battery sphere holder
    
	difference() {
	union() {
	translate([0,-contact_width,contact_width*3/4])
	difference() {
		union() {
			difference() {
				translate([0,-contact_width*0.25,0]) sphere(r=contact_width,center=true);
				translate([0,-contact_width*2,0]) cube(contact_width*2*[1,1,1], center=true); // chop off the back	
			}
			translate([0, 0,  - contact_width * 3/4]) // the cubes holding it up, begging to the board
			    cube([contact_width * 1.3,contact_width,contact_width *  3/2], center=true);			
			translate([0, 0, - contact_width * 3/2]) rotate([90,0,90])  // and sloped support
			    rightTriangle(contact_width * 3/2, contact_width * 3/2, contact_width * 1.6);
		}
		union() {
			translate([0, -contact_width/2,contact_width/2 + wind_gap*2]) rotate([45,0,0]) cube([contact_width*2,wind_gap,contact_width*1.5], center=true);
			cube([contact_width*2,wind_gap,wind_gap*4], center=true); // two slots for easy threading
			translate([0,-contact_width*0.25,0]) torus2(contact_width, wind_gap); // groove for wrapping
		}
	}
	translate([0,-contact_width/4 - wind_gap*3/4 ,contact_width*0.75]) cube([wind_gap * 4,wind_gap,wind_gap*4], center=true); // point of contact
	translate([0,-contact_width * 2 * 0.95,-contact_width * 0.25 * 0.95]) rotate([45,0,0]) peg(); // wrapping peg
	} // subtract an extra slot from the mass so that the cap will fit (hack.. fix me)
	translate([0,-contact_width * 2 * 0.95,-contact_width * 0.25 * 0.95]) rotate([45,0,0]) translate([0,0,4.9]) cube([0.8,21,8], center=true); // extra slot for cap
	}
}

module component_capacitor(diameter = 5.5) { 
	$fs = 0.2;
	difference(){
		component_resistor();
		cylinder(h=15, r=diameter/2, center=true);
	}
}

module component_LED(diameter = 5) { 
	$fs = 0.2;
	tolerance_adjustment = 1.23;
	LED_diameter = diameter * tolerance_adjustment; // to make the fit snug, by trial and error

	difference(){
		component_resistor(); // base structure
        cylinder(h=15, r=LED_diameter/2, center=true); // cut hole for vertical orientation
        translate([0,-5,5]) rotate([90,0,0]) cylinder(h=10, r=LED_diameter/2 * 0.95, center=true); // and for horizontal orientation
	}
}

module component_2_LEDs(diameter = 5) { 
	$fs = 0.2;
	tolerance_adjustment = 1.23;
	LED_diameter = diameter * tolerance_adjustment; // to make the fit snug, by trial and error

	difference(){
		component_resistor(); // base structure
		for(sign = [-1,1]) {
		    translate([sign * LED_diameter / 2,0,0])
		    union() {
                cylinder(h=15, r=LED_diameter/2, center=true); // cut hole for vertical orientation
                translate([0,-5,5]) rotate([90,0,0]) cylinder(h=10, r=LED_diameter/2 * 0.9, center=true); // and for horizontal orientation
            }
        }
        translate([0,get_component_distance() / 3, 0]) cube([1.6,10,15], center=true);
	}
	// final peg in back for shared lead
	translate([0,get_component_distance(),0]) peg();
}

module component_resistor() {
	union() {
		translate([get_component_distance(), 0, 0]) peg(); // holder pegs
		translate([-get_component_distance(), 0, 0]) peg();  // one and two[ 67.20, 0.00, 4.20 ]
		component_resistor_clip(); // main clip holding the resistor down
	}
}

module component_resistor_clip() { 
	resistor_length = 6;
	resistor_width = 2;
	clip_width = 15;
	clip_height = 6;
	clip_depth = 5;
	clip_gap = resistor_width * 1.5;
	difference() {
	    union() {
		    translate([0, clip_gap/2 + clip_depth/4, clip_height/2]) cube([clip_width, clip_depth/2, clip_height], center=true); // vertical component
		    translate([0,clip_gap/2 + clip_depth/4,0]) rotate([0,90,0]) rightTriangle(clip_height, clip_depth, clip_width); // supporting right triangle
		    translate([0, -clip_gap/2 - clip_depth/4, clip_height/2]) cube([clip_width, clip_depth/2, clip_height], center=true); // vertical component [mirror side]
		    translate([0,-clip_gap/2 - clip_depth/4,0]) rotate([180,90,0]) rightTriangle(clip_height, clip_depth, clip_width); // supporting right triangle
	    }
		translate([0, 0, clip_height * 3/8]) rotate([0,90,0]) cylinder(r=resistor_width * 1.15, h=resistor_length*2, center=true); // leave space for resistor
	}
}

module component_transistor() {
    spacing = get_component_distance();
	union() { // 3 pegs in a triangle
		translate([-spacing, 0, 0]) peg();
		translate([spacing, 0, 0]) peg();
		translate([0,spacing, 0]) peg();
	}
}

// This is a standard peg for winding thread around, or winding up as an end point
module peg(peg_height = 5, slot_width = 0.8) {
	$fs = 0.2;
	peg_radius_thin = 2.2;
	peg_radius_thick = 5;
	peg_gap = 1.6; // gap between peg, for winding thread
	slot_depth=4;
	num_slots=4;

	translate([0,0,peg_height/2 + peg_gap/4 - peg_gap/2]) // position on top of the board
	difference() {
	    union() {
	     	translate([0,0,0]) cylinder(h=peg_height/2 + peg_gap, r2=peg_radius_thick*0.95, r1=peg_radius_thick,center=true); // thick trunk of peg
		    translate([0,0,peg_height/4 + peg_gap]) cylinder(h=peg_gap*1.3, r=peg_radius_thick, center=true); // flat part leading to slant
		    translate([0,0,peg_height/4 + peg_gap*2]) cylinder(h=peg_gap, r1=peg_radius_thick, r2=peg_radius_thin, center=true); // slanted top
	    }
	    union() { // minus slots on the side
		    for( i= [0:num_slots] ) {
			    rotate(i*360/num_slots, [0,0,1])
			    translate([0,peg_radius_thick,0]) 
			    union() {
			        cube([slot_width,slot_depth,20],center=true);
			        translate([0,0,peg_height/2+peg_gap+slot_width]) cube([slot_width,peg_radius_thick*2,slot_width*10],center=true);
			    }
		    }
		    translate([0,0,peg_height * 1/4]) torus2(peg_radius_thick, slot_width); // torus winder
	    }
	}
}

module peg_cap() {
	$fs = 0.1;
	cap_depth = 5;
	radius = 6; // analogous to peg_radius_thick
	tolerance_adjustment = 1.25;
	// cap that goes over the peg, snaps in for sealing where necessary!
	rotate([0,180,0]) // orient for printing
	translate([0,0, - cap_depth * tolerance_adjustment / 2]) // place on platform
	scale([1,1,tolerance_adjustment])
	difference() {
		cylinder(r1 = radius * 0.75, r=radius * 0.75, h=cap_depth, center=true);
		translate([0,0,-5.5]) scale([1.5,1.5,1]) peg(5, 0.6);
	}
}

module SPST_slide_switch_base() {
	$fs = 0.2;
	throw_distance = 3.2; // full activation distance of switch
	off = 0;
	on = throw_distance ;
	is_on = on;
	base_height = 3; // dimensions of switch base, without the toggle piece
	base_length = 20;
	base_width = 8;
	slot_width = 4; // width of the central slot

    translate([-throw_distance * 6/8,0,0]) // align pegs for connecting
	difference() {
		union() {
			for(sign = [-1,1]) {  // both sides
				translate([base_length * 2/16, sign * base_width/2 ,base_height/2]) rotate([0,90,0]) cylinder(r=base_height/2, h=base_length * 10/8, center=true); // side cylinders
				translate([throw_distance * 6/8, sign * get_component_distance(), 0]) peg();
			}
			translate([base_length * 2/16, 0, base_height/2]) cube([base_length * 10/8, base_width, base_height], center=true);
			
		}
		for(sign = [-1,1]) { // minus spheres for catching (off & on)
			translate([base_length/2 - base_height/4, sign * (base_width/2 + base_height * 6/8), base_height/2]) sphere(r=base_height * 5/8, center=true); 
			translate([base_length/2 - base_height/4 + throw_distance, sign * (base_width/2 + base_height * 6/8), base_height/2]) 
						sphere(r=base_height * 5/8, center=true); 
		}
		cube([base_length * 2, slot_width, base_height * 3], center=true); // central slot
		translate([throw_distance * 7/8, 0, 0]) cube([slot_width, base_width * 2, base_height * 3], center=true); // extra gap where thread crosses
	}
    // for debug only
	//translate([is_on -base_length/2 ,0,4.5]) rotate([0,90,0]) SPST_slide_switch_toggle(throw_distance, base_length, base_width, base_height, slot_width);
}


module SPST_slide_switch_toggle(throw_distance = 3.2, length = 20, width = 8, height = 3, slot_width = 4) {
	$fs = 0.2;
	wall_thickness = 2;
	side_overhang = 8;
	width = width * 1.05;
	translate([0, 0, length/2])
	rotate([0,-90,0])
	difference() {
		union() {
			cube([length, width + side_overhang , wall_thickness], center=true);  // horizontal backbone
			difference() { // partial sphere at the top for grip
				translate([0,0,-length + height]) sphere(r=length * 1.027, center=true);
				translate([0,0,-length * 2 + height * 5/16]) cube([length * 4, length * 4, length * 4], center=true);
			}
			difference() {  // outside slide holders
				for(sign = [-1,1]) { translate([0, sign * (width + side_overhang) / 2 - sign*height/2, -height*3/4]) cube([length, height, height * 1.4], center=true); }
				for(sign = [-1,1]) { translate([0, sign* (width)/2, -height * 7/8]) rotate([0,90,0]) cylinder(r=height/2 * 1.1, h=length*2, center=true); }
				translate([slot_width/4,0,-slot_width]) rotate([90,90,0]) teardrop_cylinder(slot_width * 1.5, width * 2); // separate the spring part from top, thread gap
			}
			translate([-length / 2 + length * 1/4 + length * 1/32,0,-height]) cube([length * 9/16 , slot_width * 0.75, height*3/2], center=true); // central slot
			for(sign = [-1,1]) { 
				translate([length/2 - height/4, sign * (width + side_overhang) / 2 - sign*height * 3/4+ sign*height * 8/64, -height]) sphere(r=height * 8/16, center=true); 
			} //catch
		}
		translate([-length / 2 + length * 5/16,0,height*3/4]) cube([length * 2/4 , slot_width / 4, height], center=true); // topside wire groove
		translate([length * 1/16,0,height*3/4]) rotate([0,90,0]) cube([length , slot_width / 4, slot_width/4], center=true); // corner wire groove
		translate([-length/2,0, 0]) rotate([0,0,-90])  teardrop_cylinder(diameter=slot_width / 2, h=length); // corner wire groove other side
		translate([-length / 2 + length * 1/4,0,-height * 5/8 - height * 9/8]) cube([length * 3/4 , slot_width / 4, height], center=true); // bottomside wire groove

		translate([length * 9/16,0,0]) cube([length , slot_width/2, height*2], center=true); // large forward groove
		translate([height * 2 / 8,0,-height*9/16]) rotate([90,90,0]) teardrop_cylinder(diameter = height * 7/8, h=slot_width); // circular absense for the contact point

		translate([length / 2,0,-height*15/8]) cube([length * 2, width + side_overhang*2, height], center=true); // chop off the bottom
		for(sign = [-1,1]) { translate([throw_distance, sign * width * 23/8, height/2]) cylinder(r=width*2, h=height*4, center=true); } // sides of switch
		for(sign = [-1,1]) { translate([0, sign * width * 23/8, height/2]) cylinder(r=width*2, h=height*4, center=true); } // big cylinder slice on the sides
	}
}

module trace_hop() {
	$fs = 0.2;
	offset = -12;
	wind_gap = 0.8;
    contact_width = 7; // radius of battery sphere holder
    
	difference() {
	    difference() {
		    difference() {
		        union() {
			        sphere(r=contact_width,center=true);
			        difference() {
			            union() {
			                translate([wind_gap,0,0]) rotate([0,90,0]) cylinder(r=contact_width + wind_gap * 2, h= wind_gap*2, center=true);
			                translate([-wind_gap,0,0]) rotate([0,90,0]) cylinder(r=contact_width + wind_gap * 2, h= wind_gap*2, center=true);
			            }
			            rotate([0,90,0]) cylinder(r=contact_width*2, h= wind_gap, center=true);
			            translate([0,0,-contact_width*2]) cube(contact_width*4, center=true);
			        }
			    }
			    translate([0,0,-contact_width]) cube(contact_width*2*[1,1,1], center=true); // chop off the bottom	
		    }
		    union() {
			    translate([0, -contact_width/2,contact_width/2 + wind_gap*2]) rotate([45,0,0]) cube([contact_width*2,wind_gap,contact_width*1.5], center=true);
			    cube([contact_width*2,wind_gap,wind_gap*4], center=true); // two slots for easy threading
		    }
	    }
	    // and extra slot for orthoganal trace
	    translate([0,contact_width,contact_width / 2]) rotate([-45,0,0])  cube([0.8,21,8], center=true);
	}
}


/* ------------ HARDWARE MODULES DEFINED BELOW ------------- */

module AA_battery() {
	$fs = 0.2;
	battery_length = 50;
	battery_width = 14;
	generic_battery(battery_length, battery_width);
}

module AAA_battery() {
	$fs = 0.2;
	battery_length = 34.75;
	battery_width = 10;
	generic_battery(battery_length, battery_width);
}

module watch_battery_3x_stack() { // quickly step up to 4.5v ...
	$fs = 0.2;
	battery_length = 15.5;
	battery_width = 11.5;
	generic_battery(battery_length, battery_width, 0);
}

module generic_battery(battery_length, battery_width, with_positive_led=1) {
	$fs = 0.2;
	rotate([90,0,0])
	rotate([0,270,0])   // reorient to horizontal
	union() {
		cylinder(h=battery_length, r=battery_width/2, center=true); // primary cylinder of battery
		if(with_positive_led == 1) { // add positive led if applicable, eg AA, AAA
		    translate([0,0,-battery_length/2]) cylinder(h=1, r=2.5, center=true); 
		}
	}
}

/* ------------ HELPER FUNCTIONS ------------- */

function distance(A,B) = sqrt( (A[0] - B[0])*(A[0] - B[0]) + (A[1] - B[1])*(A[1] - B[1]) );

function midpoint(A,B) = [(A[0]+B[0])/2, (A[1]+B[1])/2];

module band(r1, r2, height) {
	difference() {
		cylinder(r=r1, h=height, center=true);
		cylinder(r=r2, h=height*2, center=true);
	}
}

module pill (radius, length) {
    $fn = 50;
	translate([-length/2 + radius,0,0]) sphere(r=radius, center=true);
	translate([length/2 - radius,0,0]) sphere(r=radius, center=true);
	rotate([3.5,0,0]) rotate([0,90,0]) cylinder(r=radius, h=length - radius * 2, center=true); // rotate extra to line up lines
}

module teardrop_2d(diameter) {
    union() {
	circle(r = diameter/2, $fn = 100, center=true);
      rotate(45) square(size=diameter/2,center=false);
    }
}

module teardrop_cylinder(diameter, h) {
	linear_extrude(height = h, center=true)
	teardrop_2d(diameter);
}

module teardrop_3d(diameter) {
	rotate_extrude(convexity = 10)
	translate([0.1, 0, 0]) // for some reason this is necessary to render
	teardrop_2d(diameter);
}

