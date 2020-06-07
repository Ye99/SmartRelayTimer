/* By: Ye Zhang (mr.yezhang@gmail.com)
   Date: June 6, 2020
    HW-389 base. To be embedded into panel. 
*/

use <roundedCube.scad>
include <screw_matrics.scad>

wall_thickness=1;

// Add this to measured sizes and get opening sizes. 
free_play_size=2;

// both x and y minimum length is 60. Can be longer to accomdate larger panel size.
base_x_length=60;
base_y_length=60;
// The minimum height covering HW-389 and ESP8266 V3 board, same origin as x wall hole origon---PCB top surface.
base_z_length=17;

first_hole_center_offset_x=15;
first_hole_center_offset_y=5;
screw_hole_x_distance=25;
screw_hole_y_distance=52;

pcb_board_thickness=1.5;
under_pcb_board_pin_extrusion_distance=5;

// This makes sure the screw won't penetrate base.
box_button_no_screw_thickness=1;
box_bottom_thickness=number4_screw_stem_length-pcb_board_thickness-under_pcb_board_pin_extrusion_distance+box_button_no_screw_thickness;

assert(box_bottom_thickness >= 1, "Box bottom thickness must be >= 1");
echo("*** Use M3x5 screw ***");
echo("The minimum box bottom thickness is ", box_bottom_thickness);

x_side_wall_holes_origin_z_offset=under_pcb_board_pin_extrusion_distance+pcb_board_thickness+box_bottom_thickness;
// dc_plug_center_y_offset=4.5;
dc_plug_x_offset=0;
dc_plug_x_length=9;
dc_plug_z_length=11;
dc_plug_z_offset=0+x_side_wall_holes_origin_z_offset;

usb_plug_x_offset=23.4;
usb_plug_x_length=7.5;
usb_plug_z_length=3;
usb_plug_z_offset=12+x_side_wall_holes_origin_z_offset;


side_wall_z_length=base_z_length+x_side_wall_holes_origin_z_offset;

module pcb_board_one_raise() {
    hull() {
            translate([screw_hole_x_distance, screw_hole_y_distance, 0]) 
                circle(d=number4_screw_head_diameter, $fn=50);
            circle(d=number4_screw_head_diameter, $fn=50);
    }
}
/* Pin extruded under PCB board. Raise the board for clearance */
module pcb_board_raise() {
    linear_extrude(height=under_pcb_board_pin_extrusion_distance, center=false, convexity = 10) 
        translate([first_hole_center_offset_x, first_hole_center_offset_y, 0]) {
            pcb_board_one_raise();
            // The other raise. 
            translate([screw_hole_x_distance, 0, 0])
                rotate([0, 0, atan(screw_hole_x_distance/screw_hole_y_distance)*2]) // 
                    pcb_board_one_raise();
        }
}

module usb_plug_hole() {
    translate([usb_plug_x_offset, 0, usb_plug_z_offset]) 
        cube([usb_plug_x_length, wall_thickness, usb_plug_z_length]);
}

module dc_plug_hole() {
    translate([dc_plug_x_offset, 0, dc_plug_z_offset]) 
        cube([dc_plug_x_length, wall_thickness, dc_plug_z_length]);
}

/* The wall along x axis, from origin */
module x_side_wall() {
    difference() {
        cube([base_x_length, wall_thickness, side_wall_z_length]);
        translate([0, 0, 0]) {
            usb_plug_hole();
            dc_plug_hole();
        }
    }
}

/* The wall along y axis, from origin */
module y_side_wall() {
    cube([wall_thickness, base_y_length+wall_thickness, side_wall_z_length]);
}


module HW_389_base() {
    union() {
        translate([wall_thickness, 0, 0]) {
            translate([0, wall_thickness, 0]) {
                difference() {
                    union() {
                        cube([base_x_length, base_y_length, box_bottom_thickness]);
                        translate([0, 0, box_bottom_thickness])
                            pcb_board_raise();
                    }
                    
                    first_screw_hole();
                    second_screw_hole();    
                    third_screw_hole();
                    fourth_screw_hole();
                }
                
                // The plate to plug through holes, make sure there is box_button_no_screw_thickness at bottom. 
                cube([base_x_length, base_y_length, box_button_no_screw_thickness]);
            }
            x_side_wall();
        }
        
        y_side_wall();
    }
}

module screw_hole() {
    #cylinder(d=number4_screw_hole_tap_diameter, h=wall_thickness*20, center=false, $fn=50);
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



HW_389_base();