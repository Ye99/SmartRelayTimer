/* By: Ye Zhang (mr.yezhang@gmail.com)
   Date: June 6, 2020
    Touch pad bezel. To be embedded into panel. 
*/

use <roundedCube.scad>
include <screw_matrics.scad>

touch_pad_board_x_length=48.1;
touch_pad_board_y_length=79;
touch_pad_board_z_length=1.56;

screw_hole_y_distance=72.5;
screw_hole_x_distance=41;

first_hole_center_offset_y=3;
first_hole_center_offset_x=4;

// Leave square hole for pin wiring, and room for surface mounted chip.
pin_and_chip_hole_edge_length=20;

// Add extra wall to hide the extruded pins.
pin_cover_y_wall_thickness=1;
// Pin cover hides the soldering pins. Looks better and safer.
pin_cover_y_length=9+pin_cover_y_wall_thickness;
pin_cover_x_length=touch_pad_board_x_length;
pin_cover_z_length=6;


pin_cover_screw_sink_diameter=number4_screw_head_diameter + 0.5;
pin_cover_screw_sink_z_depth=2.8;

// this is for consumer use. Minimum hole depth for #4 5/16 screw to seat. 
base_screw_hole_z_depth=number4_screw_stem_length-(pin_cover_z_length-pin_cover_screw_sink_z_depth)-touch_pad_board_z_length;
echo("base screw hole minimum depth is ", base_screw_hole_z_depth);

pin_cover_rounded_corner_radius=2;

// Remove this cube from pin cover, making room for extruded pins.
pin_area_y_length=4;
pin_area_x_length=pin_and_chip_hole_edge_length;
// Length of extrution above board.
pin_area_z_length=4;

module pin_cover_pin_cut_area() {
    translate([(touch_pad_board_x_length-pin_and_chip_hole_edge_length)/2, pin_cover_y_wall_thickness, 0]) 
        #cube([pin_area_x_length, pin_area_y_length, pin_area_z_length]);
}

module pin_cover() {
    difference() {
        roundedCube([pin_cover_x_length, pin_cover_y_length, pin_cover_z_length], center=false, r=pin_cover_rounded_corner_radius,
            x=true, xcorners=[false, true, true, false],
            z=true, 
            y=true, ycorners=[true, true, false, false]);
        
        
        translate([0, pin_cover_y_wall_thickness, 0]) {
            first_pin_cover_screw_hole();
            second_pin_cover_screw_hole();
        }
        
        pin_cover_pin_cut_area();
    }
}

module touch_pad() {
    union() {
        //difference() {
            cube([touch_pad_board_x_length, touch_pad_board_y_length, touch_pad_board_z_length]);
            
            first_screw_hole();
            second_screw_hole();    
            third_screw_hole();
            fourth_screw_hole();
            
            // pin_and_chip_hole();
        //}
    
        pin_and_chip_hole();
    }
}

module screw_hole() {
    cylinder(d=number4_screw_hole_tap_diameter, h=touch_pad_board_z_length*20, center=false, $fn=50);
}

module pin_cover_screw_hole() {
    cylinder(d=number4_screw_hole_diameter, h=touch_pad_board_z_length*50, center=false, $fn=50);
}

/* Screw sink so we can use shorter screws like 5/16 inch */
module pin_cover_screw_sink_hole() {
    translate([0, 0, pin_cover_z_length-pin_cover_screw_sink_z_depth]) 
        #cylinder(d=pin_cover_screw_sink_diameter, h=pin_cover_screw_sink_z_depth, center=false, $fn=50);
}

module first_pin_cover_screw_hole() {
        translate([first_hole_center_offset_x, first_hole_center_offset_y, 0])
            union() {
                pin_cover_screw_hole();
                pin_cover_screw_sink_hole();
            }
}

module second_pin_cover_screw_hole() {
        translate([first_hole_center_offset_x+screw_hole_x_distance, first_hole_center_offset_y, 0]) 
            union() {
                pin_cover_screw_hole();
                pin_cover_screw_sink_hole();
            }
}

module first_screw_hole() {
        translate([first_hole_center_offset_x, first_hole_center_offset_y, -1]) 
            screw_hole();
}

module second_screw_hole() {
        translate([first_hole_center_offset_x, first_hole_center_offset_y+screw_hole_y_distance, -1]) 
            screw_hole();
}

module third_screw_hole() {
        translate([first_hole_center_offset_x+screw_hole_x_distance, first_hole_center_offset_y+screw_hole_y_distance, -1]) 
            screw_hole();
}

module fourth_screw_hole() {
        translate([first_hole_center_offset_x+screw_hole_x_distance, first_hole_center_offset_y, -1]) 
            screw_hole();
}

module pin_and_chip_hole() {
    translate([(touch_pad_board_x_length-pin_and_chip_hole_edge_length)/2, touch_pad_board_y_length-pin_and_chip_hole_edge_length, -1]) 
        cube([pin_and_chip_hole_edge_length, pin_and_chip_hole_edge_length, touch_pad_board_z_length*5]);
}

%touch_pad();

// This puts the cover aside the pad
translate([0, -pin_area_y_length*2-5, 0])
    pin_cover();

// This puts the cover onto the pad, to double check fit
translate([0, -pin_cover_y_wall_thickness, touch_pad_board_z_length])
    %pin_cover();