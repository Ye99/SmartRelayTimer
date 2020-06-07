/* By: Ye Zhang (mr.yezhang@gmail.com)
   Date: June 6, 2020
    HW-389 base. To be embedded into panel. 
*/

use <roundedCube.scad>

wall_thickness=1;

// Add this to measured sizes and get opening sizes. 
free_play_size=2;

// both x and y minimum length is 60. Can be longer to accomdate larger panel size.
base_x_length=60;
base_y_length=60;

// The minimum height covering HW-389 and ESP8266 V3 board, including protruded pin height under HW-389.
base_z_length=20;

// dc_plug_center_y_offset=4.5;
dc_plug_x_offset=0;
dc_plug_x_length=9;
dc_plug_z_length=11;
dc_plug_z_offset=0;

usb_plug_x_offset=23.4;
usb_plug_x_length=7.5;
usb_plug_z_length=3;
usb_plug_z_offset=12;

// M3 screw parameters
screw_hole_tap_diameter=2.8;
screw_thread_diamater=3;
// No-drag through-hole diameter
screw_hole_diameter=screw_thread_diamater+0.7;
screw_stem_length=5;
screw_head_diameter=5.5;

first_hole_center_offset_x=15;
first_hole_center_offset_y=5;
screw_hole_x_distance=25;
screw_hole_y_distance=52;

pcb_board_thickness=1.5;
// This makes sure the screw won't penetrate base.
box_button_no_screw_thickness=1;
box_bottom_thickness=screw_stem_length-pcb_board_thickness+box_button_no_screw_thickness;

echo("*** Use M3x5 screw ***");
echo("The minimum box bottom thickness is ", box_bottom_thickness);

module usb_plug_hole() {
    translate([usb_plug_x_offset, 0, usb_plug_z_offset]) 
        cube([usb_plug_x_length, wall_thickness, usb_plug_z_length]);
}

module dc_plug_hole() {
    translate([dc_plug_x_offset, 0, dc_plug_z_offset]) 
        cube([dc_plug_x_length, wall_thickness, dc_plug_z_length]);
}

module side_wall() {
    difference() {
        cube([base_x_length, wall_thickness, base_z_length+box_bottom_thickness]);
        translate([0, 0, box_bottom_thickness]) {
            usb_plug_hole();
            dc_plug_hole();
        }
    }
}

module HW_389_base() {
    union() {
        translate([0, wall_thickness, 0]) {
            difference() {
                cube([base_x_length, base_y_length, box_bottom_thickness]);
                
                first_screw_hole();
                second_screw_hole();    
                third_screw_hole();
                fourth_screw_hole();
            }
            cube([base_x_length, base_y_length, box_button_no_screw_thickness]);
        }
            
        side_wall();
    }
}

module screw_hole() {
    cylinder(d=screw_hole_tap_diameter, h=wall_thickness*20, center=false, $fn=50);
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