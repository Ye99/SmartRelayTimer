// Use include to import named constant defined in below file.
include <1602LCD_bezel_remix.scad>
include <touch_pad_bezel.scad>
include <screw_matrics.scad>
include <BOSL/constants.scad>
use <BOSL/metric_screws.scad>
use <BOSL/transforms.scad>
use <triangles.scad>
use <HW-389_box.scad>

echo("1602LCD_x_length is", 1602LCD_x_length);

module aligned_1602LCD_bezel(control_compartment_x_length, control_compartment_y_length) {
    translate([control_compartment_x_length, control_compartment_y_length-(control_compartment_y_length-1602LCD_x_length)/2, 0])
        rotate([0, 0, 270])
            1602bezel();
}

touch_pad_x_offset_to_origin=7;

/* move children to four corners, also lift it up by control_compartment_wall_thickness */
module arrange_to_four_corners(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness) {
    double_wall_thickness=control_compartment_wall_thickness*2;
    cover_hole_to_edge_offset_x=control_compartment_wall_thickness*2;
    cover_hole_to_edge_offset_y=cover_hole_to_edge_offset_x;
    
    translate([cover_hole_to_edge_offset_x, 
                cover_hole_to_edge_offset_y, 
                control_compartment_wall_thickness])
        children();
    
    translate([cover_hole_to_edge_offset_x, 
                control_compartment_y_length+double_wall_thickness-cover_hole_to_edge_offset_y, 
                control_compartment_wall_thickness])
        zrot(-90)
            children();
    
    translate([control_compartment_x_length+double_wall_thickness-cover_hole_to_edge_offset_x, 
                control_compartment_y_length+double_wall_thickness-cover_hole_to_edge_offset_y, 
                control_compartment_wall_thickness])
        zrot(-180)
            children();

    translate([control_compartment_x_length+double_wall_thickness-cover_hole_to_edge_offset_x, 
                cover_hole_to_edge_offset_y, 
                control_compartment_wall_thickness])
        zrot(-270)
            children();
}

module cover_screws(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness, screwsize) {
    arrange_to_four_corners(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness)
        screw(screwsize, 
               screwlen=number4_screw_stem_length,
               headsize=number4_screw_head_diameter,
               headlen=3, countersunk=false, align="base");
}

module aligned_touch_pad_bezel(touch_pad_x_offset_to_origin, touch_pad_bezel_y_length, touch_pad_bezel_z_length, control_compartment_y_length) {
    up(touch_pad_bezel_z_length)
        right(touch_pad_x_offset_to_origin)
            back((control_compartment_y_length-touch_pad_bezel_y_length)/2)
                touch_pad_bezel();
}

module cover(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness, isBlankCover) {
    double_wall_thickness=control_compartment_wall_thickness*2;
    difference() {
        union() {
            difference() {
                cube([control_compartment_x_length+double_wall_thickness, control_compartment_y_length+double_wall_thickness, control_compartment_wall_thickness]);
                
                if (!isBlankCover) {
                    // Cut space for the bezels. 
                    hull()
                        aligned_1602LCD_bezel(control_compartment_x_length, control_compartment_y_length);
                    
                    hull()
                        aligned_touch_pad_bezel(touch_pad_x_offset_to_origin, touch_pad_bezel_y_length, touch_pad_bezel_z_length, control_compartment_y_length);
                }
            }
            
            if (!isBlankCover) {
                // Add LCD bezel.
                aligned_1602LCD_bezel(control_compartment_x_length, control_compartment_y_length);
                
                // Add touch pad bezel.
                aligned_touch_pad_bezel(touch_pad_x_offset_to_origin, touch_pad_bezel_y_length, touch_pad_bezel_z_length, control_compartment_y_length);
            }
        }
            
        cover_screws(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness, number4_screw_hole_diameter);
    }
    
    left(control_compartment_wall_thickness)
        zrot(90)
            *touch_pad_pin_cover(); // Not enough space to print. Temporarily disable. 
}

wall_screw_tab_height=19;

module wall_screw_tab() {
    cube_side_length=number4_screw_head_diameter*1.4;
    
    difference() {
        cube([cube_side_length, cube_side_length, wall_screw_tab_height], center=true);        
        
        rotate([-30, 0, -45])
            back(number4_screw_head_diameter)
                cube([cube_side_length*2, cube_side_length, wall_screw_tab_height*5], center=true);
    }
}

/* The first childeren is HW_389_base. 
   The second children is wall screw tab */
module add_screw_tabs_to_box_top_corners(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness) {
    difference() {
        union() {
            children(0);
            
            up(control_compartment_z_length-wall_screw_tab_height/2-control_compartment_wall_thickness)
                arrange_to_four_corners(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness) 
                    children(1);
        }
        
        // On top of the box. Cut screw holes that matching those on cover. 
        up(control_compartment_z_length) {
            cover_screws(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness, number4_screw_hole_tap_diameter); 
        }
    }
}

module sensor_wire_hole(hole_x_offset, 
    control_compartment_y_length, 
    control_compartment_wall_thickness, 
    sensor_wire_hole_diameter) {
        translate([hole_x_offset, control_compartment_y_length, 24])
                xrot(90)
                    #cylinder(d=sensor_wire_hole_diameter, h=control_compartment_wall_thickness*10, center=true, $fn=50);
    }

module cut_sensor_wire_hole(control_compartment_x_length, 
    control_compartment_y_length, 
    control_compartment_z_length, 
    control_compartment_wall_thickness, 
    sensor_wire_hole_diameter) {
        if (control_compartment_x_length<58) {
            sensor_wire_hole(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness, sensor_wire_hole_diameter);
        }
        else {
            sensor_wire_hole(control_compartment_x_length-sensor_wire_hole_diameter/2, control_compartment_y_length, control_compartment_wall_thickness, sensor_wire_hole_diameter);
        }
}

module buttom_group(control_compartment_x_length, 
    control_compartment_y_length, 
    control_compartment_z_length, 
    control_compartment_wall_thickness, 
    sensor_wire_hole_diameter,
    isBlankCover) {
    difference() {
        add_screw_tabs_to_box_top_corners(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness) {
            children(); // This is the box buttom part.
            wall_screw_tab();
        }
        cut_sensor_wire_hole(control_compartment_x_length, 
            control_compartment_y_length, 
            control_compartment_z_length, 
            control_compartment_wall_thickness, 
            sensor_wire_hole_diameter);
    }
    
    // This cover here to visualize fit. It's not included in final result. 
    // On top of the box
    up(control_compartment_z_length) 
        %cover(control_compartment_x_length, 
                control_compartment_y_length,
                control_compartment_wall_thickness,
                isBlankCover);
}

module cover_group(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness, isBlankCover) {
    cover_besides_box(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness) {
        cover(control_compartment_x_length, 
                control_compartment_y_length,
                control_compartment_wall_thickness,
                isBlankCover);
    }
}

// TODO: extract this to library.
module cut_ventilation_slots(width, height, single_slot_z, slot_ratio, wall_thickness) {
    step_z = single_slot_z/slot_ratio;
    echo("step_z is ", step_z);
    for(i=[0:height/step_z]) {
        up(step_z*i)
            #cube([width, wall_thickness*2, single_slot_z], center=true);
    }
}

// Single slot hole height in mm. 
single_slot_z = 3;

// Extract this to shared library.
// A simple box without lid, with ventilation slots on y sides.
module box(net_x, net_y, total_z, wall_thickness) {
    assert(total_z > wall_thickness, "total_z must be greater than wall_thickness!");
    double_wall_thickness = wall_thickness * 2;
    difference() {
        cube([net_x+double_wall_thickness, net_y+double_wall_thickness, total_z], center = true);
        up(wall_thickness)
            cube([net_x, net_y, total_z-wall_thickness], center = true);
        
        down(total_z/2-wall_thickness*3) {
            back(net_y/2)
                cut_ventilation_slots(net_x, 
                                    total_z-wall_thickness*5, 
                                    single_slot_z, 
                                    0.6, 
                                    wall_thickness);
            fwd(net_y/2)
                cut_ventilation_slots(net_x, 
                                    total_z-wall_thickness*5, 
                                    single_slot_z, 
                                    0.6, 
                                    wall_thickness);
        }
    }
}

// If box_part_type is not "HW_389_base", render a basic box. 
module box_bottom_part(box_part_type, net_x, net_y, total_z, wall_thickness) {
    if (box_part_type == "HW_389_base") { 
        HW_389_base(net_x, net_y, total_z, wall_thickness);
    } else {
        right(net_x/2 + wall_thickness)
            back(net_y/2 + wall_thickness)
                up(total_z/2)
                    box(net_x, net_y, total_z, wall_thickness);
    }
}

// If box_part_type is not "HW_389_base", render a basic box.
module control_compartment(control_compartment_x_length, 
    control_compartment_y_length, 
    control_compartment_z_length, 
    control_compartment_wall_thickness, 
    part,
    sensor_wire_hole_diameter,
    isBlankCover,
    box_part_type) {
    if (part == "bottom") {
        buttom_group(control_compartment_x_length, 
            control_compartment_y_length, 
            control_compartment_z_length, 
            control_compartment_wall_thickness, 
            sensor_wire_hole_diameter, 
            isBlankCover) {
                box_bottom_part(box_part_type, 
                                control_compartment_x_length, 
                                control_compartment_y_length, 
                                control_compartment_z_length, 
                                control_compartment_wall_thickness);
            }
    } else if (part == "cover") {
        cover_group(control_compartment_x_length, 
            control_compartment_y_length, 
            control_compartment_z_length, 
            control_compartment_wall_thickness, 
            isBlankCover);
    } else {
        buttom_group(control_compartment_x_length, 
            control_compartment_y_length, 
            control_compartment_z_length, 
            control_compartment_wall_thickness, 
            sensor_wire_hole_diameter, 
            isBlankCover) {
                box_bottom_part(box_part_type, 
                                control_compartment_x_length, 
                                control_compartment_y_length, 
                                control_compartment_z_length, 
                                control_compartment_wall_thickness);
            }
        
        cover_group(control_compartment_x_length, 
            control_compartment_y_length, 
            control_compartment_z_length, 
            control_compartment_wall_thickness, 
            isBlankCover);
    }
}

module cover_besides_box(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness) {   
    // Besides the box
    translate([-(control_compartment_x_length+control_compartment_wall_thickness*3), 0, 0]) 
        children();
}

// These x/y length is inner size, not including wall thickness.
// Z length includes buttom thickness (==control_compartment_wall_thickness).
control_compartment(81, // control_compartment_x_length= 61 by default
    70, // control_compartment_y_length
    40, // control_compartment_z_length
    2, // control_compartment_wall_thickness
    "all", // cover, bottom, or all
    17, // sensor wire hole diameter default 8
    true, // isBlankCover?
    box_part_type="HW_389_base1"); // HW_389_base or basic box.

/*
control_compartment(106, // control_compartment_x_length=
    106, // control_compartment_y_length
    50, // control_compartment_z_length
    2, // control_compartment_wall_thickness
    "all", // cover, bottom, or all
    6, // sensor wire hole diameter
    false); // isBlankCover?
    */