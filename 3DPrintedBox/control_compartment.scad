use <1602LCD_bezel_remix.scad>
use <touch_pad_bezel.scad>
use <HW-389_box.scad>

control_compartment_wall_thickness=2;

// These x/y length is inner size, not including wall thickness
control_compartment_x_length=96; 
control_compartment_y_length=106;

// This includes buttom thickness (==control_compartment_wall_thickness)
control_compartment_z_length=30; 


module cover(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness) {
     
}

module control_compartment(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness) {
        HW_389_base(control_compartment_x_length, 
                    control_compartment_y_length, 
                    control_compartment_z_length, 
                    control_compartment_wall_thickness);
    
        cover(control_compartment_x_length, 
              control_compartment_y_length, 
              control_compartment_z_length, 
              control_compartment_wall_thickness);
}

control_compartment(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness);