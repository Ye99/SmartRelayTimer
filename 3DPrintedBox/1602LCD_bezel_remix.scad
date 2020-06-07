1602LCD_z_length=6;
1602LCD_x_length=90;
1602LCD_y_length=46;

// Hole for the extruded pins on the board
pin_hole_depth=4.2;
pin_hole_length=44;
pin_hole_height=4.5;

// Screw hole diameter is 3mm.
existing_screw_hole_diameter=3;
existing_screw_hole_x_distance=50;
existing_screw_hole_y_distance=30;

screw_hole_plug_diameter=existing_screw_hole_diameter*1.5;
screw_hole_plug_height=1.5;

/* Plug the STL's through-hole */
module screw_hole_plug() {
    translate([0, 0, screw_hole_plug_height/2]) {
        cylinder(d=screw_hole_plug_diameter, h=screw_hole_plug_height, center=true, $fn=50);
    }
}

module deeper_pin_hole() {
    translate([35, 37, 1.8]) 
        cube([pin_hole_length, pin_hole_height, pin_hole_depth]);
}

module 1602bezel() {
    translate([1602LCD_x_length, -1602LCD_y_length, 1602LCD_z_length])
        rotate([0, 180, 0]) // Flip to make it face up.
            difference() {
                import("1602LCD_bezel_fixed.stl");
                deeper_pin_hole();
            }
}

*1602bezel();