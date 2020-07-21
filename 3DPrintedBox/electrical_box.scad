/* By: Ye Zhang (mr.yezhang@gmail.com)
   Date: May 22, 2020
    Electrical box module. 
*/

include <size_constants.scad>
use <roundedCube.scad>
use <BOSL/transforms.scad>

// Choose, which part you want to see!
part = "all_parts__";  //[all:All Parts,bottom:ElectrialBoxBottom,cover:ElectricalBoxCover]

// Outlet screw diameter (mm) for the holes at 2 ends
outlet_screw_hole_diag=3.4; // [3:6]
// The screw hole on box bottom tab, to secure the box.
bottom_tab_screw_hole_diag=5;
// Width of hole to run the mains input wires (mm)
// Below 14/2 wire width is 10, height is 5
// https://smile.amazon.com/gp/product/B000BPEQCC/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1
wires_hole_width=11; // [8:12]
// The height of hole to run the mains input wires (mm)
wires_hole_height=6; // [4:12]

// This is relay control wire. For three wires recommend 8.
relay_control_wires_hole_diameter=0; // [0:12]. 

// Radius of rounded corner
rounded_corner_radius=2;

cover_alignment_tab_length=3;
cover_alignment_tab_height=5;
// The tab is short, regular wall thickness isn't strong enough. 
cover_alignment_tab_thickness=wall_double_thickness*2;
// The larger this value, the more cover free-play allowed.
cover_alignment_tab_tolerance=0.2;

electricalbox(part);

module electricalbox(part) {
    if (part == "bottom") {
        electricalbox_buttom();
    } else if (part == "cover") {
        right(wall_double_thickness)
            electricalbox_cover();
    } else if (part == "all") {
        electricalbox_all();
    }
}

module put_bottom_to_z_zero() {
    translate([0, 0, (height+wall_double_thickness/2)/2]) 
        children();
}

module put_cover_to_z_zero() {
    translate([0, 0, (wall_double_thickness/2+cover_wall_height)/2]) 
        children();
}

module electricalbox_all() {
    electricalbox_buttom();

    // This put cover next to box
    translate([width+(wall_double_thickness*2), 0, 0])
            electricalbox_cover();
}

outlet_screw_hole_depth=35; // how far down is the outlet screw hole in supporting cylinder.
support_cylinder_radius=outlet_screw_hole_diag*2+1;
// Enlong the cylinder by this factor.
support_cylinder_scale_factor=2.1;
// distance between supporting cylinder and box top
cylinder_top_gap=5.5-wall_double_thickness; // deduct cover thickness so the outlet will be flush.

// Outlet screw off set from edge. Change according to your measurement with caution!
// My desin references x,y,z 0 (center), and thus changing wall thickness won't inerference screw_position.
screw_posistion_from_edge=11; // Outlet screw holes are 84mm apart. Must be precise!

// Cover wall height in mm, not including cover thickness.
cover_wall_height=3;

module one_plug_hole() {
    difference() {
        cylinder(r=17.4625, h=15, center = true, $fn=50);
        translate([-24.2875,-15,-cover_wall_height*2]) cube([10,37,15], center=false);
        translate([14.2875,-15,-cover_wall_height*2]) cube([10,37,15], center=false);
   }
}

module cover_alignment_tab() {
    cube([cover_alignment_tab_thickness, cover_alignment_tab_length, cover_alignment_tab_height], center=false);
}

module electricalbox_cover(width=width, length=length, height=height, screw_pos=screw_posistion_from_edge) {
    put_cover_to_z_zero() {
        union() {
            difference() {        
               difference() {
                    // outside wall
                    roundedCube([width + wall_double_thickness, length + wall_double_thickness, cover_wall_height+wall_double_thickness/2], center=true, r=rounded_corner_radius);
                    // inside wall
                    translate([0, 0, wall_double_thickness/2]) 
                        roundedCube([width, length, cover_wall_height], center=true, r=rounded_corner_radius);
                } 

                // Outlet opening and screw hole
                rotate([0,0,90]) 
                    translate([-length/2+12, 0, 0]) // why is this magic number?
                        union() {
                            translate([height+19.3915, 0, 0]) 
                            {
                                one_plug_hole();
                            }
                        
                            translate([height-19.3915, 0, 0]){
                                one_plug_hole();
                            }
                            
                            // center hole. 4mm diameter.
                            // printed holes tend to shrink, give it 5mm. 
                            translate([height, 0, -3]) cylinder(r=2.5, h=20, $fn=50); 
                            translate([height, 0, 3.5]) cylinder(r1=2.5, r2=3.3, h=3);            
                        }
            }
            
            translate([-width/2+cover_alignment_tab_tolerance, length/3, 0]) 
                cover_alignment_tab();
            translate([width/2-cover_alignment_tab_tolerance-cover_alignment_tab_thickness, length/3, 0]) 
                cover_alignment_tab();
        }
    }
}

module box_walls(ow_width, ow_length, ow_height) {
        difference() {
            // box walls
            difference() {
                // outside wall
                roundedCube([ow_width, ow_length, ow_height], center=true, r=rounded_corner_radius,
                zcorners=[false, true, true, false]);
                // inside wall
                translate([0, 0, wall_double_thickness/2]) 
                    roundedCube([width, length, height], center=true, r=rounded_corner_radius);
            } 
        
           // mains input wires hole on side wall
           translate([ow_width/2, -(ow_length/4), -ow_height/4])
                // cube's x, y, z parameters confirm to the overall axes, making reasoning simple. 
                cube([wall_double_thickness*2, wires_hole_width, wires_hole_height], center=true);
            
           // control input wires hole on the other side wall
           translate([-ow_width/2, (ow_length/4), -ow_height/3])
            rotate([0, 90, 0])
                cylinder(d=relay_control_wires_hole_diameter, h=wall_double_thickness, center=true, $fn=50);
    }
}

module outlet_screw_cylinder(length, ow_height, screw_pos) {
    cylinder_height = ow_height - cylinder_top_gap;

    translate([0, -length/2, -ow_height/2])
        difference(){
                // the support cylinder
                scale([1, support_cylinder_scale_factor, 1]) 
                    cylinder(h=cylinder_height, 
                            r1=support_cylinder_radius, 
                            r2=support_cylinder_radius, $fn=60, center=false);
                
                translate([0, -support_cylinder_radius*1.5, ow_height/2+wall_double_thickness]) // to make tab strong, its thickness equals to wall_double_thickness
                 {
                    scale([1, 1.5, 1])
                        // remove half of the outer cylinder                  
                        cube([support_cylinder_radius*2, support_cylinder_radius*2, 
                              ow_height], true);
                    // screw hole in the outside cylinder tab
                    translate([0, 2, -3])
                        cylinder(r=bottom_tab_screw_hole_diag/2, h=ow_height*2, $fn=50, center=true);
                }
                    
                // screw hole in the cylinder
                translate([0, screw_pos, cylinder_height-outlet_screw_hole_depth+1]) {
                        cylinder(r=outlet_screw_hole_diag/2, h=outlet_screw_hole_depth, $fn=50, center=false);
            }
        }
}

module lengh_support(ow_width, ow_height, wall_double_thickness) {
    rotate([0,0,90]) 
        translate([0, -(ow_width/2)+wall_double_thickness/2, -ow_height/2])
            scale([1, 0.6, 1]) // support_cylinder_radius shrink widthwise, leave more room for outlet body.
                difference(){
                    cylinder(ow_height, support_cylinder_radius, support_cylinder_radius, $fn=60);
                    translate([-support_cylinder_radius, -support_cylinder_radius*2-1, -1])
                        cube([support_cylinder_radius*2, support_cylinder_radius*2, ow_height+wall_double_thickness]);
                }
}

/*
 * Function electricalbox_buttom()
 * Draw the box bottom
 */
module electricalbox_buttom(width=width, length=length, height=height, screw_pos=screw_posistion_from_edge) {
    ow_width = width+wall_double_thickness;
    ow_length = length+wall_double_thickness;
    ow_height = height+wall_double_thickness/2;
    
    put_bottom_to_z_zero() {
        box_walls(ow_width, ow_length, ow_height);
          
        // outlet screw cylinder
        outlet_screw_cylinder(length, ow_height, screw_pos);
        // the other one
        rotate([0,0,180])  
            outlet_screw_cylinder(length, ow_height, screw_pos);
        
        // support lengh-wide
        lengh_support(ow_width, ow_height, wall_double_thickness);
        
        // the other support lengh-wide
        rotate([0,0,180]) 
            lengh_support(ow_width, ow_height, wall_double_thickness);
        
        up((height+wall_double_thickness*3)/2)
            xrot(180)
                %electricalbox_cover();
    }
    

}