/* By: Ye Zhang (mr.yezhang@gmail.com)
   Date: June 6, 2020
    Touch pad bezel. To be embedded into panel. 
*/

use <roundedCube.scad>
use <BOSL/transforms.scad>

include <screw_matrics.scad>
use <BOSL/metric_screws.scad>

// PCB board dimensions. 
touch_pad_board_x_length=49.1;
touch_pad_board_y_length=80;
// This is PCB board thickness.
touch_pad_board_z_length=1.56; 

screw_hole_y_distance=72.5;
screw_hole_x_distance=41;

first_hole_center_offset_y=3.5;
first_hole_center_offset_x=4.5;

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

// Minimum hole depth for #4 5/16 screw to seat.
// Add 1mm so the screw won't run through.
// Because the board is embedded flush in the bezel
touch_pad_bezel_z_length=number4_screw_stem_length+1;
echo("touch_pad_bezel_z_length is ", touch_pad_bezel_z_length);

// Make bezel wider than the acutal board size, to make good connection with the rest of cover it integrates to.
touch_pad_bezel_two_sides_enlarge_size=4;
touch_pad_bezel_x_length=touch_pad_board_x_length+touch_pad_bezel_two_sides_enlarge_size;
touch_pad_bezel_y_length=touch_pad_board_y_length+touch_pad_bezel_two_sides_enlarge_size;

pin_cover_rounded_corner_radius=2;

// Remove this cube from pin cover, making room for extruded pins.
pin_area_y_length=4;
pin_area_x_length=pin_and_chip_hole_edge_length;
// Length of extrution above board.
pin_area_z_length=4;

module pin_cover_pin_cut_area() {
    translate([(touch_pad_board_x_length-pin_and_chip_hole_edge_length)/2, pin_cover_y_wall_thickness, 0]) 
        cube([pin_area_x_length, pin_area_y_length, pin_area_z_length]);
}

module touch_pad_pin_cover() {
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
    down(touch_pad_board_z_length)
        union() {
            cube([touch_pad_board_x_length, touch_pad_board_y_length, touch_pad_board_z_length]);
            assign_screws_to_four_corners();
            pin_and_chip_hole();
        }
}

module screw_hole() {
    #screw(screwsize=number4_screw_hole_tap_diameter, 
       screwlen=number4_screw_stem_length,
       headsize=number4_screw_head_diameter,
       headlen=3, countersunk=false, align="base");
    // cylinder(d=number4_screw_hole_tap_diameter, h=touch_pad_base_screw_hole_z_depth*2, center=false, $fn=50);
}

module pin_cover_screw_hole() {
    cylinder(d=number4_screw_hole_diameter, h=touch_pad_board_z_length*50, center=false, $fn=50);
}

/* Screw sink so we can use shorter screws like 5/16 inch */
module pin_cover_screw_sink_hole() {
    // Could have use the screw library, no need to create the screw on your own.
    translate([0, 0, pin_cover_z_length-pin_cover_screw_sink_z_depth]) 
        cylinder(d=pin_cover_screw_sink_diameter, h=pin_cover_screw_sink_z_depth, center=false, $fn=50);
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

module lift_screw_base_to_surface() {
    up(touch_pad_board_z_length) {
        children();
    }
}

module assign_screws_to_four_corners() {
    back(first_hole_center_offset_y)
        right(first_hole_center_offset_x)
            lift_screw_base_to_surface()
                screw_hole();
    
    back(first_hole_center_offset_y+screw_hole_y_distance)
        right(first_hole_center_offset_x)
            // up(pin_cover_z_length-pin_cover_screw_sink_z_depth) // Give deeper hole than needed.
                lift_screw_base_to_surface()
                    screw_hole();
    
    back(first_hole_center_offset_y+screw_hole_y_distance)
        right(first_hole_center_offset_x+screw_hole_x_distance)
            // up(pin_cover_z_length-pin_cover_screw_sink_z_depth) // Give deeper hole than needed.
                lift_screw_base_to_surface()
                    screw_hole();
    
    back(first_hole_center_offset_y)
        right(first_hole_center_offset_x+screw_hole_x_distance)
            lift_screw_base_to_surface()
                screw_hole();
}

module pin_and_chip_hole() {
    translate([(touch_pad_board_x_length-pin_and_chip_hole_edge_length)/2, 
                touch_pad_board_y_length-pin_and_chip_hole_edge_length, 
                -pin_and_chip_hole_edge_length]) 
        cube([pin_and_chip_hole_edge_length, pin_and_chip_hole_edge_length, pin_and_chip_hole_edge_length]);
}

/* This is the component to be used */
module touch_pad_bezel() {
    difference() {
        down(touch_pad_bezel_z_length)
            roundedCube([touch_pad_bezel_x_length, 
                        touch_pad_bezel_y_length,
                        touch_pad_bezel_z_length], 
                        center=false, 
                        r=pin_cover_rounded_corner_radius,
                        z=true);
        
        shift_object_for_bezel_wall()
                    #touch_pad();
    }
}

module shift_object_for_bezel_wall () {
    back(touch_pad_bezel_two_sides_enlarge_size/2)    
        right(touch_pad_bezel_two_sides_enlarge_size/2)
            children();
}

*touch_pad_bezel();

// This puts the cover aside the pad
translate([0, -pin_area_y_length*2-5, 0])
    *touch_pad_pin_cover();

// This puts the cover onto the pad, to double check fit
// fwd(pin_cover_y_wall_thickness)
back(touch_pad_board_y_length+pin_cover_y_wall_thickness)
    shift_object_for_bezel_wall()
    // The 0.8 magic number is because the dimentions are measured from physical board and are not strictly symmetrical. 
    // touch_pad_pin_cover is flipped and thus exposes this asymmetrical issue. 
    right(pin_cover_x_length+0.8) 
        zrot(180)
            *touch_pad_pin_cover();

