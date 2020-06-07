 use <1602LCD_bezel_remix.scad>
 use <touch_pad_bezel.scad>
 use <HW-389_box.scad>
 
comtrol_compartment_x_length=96; // These x/y length is inner size, not including wall thickness
control_compartment_y_length=106; // The same width as electrical box
control_compartment_wall_thickness=2;
 
 HW_389_base(base_x_length, base_y_length, 43);
 
 module cover() {
     
 }