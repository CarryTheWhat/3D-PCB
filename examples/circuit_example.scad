use <../MCAD/regular_shapes.scad>;
use <../MCAD/shapes.scad>;
include <../3D-PCB/3D-PCB.scad>;

num_col = 5;
num_row =4;

buffer = 8;
length = get_component_distance()*2 * num_col + buffer;
width = get_component_distance()*2 * num_row + buffer*2;
spacing = get_component_distance();
col_width = spacing * 2;
echo(length, width);

translate([spacing / 4, 0, 0])
base_board(length,width,0.7);

//first row
translate([length/2 - buffer,-spacing,0]) rotate([0,0,90]) battery_holder_AA();
translate([length/2 - buffer, width/2 - buffer - spacing, 0]) peg();

// second row
translate([length/2 - col_width*1 - buffer,0,0])
union() {
	translate([0,width/2 - spacing - buffer,0]) rotate([0,0,180]) SPST_slide_switch_base();
	translate([0,width/2 - spacing*5 - buffer,0]) rotate([0,0,-90]) component_LED();
	translate([0,spacing,0]) rotate([0,0,-90]) component_resistor(); // 1k
	translate([0,-width/2 + buffer,0]) peg();
}

// third row
translate([length/2 - col_width*2 - buffer,0,0])
union() {
	translate([-spacing,width/2 - buffer,0]) component_resistor();
	translate([0,width/2 - buffer - spacing*3]) rotate([0,0,90]) component_transistor();
	translate([spacing,width/2 - buffer - spacing*4]) component_capacitor();
	translate([0,-width/2 + buffer + spacing]) rotate([0,0,90]) component_resistor();
}

// fourth row
translate([length/2 - col_width*3 - buffer,0,0])
union() {
	translate([0,width/2 - buffer - spacing * 3,0]) component_resistor();
	translate([0,width/2 - buffer - spacing * 2,0]) component_capacitor();
	translate([-spacing,width/2 - buffer - spacing*4]) rotate([0,0,90]) component_transistor();
	translate([-spacing,-width/2 + buffer,0]) peg();
	translate([-spacing,-width/2 + buffer + spacing*2,0]) rotate([0,0,90]) trace_hop();
}

// fifth row
translate([length/2 - col_width*4 - buffer,0,0])
union() {
	translate([-spacing,width/2 - buffer - spacing * 5,0]) rotate([0,0,90]) component_capacitor();
	translate([-spacing,width/2 - buffer,0]) peg();
}










