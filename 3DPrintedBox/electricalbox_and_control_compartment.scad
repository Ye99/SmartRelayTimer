/* By: Ye Zhang (mr.yezhang@gmail.com)
   Date: June 7, 2020
    Smart timer and electrical box. 
*/

include <size_constants.scad>
use <electrical_box.scad>
use <control_compartment.scad>
use <BOSL/transforms.scad>

// If set to true, compartment cover doesn't have screen or touch pad.
is_blank_cover=false;

// Installs a standard mains outlet and relay.
has_electricalbox=false;

// Fan cooled compartment suitable for MOSFET.
has_fan_cooled_compartment=true;

// The parts are too large to fit printer bed. 
// Set this to true and false respectively and generate two separate STL files. 
only_fan_cooled_compartment_cover=false;

// Print cover/bottom separately if your printer bed isn't large enough for "all" at once.
part_enum = "all"; // Options "cover", "bottom", "all"

// These x/y length is inner size, not including wall thickness
control_compartment_x_length=is_blank_cover ? 61 : 106; 
control_compartment_y_length=106;
wall_thickness=wall_double_thickness/2;
// This includes buttom thickness (==control_compartment_wall_thickness)
control_compartment_z_length=height+wall_thickness;
echo("Compartment net inside height is ", height);

fan_cooled_compartment_net_x=41; // Install 40mm fan.
assert(fan_cooled_compartment_net_x >=40, "Too small to install 40mm fan!");
fan_cooled_compartment_net_y=control_compartment_y_length;
fan_cooled_compartment_total_z=control_compartment_z_length;

// Between control comartment and the eletrical compartment.
control_wires_hole_diameter=8;
// Between control compartment and outside. 
sensor_wires_hole_diameter=0;

// Between fan cooled compartment and outside.
output_wires_hole_diameter=15;

module cut_signal_wire_hole(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, wall_thickness, hole_diameter) {
        // control input wires hole on the other side wall
        hole_y_location = has_fan_cooled_compartment ? -(length/8) : (length/4);
        hole_z_location = has_fan_cooled_compartment ? control_compartment_z_length*8/11 : control_compartment_z_length/3;
        translate([-width/2, hole_y_location, hole_z_location])
            zrot(90)
                xrot(90)
                    #cylinder(d=hole_diameter, h=wall_thickness*5, center=true, $fn=50);
}

module arrange_x_positions() {
    if ("cover" == part_enum) {
        left(width/2)  
            children();
    } else {
        left(control_compartment_x_length+wall_thickness*2+width/2+wall_thickness)
            children();
    }
}

difference() {
    union() {
        if (has_electricalbox)
            electricalbox(part_enum); 
        else if (has_fan_cooled_compartment) {
            double_wall_thickness = wall_thickness*2;
            fan_cooled_compartment_part_enum = only_fan_cooled_compartment_cover ? "cover" : "bottom";
            // Put the fan cooled compartment at the exact location of the electrical box. 
            right(fan_cooled_compartment_net_x+double_wall_thickness+(width-fan_cooled_compartment_net_y-wall_thickness)/2)
                back(fan_cooled_compartment_net_y/2+wall_thickness)
                    zrot(180)
                        control_compartment(fan_cooled_compartment_net_x, 
                                            fan_cooled_compartment_net_y, 
                                            fan_cooled_compartment_total_z, 
                                            wall_thickness, 
                                            fan_cooled_compartment_part_enum, 
                                            sensor_wires_hole_diameter, 
                                            true,
                                            box_part_type="basic_box");
        }
        if (!only_fan_cooled_compartment_cover)
            arrange_x_positions()
                fwd(length/2+wall_thickness)
                    control_compartment(control_compartment_x_length, 
                                        control_compartment_y_length, 
                                        control_compartment_z_length, 
                                        wall_thickness, 
                                        part_enum, 
                                        sensor_wires_hole_diameter, 
                                        is_blank_cover,
                                        box_part_type="HW_389_base");
    }

    if ("cover" != part_enum)
        cut_signal_wire_hole(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, wall_thickness, control_wires_hole_diameter);
    
    if (has_fan_cooled_compartment) {
        right(fan_cooled_compartment_net_x)
            cut_signal_wire_hole(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, wall_thickness, output_wires_hole_diameter);
    }
}