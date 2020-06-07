// Use include to import named constant defined in below file.
include <1602LCD_bezel_remix.scad>
include <touch_pad_bezel.scad>

use <HW-389_box.scad>

control_compartment_wall_thickness=2;

// These x/y length is inner size, not including wall thickness
control_compartment_x_length=96; 
control_compartment_y_length=106;

// This includes buttom thickness (==control_compartment_wall_thickness)
control_compartment_z_length=30;

echo("1602LCD_x_length is", 1602LCD_x_length);

module aligned_1602LCD_bezel() {
    translate([control_compartment_x_length, control_compartment_y_length-(control_compartment_y_length-1602LCD_x_length)/2, 0])
        rotate([0, 0, 270])
            1602bezel();
}

module cover(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness) {
    double_wall_thickness=control_compartment_wall_thickness*2;
    union() {
        difference() {
            cube([control_compartment_x_length+double_wall_thickness, control_compartment_y_length+double_wall_thickness, control_compartment_wall_thickness]);
            
            // Cut space for the bezel. 
            hull()
                aligned_1602LCD_bezel();
            
            // Cut space for the keypad.
        }
        
        // Add the bezel.
        aligned_1602LCD_bezel();
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
        touch_pad_pin_cover();
}

module layout_cover(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness) {
    // On top of the box
    translate([0, 0, control_compartment_z_length]) 
        children();
    
    // Besides the box
    translate([-(control_compartment_x_length+control_compartment_wall_thickness*3), 0, 0]) 
        children();
}

control_compartment(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness);