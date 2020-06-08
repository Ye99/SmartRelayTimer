// Use include to import named constant defined in below file.
include <1602LCD_bezel_remix.scad>
include <touch_pad_bezel.scad>
include <screw_matrics.scad>
include <BOSL/constants.scad>
use <BOSL/metric_screws.scad>
use <BOSL/transforms.scad>
use <triangles.scad>
use <HW-389_box.scad>

control_compartment_wall_thickness=2;

// These x/y length is inner size, not including wall thickness
control_compartment_x_length=106; 
control_compartment_y_length=106;

// This includes buttom thickness (==control_compartment_wall_thickness)
control_compartment_z_length=50;

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

cover_hole_to_edge_offset_x=control_compartment_wall_thickness*2;
cover_hole_to_edge_offset_y=cover_hole_to_edge_offset_x;

/* move children to four corners, also lift it up by control_compartment_wall_thickness */
module arrange_to_four_corners(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness) {
    double_wall_thickness=control_compartment_wall_thickness*2;
    
    translate([cover_hole_to_edge_offset_x, 
                cover_hole_to_edge_offset_y, 
                control_compartment_wall_thickness])
        children();
    
    translate([cover_hole_to_edge_offset_x, 
                control_compartment_y_length+double_wall_thickness-cover_hole_to_edge_offset_y, 
                control_compartment_wall_thickness])
        zrot(-90)
            children();
    
    translate([control_compartment_y_length+double_wall_thickness-cover_hole_to_edge_offset_x, 
                control_compartment_y_length+double_wall_thickness-cover_hole_to_edge_offset_y, 
                control_compartment_wall_thickness])
        zrot(-180)
            children();

    translate([control_compartment_y_length+double_wall_thickness-cover_hole_to_edge_offset_x, 
                cover_hole_to_edge_offset_y, 
                control_compartment_wall_thickness])
        zrot(-270)
            children();
}

module cover_screws() {
    arrange_to_four_corners(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness)
        #screw(screwsize=number4_screw_hole_diameter, 
               screwlen=number4_screw_stem_length,
               headsize=number4_screw_head_diameter,
               headlen=3, countersunk=false, align="base");
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
            
        cover_screws();
    }
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
module add_screw_tabs_to_box_bottom(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness) {
    difference() {
        union() {
            children(0);
            
            up(control_compartment_z_length-wall_screw_tab_height/2-control_compartment_wall_thickness)
                arrange_to_four_corners(control_compartment_x_length, control_compartment_y_length, control_compartment_wall_thickness) 
                    children(1);
        }
        
        // On top of the box
        up(control_compartment_z_length) {
            cover_screws(); 
            // This cover here to visualize fit. It's not included in final result. 
            %cover(control_compartment_x_length, 
                    control_compartment_y_length,
                    control_compartment_wall_thickness);
        }
    }
}

module buttom_group(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness) {
    add_screw_tabs_to_box_bottom(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness) {
        HW_389_base(control_compartment_x_length, 
                    control_compartment_y_length, 
                    control_compartment_z_length, 
                    control_compartment_wall_thickness);
        wall_screw_tab();
    }
    
    // Cover on box, for checking fit. Not included in model output. 
    translate([0, -20, 0])
        *touch_pad_pin_cover();
}

module cover_group(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness) {
    cover_besides_box(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness) {
        cover(control_compartment_x_length, 
              control_compartment_y_length,
              control_compartment_wall_thickness);
    }
}

module control_compartment(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness, part) {
    if (part == "bottom") {
        buttom_group(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness);
    } else if (part == "cover") {
        cover_group(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness);
    } else {
        buttom_group(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness);
        cover_group(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness);
    }
}

module cover_besides_box(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness) {   
    // Besides the box
    translate([-(control_compartment_x_length+control_compartment_wall_thickness*3), 0, 0]) 
        children();
}

control_compartment(control_compartment_x_length, control_compartment_y_length, control_compartment_z_length, control_compartment_wall_thickness, "bottom");