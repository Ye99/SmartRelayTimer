/* By: Ye Zhang (mr.yezhang@gmail.com)
   Date: June 7, 2020
    Smart timer and electrical box. 
*/

include <size_constants.scad>

use <electrical_box.scad>
use <control_compartment.scad>
use <BOSL/transforms.scad>

wall_thickness=wall_double_thickness/2;

// These x/y length is inner size, not including wall thickness
control_compartment_x_length=106; 
control_compartment_y_length=106;

// This includes buttom thickness (==control_compartment_wall_thickness)
control_compartment_z_length=height+wall_thickness;

// Hole for three wires relay control.
relay_control_wires_hole_diameter=8;

module cut_signal_wire_hole(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, wall_thickness) {
        // control input wires hole on the other side wall
        translate([-width/2, (length/4), control_compartment_z_length/3])
            zrot(90)
                xrot(90)
                    #cylinder(d=relay_control_wires_hole_diameter, h=wall_thickness*5, center=true, $fn=50);
}

difference() {
    union() {
        electricalbox();
        left(control_compartment_x_length+wall_thickness*2+width/2+wall_thickness)
            fwd(length/2+wall_thickness)
                control_compartment(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, wall_thickness);
    }

    cut_signal_wire_hole(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, wall_thickness);
}