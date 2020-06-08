// Use include to import named constant defined in below file.
include <1602LCD_bezel_remix.scad>
include <touch_pad_bezel.scad>

use <HW-389_box.scad>

control_compartment_wall_thickness=2;

// These x/y length is inner size, not including wall thickness
control_compartment_x_length=106; 
control_compartment_y_length=106;

// This includes buttom thickness (==control_compartment_wall_thickness)
control_compartment_z_length=30;

echo("1602LCD_x_length is", 1602LCD_x_length);

module aligned_1602LCD_bezel() {
    translate([control_compartment_x_length, control_compartment_y_length-(control_compartment_y_length-1602LCD_x_length)/2, 0])
        rotate([0, 0, 270])
            1602bezel();
}

touch_pad_x_offset_to_origin=8;
/* Move touch pad to correct x,y position */
module align_touch_pad() {
    translate([touch_pad_x_offset_to_origin, 
               (control_compartment_y_length-touch_pad_board_y_length)/2, 
               0])
        children();
}

touch_pad_support_thickness=touch_pad_base_screw_hole_z_depth+1;
// The support is wider than the acutal board size, to make good connection with cover.
touch_pad_support_two_sides_enlarge_size=control_compartment_wall_thickness*3;

module touch_pad_support() {
    translate([-touch_pad_support_two_sides_enlarge_size/2, -touch_pad_support_two_sides_enlarge_size/2, -touch_pad_support_thickness])
        cube([touch_pad_board_x_length+touch_pad_support_two_sides_enlarge_size, 
              touch_pad_board_y_length+touch_pad_support_two_sides_enlarge_size, touch_pad_support_thickness]);
}

module cover(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness) {
    double_wall_thickness=control_compartment_wall_thickness*2;
    difference() {
        union() {
            difference() {
                cube([control_compartment_x_length+double_wall_thickness, control_compartment_y_length+double_wall_thickness, control_compartment_wall_thickness]);
                
                // Cut space for the bezel. 
                hull()
                    aligned_1602LCD_bezel();
            }
            
            // Add LCD bezel.
            aligned_1602LCD_bezel();
            
            // Add touch pad support
            align_touch_pad()
                touch_pad_support();
        }
        
        // Cut space for the touch pad.
        // OpenSCAD shows mesh on cut surface, if the two surfaces are aligned.
        // The mesh looks as if the cut doesn't exist in my case, though in slicer it's perfect. 
        // Add a tiny offset to break the aligment, so the cut is easier to see in OpenSCAD. 
        up(control_compartment_wall_thickness + 0.001)
            align_touch_pad()
                #touch_pad();
            
    }
}

module control_compartment(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness) {
    %HW_389_base(control_compartment_x_length, 
                control_compartment_y_length, 
                control_compartment_z_length, 
                control_compartment_wall_thickness);
    
    layout_cover(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness) {
        cover(control_compartment_x_length, 
              control_compartment_y_length,
              control_compartment_wall_thickness);
    }
    
    translate([0, -20, 0])
        *touch_pad_pin_cover();
}

module layout_cover(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness) {
    // On top of the box
    translate([0, 0, control_compartment_z_length]) 
        %children();
    
    // Besides the box
    translate([-(control_compartment_x_length+control_compartment_wall_thickness*3), 0, 0]) 
        children();
}

control_compartment(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness);